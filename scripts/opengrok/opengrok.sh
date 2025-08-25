#!/bin/bash
OPENGROK_DIR="/home/huang.liang29/workdir/tools/opengrok-1.14.1"
APACHE_TOMCAT_DIR="/home/huang.liang29/workdir/tools/apache-tomcat-10.1.44"
cd $OPENGROK_DIR; rm -rf data; java -jar lib/opengrok.jar -G -S -v -s src -d data --depth 10 -W etc/configuration.xml
sleep 1
$APACHE_TOMCAT_DIR/bin/shutdown.sh
sleep 1
$APACHE_TOMCAT_DIR/kill_tomcat.sh
sleep 1
$APACHE_TOMCAT_DIR/bin/startup.sh
