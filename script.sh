#!/bin/bash

# Actualizar paquetes
sudo apt update

# Instalar Nginx, PHP y MySQL
sudo apt install -y nginx php-fpm php-mysql mysql-server

# Crear directorios necesarios
#sudo mkdir -p /var/www/html/codeigniter/application/cache
#sudo mkdir -p /var/www/html/codeigniter/application/logs

# Habilitar PHP en Nginx
sudo systemctl enable php7.4-fpm

# Descargar CodeIgniter
sudo apt install unzip -y
wget https://github.com/bcit-ci/CodeIgniter/archive/3.1.11.zip
unzip 3.1.11.zip
sudo mv CodeIgniter-3.1.11 /var/www/html/codeigniter

# Configurar permisos
sudo chown -R www-data:www-data /var/www/html/codeigniter
sudo chmod -R 755 /var/www/html/codeigniter/application/cache
sudo chmod -R 755 /var/www/html/codeigniter/application/logs

# Configurar base de datos en CodeIgniter
sudo cp /var/www/html/codeigniter/application/config/database.php /var/www/html/codeigniter/application/config/database.php.bak

sudo sh -c 'cat > /var/www/html/codeigniter/application/config/database.php <<EOF
<?php
defined("BASEPATH") or exit("No direct script access allowed");

\$active_group = "default";
\$query_builder = TRUE;

\$db["default"] = array(
    "dsn"   => "",
    "hostname" => "localhost",
    "username" => "admin",
    "password" => "123456",
    "database" => "dbadmin",
    "dbdriver" => "mysqli",
    "dbprefix" => "",
    "pconnect" => FALSE,
    "db_debug" => (ENVIRONMENT !== "production"),
    "cache_on" => FALSE,
    "cachedir" => "",
    "char_set" => "utf8",
    "dbcollat" => "utf8_general_ci",
    "swap_pre" => "",
    "encrypt" => FALSE,
    "compress" => FALSE,
    "stricton" => FALSE,
    "failover" => array(),
    "save_queries" => TRUE
);

EOF'

# Configurar Nginx
sudo rm /etc/nginx/sites-available/default
sudo sh -c 'echo "
server {
    listen 80;
    listen [::]:80;
    root /var/www/html/codeigniter;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }
}
" > /etc/nginx/sites-available/default'

# Reiniciar servicios
sudo systemctl restart nginx
sudo systemctl restart php7.4-fpm
sudo systemctl restart mysql

echo "La instalación de CodeIgniter con Nginx en Ubuntu se ha completado. Asegúrate de configurar el servidor web correctamente."

