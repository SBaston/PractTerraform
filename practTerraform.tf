terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

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


