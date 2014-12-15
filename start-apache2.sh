#!/bin/bash
source /etc/apache2/envvars
exec apache2 -X -D FOREGROUND
