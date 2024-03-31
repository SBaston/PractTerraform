# Terraform #
# Enunciado #
1. Crea una infraestructura Docker personalizada utilizando Terraform.
2. La infraestructura debe contener un contenedor con una aplicación Wordpress y otro
contenedor con una base de datos MariaDB.
3. Deben estar conectados a una red Docker.
4. Debe existir un volumen para almacenar los datos de la base de datos y que no se
eliminen al destruir la infraestructura.
5. Deben usarse variables de entorno para configurar la aplicación Wordpress.
6. Debe existir un archivo de configuración variables.tf con las variables de entorno.

# Descripción del código #
# Fichero practTerraform.tf #
```
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}
```
Se define la configuración de Terraform especificando el proveedor de Docker que se utilizará. En este caso las versiones que sean 3.0.1 o superiores.

```
provider "docker" {}
```
Se especifica la configuración del proveedor Docker.

resource "docker_image" "wordpress" {
  name         = "wordpress:latest"
  keep_locally = false
}

resource "docker_image" "mariadb" {
  name         = "mariadb:latest"
  keep_locally = false
}

resource "docker_volume" "volumePract" {
  name = "volumePract"
}

resource "docker_network" "redDocker" {
  name = "redDocker"
}

resource "docker_container" "wordpress" {
  image = docker_image.wordpress.image_id
  name  = var.container_name
  ports {
    internal = 80
    external = 8001
  }

  depends_on = [docker_container.mariadb]

  env = [
    "WORDPRESS_DB_HOST  = mariadb",
    "WORDPRESS_DB_NAME  = wordpress",
    "WORDPRESS_DB_USER  = root",
    "WORDPRESS_DB_PASSWORD  = example"
  ]

  networks_advanced {
    name = docker_network.redDocker.name
  }

  volumes {
    volume_name    = docker_volume.volumePract.name
    container_path = "/var/www/html/wp-content"
  }
}

resource "docker_container" "mariadb" {
  image = docker_image.mariadb.image_id
  name  = "mariadb"

  env = [
    "MYSQL_DATABASE = wordpress",
    "MYSQL_USER = root",
    "MYSQL_PASSWORD = example",
    "MYSQL_ROOT_PASSWORD = root"
  ]

  networks_advanced {
    name = docker_network.redDocker.name
  }

  volumes {
    volume_name    = docker_volume.volumePract.name
    container_path = "/var/lib/mysql"
  }
}
```
# Fichero variables.tf #
```
variable "container_name" {
  description = "Value of the name for the Docker container"
  type        = string
  default     = "WordPressContainer"
}
```

