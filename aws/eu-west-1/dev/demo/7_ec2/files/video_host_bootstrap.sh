#!/bin/bash
yum install -y nginx wget unzip
chkconfig nginx on
service nginx start
mkdir -p /usr/share/nginx/html/videos

wget https://upload.wikimedia.org/wikipedia/commons/0/0f/Fogos_artificiais_-_Fuegos_artificiales_-_Fireworks_-_Santa_Minia_2014_-_Brion_-_Animacion_-_05.gif -O /usr/share/nginx/html/videos/video-1.gif
wget https://upload.wikimedia.org/wikipedia/commons/d/df/Feuerwerks-gif.gif -O /usr/share/nginx/html/videos/video-2.gif
echo '<HTML><HEAD><TITLE>Health Check</TITLE></HEAD><BODY><H1>Hello World</H1></BODY></HTML>' > /usr/share/nginx/html/videos/health_check.html
