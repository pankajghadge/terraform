#!/bin/bash
yum install -y nginx wget
chkconfig nginx on
service nginx start
mkdir -p /usr/share/nginx/html/images
wget https://images.pexels.com/photos/1251293/pexels-photo-1251293.jpeg -O /usr/share/nginx/html/images/photo-1.jpeg
wget https://images.pexels.com/photos/1139556/pexels-photo-1139556.jpeg -O /usr/share/nginx/html/images/photo-2.jpeg
echo '<HTML><HEAD><TITLE>Health Check</TITLE></HEAD><BODY><H1>Hello World</H1></BODY></HTML>' > /usr/share/nginx/html/images/health_check.html
