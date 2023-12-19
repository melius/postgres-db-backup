# Postgres DB Backup

Este proyecto aloja scripts de configuración para realizar backups automáticos de bases de datos Postgres en 2 factores. Los backups se almacenan en:

- Un bucket de S3
- Este mismo servidor (local)

## Requisitos

- Servidor Linux (en esta configuración se utiliza Ubuntu 22.04)
- Bucket de S3 (en esta configuración se utiliza [DigitalOcean Spaces](https://www.digitalocean.com/products/spaces/))

## Configuración Spaces en DigitalOcean

### Crear bucket

1. Dentro de su cuenta de DigitalOcean, en la barra lateral de navegación, busque `Spaces Object Storage`.
2. Seleccione `Create Spaces Bucket`.
3. Seleccione una región, ingrese un nombre único y un proyecto.
4. Tome nota del nombre del bucket y la región.

### Crear llaves de acceso a Spaces

1. Dentro de su cuenta de DigitalOcean, en la barra lateral de navegación, busque `API`.
2. Seleccione la pestaña `Spaces Keys`.
3. Seleccione `Generate New Key` e ingrese un nombre para la llave.
4. Tome nota de la llave (access key) y el secreto (secret key).

## Instalación de dependencias

Complete todo los pasos a continuación:

### Instalar Postgres Client

Actualice los repositorios de Postgres:

```bash
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```

Importe la llave de firma del repositorio:

```bash
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
```

Actualice los repositorios:

```bash
sudo apt-get update
```

Instale el cliente de Postgres (**Reemplazar 15 por la versión de Postgres del clúster**):

```bash
sudo apt-get -y install postgresql-client-15
```

### Instalar s3cmd

Primero configure pip:

```bash
sudo apt-get install -y python3-pip
```

Instale s3cmd:

```bash
sudo pip install s3cmd
```

### Configurar s3cmd

Siga los pasos a continuación para configurar s3cmd:

```bash
s3cmd --configure
```

- Access Key: la llave de acceso a Spaces
- Secret Key: el secreto de acceso a Spaces
- Default Region: presione Enter
- S3 Endpoint: `nyc3.digitaloceanspaces.com` (reemplazar `nyc3` por la región de su bucket)
- DNS-style bucket+hostname:port template for accessing a bucket: `%(bucket)s.nyc3.digitaloceanspaces.com` (reemplazar `nyc3` por la región de su bucket)
- Encryption password: presione Enter
- Path to GPG program: presione Enter
- Use HTTPS protocol: `Yes`
- HTTP Proxy server name: presione Enter

Después pruebe la configuración, que debe ser correcta, y guardela. Tome nota del lugar donde se guardó el archivo de configuración.

## Configuración de backups

En este punto, puede probar el script de backup para asegurarse de que funcione correctamente. Para ello, ejecute el siguiente comando reemplazando los valores:

```bash
POSTGRES_HOST=<host> POSTGRES_PORT=<port> POSTGRES_DATABASE=<database> POSTGRES_USER=<user> POSTGRES_PASSWORD=<password> BACKUP_DIRECTORY=/path/to/backups S3CMD_CONFIG_FILE=/path/to/.s3cfg S3_BUCKET=<bucket> ./backup.sh
```

### Crear CRON job

Para automatizar los backups, puede crear un CRON job que ejecute el script de backup cada cierto intervalo de tiempo (por ejemplo, cada semana, o cada día).

Abra crontab:

```bash
crontab -e
```

Si es la primera vez, escoja Nano como editor de texto. Después, copie y pegue la siguiente línea al final del archivo:

```bash
0 12 * * 0 POSTGRES_HOST=<host> POSTGRES_PORT=<port> POSTGRES_DATABASE=<database> POSTGRES_USER=<user> POSTGRES_PASSWORD=<password> BACKUP_DIRECTORY=/path/to/pwd/backups S3CMD_CONFIG_FILE=/path/to/.s3cfg S3_BUCKET=<bucket> /path/to/pwd/backup.sh
```

Reemplazando:

- `<host>` por el host de su base de datos
- `<port>` por el puerto de su base de datos
- `<database>` por el nombre de su base de datos
- `<user>` por el usuario de su base de datos
- `<password>` por la contraseña de su base de datos
- `/path/to/pwd` por la salida del comando `pwd` en la carpeta donde se encuentra el script de backup
- `/path/to/.s3cfg` por la ruta al archivo de configuración de s3cmd
- `<bucket>` por el nombre de su bucket

Cambie los primeros 5 datos del CRON para configurar con qué frecuencia se ejecutará el script de backup.

En el ejemplo anterior (`0 12 * * 0`), el script se ejecutará todos los domingos a las 12:00 PM. En [Crontab Guru](https://crontab.guru/) puede encontrar ayuda para configurar el CRON.
