#!/bin/bash
yum install -y nginx
chkconfig nginx on
service nginx start
