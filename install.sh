#!/bin/sh

HOSTNAME=localhost
PORT=80
SITEDIR=doku
USER=www-data

#this is tested 2016-03-18-raspbian-jessie-lite.img
#sudo apt-get update -y && sudo apt-get upgrade -y
#sudo apt-get install git -y
#git clone https://github.com/catonrug/install-dokuwiki-on-raspbian.git && cd install-dokuwiki-on-raspbian && chmod +x install.sh && ./install.sh

#update all repositories and install latest updates
sudo apt-get update -y && apt-get upgrade

#install nginx web server
sudo apt-get install nginx php-fpm php-cli php-mcrypt php-gd php-xml -y

#move to the home directory
cd

#Download dokuwiki from official home page
wget http://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz -O dokuwiki.tgz

#extract archive
tar -xvf dokuwiki.tgz

#set up nginx  
sudo cat > /etc/nginx/sites-available/$SITEDIR << EOF
server {
server_name $HOSTNAME;
listen $PORT;
root /var/www/${DOMAIN}/;
access_log /var/log/nginx/$SITEDIR-access.log;
error_log /var/log/nginx/$SITEDIR-error.log;

index index.php index.html doku.php;
location ~ /(data|conf|bin|inc)/ {
      deny all;
}
location ~ /\.ht {
      deny  all;
}
location ~ \.php {
fastcgi_index index.php;
fastcgi_split_path_info ^(.+\.php)(.*)\$;
include /etc/nginx/fastcgi_params;
fastcgi_pass unix:/var/run/php5-fpm.sock;
fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
}
}
EOF

#make symbolic limk
sudo ln -s /etc/nginx/sites-available/$SITEDIR /etc/nginx/sites-enabled/$SITEDIR

#restart nginx server
sudo /etc/init.d/nginx restart

#make direcotry
sudo mkdir -p /var/www/$SITEDIR

#move to extracted content
sudo cd ~/dokuwiki-*

#copy all content to your domain directory
sudo cp -a . /var/www/$SITEDIR

#let nginx operate with this content
sudo chown -R $USER:$USER /var/www/$SITEDIR
