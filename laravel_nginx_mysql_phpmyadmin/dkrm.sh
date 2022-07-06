#!/bin/bash

### Editable Vars
# PROJECT
PROJECT_NAME='test'

# DIRS
PROJECT_SRC='src'
PROJECT_MYSQL="mysql"
PROJECT_NGINX="nginx"
PROJECT_PHPMYADMIN="phpmyadmin"

# PORTS
CONTAINER_PORT_NGINX='5000'
CONTAINER_PORT_PHPMYADMIN='5001'
CONTAINER_PORT_PHP='9000'
CONTAINER_PORT_DB='5003'

# PASSWORDS
CONTAINER_DB_PASSWORD='p4s5w0rd'

### Editable Vars no recomended to change
# CONTAINER NAMES
IMAGE_PHP_NAME=$PROJECT_NAME"_img_php"

CONTAINER_NAME_PHP=$PROJECT_NAME"_run_app"
#CONTAINER_NAME_PHP="php"
CONTAINER_NAME_DB=$PROJECT_NAME"_run_db"
CONTAINER_NAME_NGINX=$PROJECT_NAME"_run_nginx"
CONTAINER_NAME_PHPMYADMIN=$PROJECT_NAME"_run_phpmyadmin"

NETWORK_NAME=$PROJECT_NAME"_net"

# Get container command
DOKCERCOMMAND=''

### NO TOUCH
BOLD="\033[1m"
UNDERLINE="\033[4m"
BLINK="\033[5m"
NEGATIVE="\033[7m"
NORMAL="\033[22m"
TRACED="\033[9m"

RESET="\033[0m"

RED="160m"
YELLOW="220m"
GREEN="048m"
WHITE="015m"
PURLPLE="061m"
BLUE="027m"
ORANGE="202m"
FUCSIA="200m"
GRAY240="240m"
GRAY242="242m"
GRAY244="244m"

FOREGROUND="\033[38;5;"
BACKGROUND="\033[48;5;"


# Get container command
if command -v podman >/dev/null; then
    DOKCERCOMMAND='podman'
    elif command -v docker > /dev/null ; then
    DOKCERCOMMAND='docker'
else
    echo "No docker or podman found"
    exit 1
fi

### Functions

# Netwrok
function _run_network () {
    RESLT=$($DOKCERCOMMAND network ls --format "{{.Name}}" | grep $NETWORK_NAME)
    if [ -z "$RESLT" ]; then
        $DOKCERCOMMAND network create $NETWORK_NAME > /dev/null
        echo -e "Network $BOLD$NETWORK_NAME$NORMAL $NORMAL$UNDERLINE$FOREGROUND$GREEN[DONE]$RESET"
    else
        echo -e "Network $BOLD $NETWORK_NAME  $NORMAL$UNDERLINE$FOREGROUND$PURLPLE[AE]$RESET"
    fi
}

function _del_network(){
    RESLT=$($DOKCERCOMMAND network ls --format "{{.Name}}" | grep $NETWORK_NAME)
    if [ -n "$RESLT" ]; then
        $DOKCERCOMMAND network rm $NETWORK_NAME > /dev/null
        echo -e "Network $BOLD$NETWORK_NAME$NORMAL $NORMAL$UNDERLINE$FOREGROUND$YELLOW[REM]$RESET"
    else
        echo -e "Network $BOLD $NETWORK_NAME  $NORMAL$UNDERLINE$FOREGROUND$PURLPLE[AREM]$RESET"
    fi
}

# CONTAINERS
function _run_container {
    CONTAINER_NAME=$1
    CONTAINER_PARAMS=$2
    
    RESLT=$($DOKCERCOMMAND ps --format "{{.Names}}" | grep $CONTAINER_NAME)
    if [ -z "$RESLT" ]; then
        RESLT=$($DOKCERCOMMAND ps -a --format "{{.Names}}" | grep $CONTAINER_NAME)
        if [ -z "$RESLT" ]; then
            $DOKCERCOMMAND run --name $CONTAINER_NAME $CONTAINER_PARAMS
            RESLT=$($DOKCERCOMMAND ps --format "{{.Names}}" | grep $CONTAINER_NAME)
            if [ -z "$RESLT" ]; then
                echo -e "|> Container:\n$BOLD$CONTAINER_NAME$RESET\n-> $BOLD$FOREGROUND$RED[Aborted]$RESET :C"
            else
                echo -e "|> Container:\n$BOLD$CONTAINER_NAME$RESET\n-> $BOLD$FOREGROUND$GREEN[Running]$RESET :)"
            fi
        else
            echo -e "|> Container:\n$BOLD$CONTAINER_NAME$RESET\n-> $BOLD$FOREGROUND$RED[Fail]$RESET :|$FOREGROUND$ORANGE Can't run stopped container$RESET"
            echo -e $FOREGROUND$GRAY242"Try:\n[STOP],[DEL] and [RUN] to rerun container\n[RESTART] to restart container"
        fi
    else
        echo -e "|> Container:\n$BOLD$CONTAINER_NAME$RESET\n-> $BOLD$FOREGROUND$PURLPLE[Already Running]$RESET :v"
    fi
}

function _stop_container {
    CONTAINER_NAME=$1
    
    RESLT=$($DOKCERCOMMAND ps --format "{{.Names}}" | grep $CONTAINER_NAME)
    if [ -n "$RESLT" ]; then
        RESLT=$($DOKCERCOMMAND ps -a --format "{{.Names}}" | grep $CONTAINER_NAME)
        if [ -n "$RESLT" ]; then
            $DOKCERCOMMAND stop $CONTAINER_NAME > /dev/null
            echo -e "|> Container:\n$BOLD$CONTAINER_NAME$RESET\n-> $BOLD$FOREGROUND$GREEN[Done]$FOREGROUND$YELLOW[Stoped]$RESET :)"
        else
            echo -e "|> Container:\n$BOLD$CONTAINER_NAME$RESET\n-> $BOLD$FOREGROUND$RED[FAIL]$RESET :|$FOREGROUND$ORANGE Can't stop stopped container$RESET"
        fi
    else
        echo -e "|> Container:\n$BOLD$CONTAINER_NAME$RESET\n-> $BOLD$FOREGROUND$PURLPLE[Not Running]$RESET :|$FOREGROUND$ORANGE Can't stop not running container$RESET"
    fi
}

function _del_container {
    CONTAINER_NAME=$1
    
    RESLT=$($DOKCERCOMMAND ps -a --format "{{.Names}}" | grep $CONTAINER_NAME)
    if [ -n "$RESLT" ]; then
        RESLT=$($DOKCERCOMMAND ps --format "{{.Names}}" | grep $CONTAINER_NAME)
        if [ -z "$RESLT" ]; then
            $DOKCERCOMMAND rm $CONTAINER_NAME > /dev/null
            echo -e "|> Container:\n$BOLD$CONTAINER_NAME$RESET\n-> $BOLD$FOREGROUND$GREEN[Done]$FOREGROUND$YELLOW[Deleted]$RESET :)"
        else
            echo -e "|> Container:\n$BOLD$CONTAINER_NAME$RESET\n-> $BOLD$FOREGROUND$RED[FAIL]$RESET :|$FOREGROUND$ORANGE Can't delete running container$RESET"
        fi
    else
        echo -e "|> Container:\n$BOLD$CONTAINER_NAME$RESET\n-> $BOLD$FOREGROUND$PURLPLE[Not Exist]$RESET :|$FOREGROUND$ORANGE Can't delete not existing container$RESET"
    fi
}

function _start_container {
    
    CONTAINER_NAME=$1
    RESLT=$($DOKCERCOMMAND ps -a --format "{{.Names}}" | grep $CONTAINER_NAME)
    if [ -n "$RESLT" ]; then
        RESLT=$($DOKCERCOMMAND ps  --format "{{.Names}}" | grep $CONTAINER_NAME)
        if [ -z "$RESLT" ]; then
            $DOKCERCOMMAND start $CONTAINER_NAME > /dev/null
            echo -e "|> Container:\n$BOLD$CONTAINER_NAME$RESET\n-> $BOLD$FOREGROUND$GREEN[Done]$FOREGROUND$YELLOW[Started]$RESET :)"
        else
            echo -e "|> Container:\n$BOLD$CONTAINER_NAME$RESET\n-> $BOLD$FOREGROUND$RED[FAIL]$RESET :|$FOREGROUND$ORANGE Can't start running container$RESET"
        fi
    else
        echo -e "|> Container:\n$BOLD$CONTAINER_NAME$RESET\n-> $BOLD$FOREGROUND$PURLPLE[Not Exist Container]$RESET :v"
    fi
}

# NGINX
function _run_nginx {
    echo -n '
# configuracion del servidor de nginx
server {
    listen 80; # puerto del container
    index index.php index.html; # busca interpretar archivos de este tpo
    server_name localhost; # usa el localhost
    error_log /var/log/nginx/error.log; # registros de errores
    access_log /var/log/nginx/access.log; # registros de acceso
    root /var/www/html/public; # usara esta ruta como la root

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # a partir de aqui todo es muy confuso 😹
    location ~ \.php$ {
        try_files $uri =404; # por defecto regresa el 404
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass '$CONTAINER_NAME_PHP':'$CONTAINER_PORT_PHP'; # puerto al que se conectara para obtener sus archivos
        fastcgi_index index.php; # el archivo raiz por default
        include fastcgi_params;
        #fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

}
    ' > $(pwd)/$PROJECT_NGINX/nginx.conf && \
    _run_container $CONTAINER_NAME_NGINX \
    "-d \
        -p $CONTAINER_PORT_NGINX:80 \
        -v $(pwd)/$PROJECT_NGINX/error.log:/var/log/nginx/error.log:z \
        -v $(pwd)/$PROJECT_NGINX/access.log:/var/log/nginx/access.log:z \
        -v $(pwd)/$PROJECT_SRC:/var/www/html:z \
        -v $(pwd)/$PROJECT_NGINX/nginx.conf:/etc/nginx/conf.d/default.conf:z \
        --network $NETWORK_NAME \
    nginx"
    
}

# PHP
function _build_php {
    echo -n '
FROM php:7.4.30-fpm-alpine3.16

COPY '$PROJECT_SRC' /var/www/html
WORKDIR /var/www/html

#  install dependencies
# imagemagick

RUN apk update && \
apk upgrade && \
apk add imagemagick && \
apk add imagemagick-dev && \
apk add autoconf &&  \
apk add automake && \
apk add cmake && \
apk add make && \
apk add gcc && \
apk add g++

RUN pecl install imagick
RUN docker-php-ext-enable imagick
# # enable mysql
RUN docker-php-ext-install pdo pdo_mysql mysqli;
#Conposer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# da permisos para editar los archivos en esta ruta del container
RUN chown -R www-data:www-data /var/www
RUN chmod 755 /var/www

# Permisos en el proyecto de elaravel
RUN chown -R $USER:www-data /var/www/html/storage
RUN chown -R $USER:www-data /var/www/html/bootstrap/cache
    ' >  $(pwd)/Dockerfile && \
    $DOKCERCOMMAND build -t $IMAGE_PHP_NAME .
}

function _run_php {
    _run_container \
    $CONTAINER_NAME_PHP \
    "-d \
    -v $(pwd)/$PROJECT_SRC:/var/www/html:z \
    --network $NETWORK_NAME \
    $IMAGE_PHP_NAME"
}

function _input_cae {
    
    case $1 in
        # NETWORK
        network|net|n)
            _run_network
        ;;
        delnetwork|dlntwk|dn)
            _del_network
        ;;
        networkls|netls|nls|nl)
            $DOKCERCOMMAND network ls
        ;;
        
        # PHP
        buildphp|bphp)
            _build_php
        ;;
        runphp|rnphp|rphp|php)
            _run_php
        ;;
        stopphp|spphp)
            _stop_container $CONTAINER_NAME_PHP
        ;;
        delphp|dlphp|rmphp)
            _del_container $CONTAINER_NAME_PHP
        ;;
        startphp|stphp)
            _start_container $CONTAINER_NAME_PHP
        ;;
        restartphp|rstphp|rtphp)
            _stop_container $CONTAINER_NAME_PHP
            _start_container $CONTAINER_NAME_PHP
        ;;
        rerunphp|rrphp|rebootphp|rbtphp)
            _stop_container $CONTAINER_NAME_PHP
            _del_container $CONTAINER_NAME_PHP
            _run_php
        ;;
        itphp)
            $DOKCERCOMMAND exec -it $CONTAINER_NAME_PHP sh
        ;;
        
        # NGINX
        runnginx|nginx|rnng|rng)
            _run_nginx
        ;;
        stopnginx|spng)
            _stop_container $CONTAINER_NAME_NGINX
        ;;
        startnginx|stng)
            _start_container $CONTAINER_NAME_NGINX
        ;;
        deleteng|delng|dng|rmng)
            _del_container $CONTAINER_NAME_NGINX
        ;;
        restartng|rstng|rtng)
            _stop_container $CONTAINER_NAME_NGINX
            _start_container $CONTAINER_NAME_NGINX
        ;;
        resetng|rebootng|rbtng)
            _stop_container $CONTAINER_NAME_NGINX
            _del_container $CONTAINER_NAME_NGINX
            _run_nginx
        ;;
        itng)
            $DOKCERCOMMAND exec -it $CONTAINER_NAME_NGINX sh
        ;;
        # buildphp|bphp|bph)
        #     $DOKCERCOMMAND build -t $IMAGE_PHP_NAME .
        # ;;
        # php)
        #     _run_container $CONTAINER_NAME_PHP \
        #     "-d \
        #         -p $CONTAINER_PORT_PHP:80 \
        #         -v $(pwd)/$PROJECT_SRC:/var/www/html \
        #         --privileged --security-opt label=disable \
        #         --network $NETWORK_NAME \
        #     $IMAGE_PHP_NAME"
        # ;;
        
        ps)
            $DOKCERCOMMAND ps -a --format "table {{.ID}} {{.State}} {{.Names}} {{.Ports}}"
        ;;
        
        *)
            echo -e "|> $BOLD$FOREGROUND$RED[ERROR]$RESET :|$FOREGROUND$ORANGE No se reconoce el comando $1$RESET"
        ;;
    esac
}

for command in "$@"
do
    echo -e "$FOREGROUND$FUCSIA"
    echo -e "$ $command "
    echo -e "$RESET"
    _input_cae $command
done