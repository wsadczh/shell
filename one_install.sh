#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# if["$(uname)"=="Darwin"];
# then
# # Mac OS X 操作系统
#     elif["$(expr substr $(uname -s) 1 5)"=="Linux"];then
# # GNU/Linux操作系统
#     elif["$(expr substr $(uname -s) 1 10)"=="MINGW32_NT"];then
# # Windows NT操作系统
# fi

# 设置字体颜色函数
function blue() {
    echo -e "\033[34m\033[01m $1 \033[0m"
}
function green() {
    echo -e "\033[32m\033[01m $1 \033[0m"
}
function greenbg() {
    echo -e "\033[43;42m\033[01m $1 \033[0m"
}
function red() {
    echo -e "\033[31m\033[01m $1 \033[0m"
}
function redbg() {
    echo -e "\033[37;41m\033[01m $1 \033[0m"
}
function yellow() {
    echo -e "\033[33m\033[01m $1 \033[0m"
}
function white() {
    echo -e "\033[37m\033[01m $1 \033[0m"
}

#工具安装
install_pack() {
    pack_name="基础工具"
    echo "===> Start to install curl"
    if [ -x "$(command -v yum)" ]; then
        command -v curl >/dev/null || yum install -y curl
    elif [ -x "$(command -v apt)" ]; then
        command -v curl >/dev/null || apt install -y curl
    else
        echo "Package manager is not support this OS. Only support to use yum/apt."
        exit -1
    fi
}

# docker 安装
# curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun

# docker-compose 安装
# curl -L https://get.daocloud.io/docker/compose/releases/download/v2.4.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose
# sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
install_docker() {
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
}

install_docker—compose() {
    curl -L https://get.daocloud.io/docker/compose/releases/download/v2.4.1/docker-compose-$(uname -s)-$(uname -m) >/usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
}

install_wordpress() {
    read -p "请输入uuid(字符串):" uuid
    echo ${uuid}
    read -p "请输入db_password:" db_password
    echo ${db_password}
    read -p "请输入db_port(3400及以上):" db_port
    echo ${db_port}
    read -p "请输入wordpress_port(9000及以上):" wordpress_port
    echo ${wordpress_port}
    echo "start"
    # uuid=one
    # db_password=123456
    # db_port=3401
    # wordpress_port=9000
    filename="wordpress.yml"
    cat >$filename <<EOF
version: "3"
services:
    db_$uuid:
        image: mysql:5.7
        command:
        - --default_authentication_plugin=mysql_native_password
        - --character-set-server=utf8mb4
        - --collation-server=utf8mb4_unicode_ci
        ports:
        - $db_port:3306
        volumes:
        - db_data_$uuid:/var/lib/mysql
        restart: always
        environment:
        MYSQL_ROOT_PASSWORD: $db_password
        MYSQL_DATABASE: wordpress
        MYSQL_USER: wordpress
        MYSQL_PASSWORD: $db_password
        WORDPRESS_WPLANG: zh-CN
    wordpress_$uuid:
        depends_on:
        - db_$uuid
        # image: wordpress:latest
        image: wordpress:php7.4-apache
        ports:
        - $wordpress_port:80
        restart: always
        volumes:
        - wordpress_data_$uuid:/var/www/html/wp-content
        environment:
        WORDPRESS_DB_HOST: db_$uuid:3306
        WORDPRESS_DB_USER: wordpress
        WORDPRESS_DB_PASSWORD: $db_password
volumes:
    db_data_$uuid:
    wordpress_data_$uuid:
EOF
    echo "启动命令"
    echo "docker-compose -f $filename up -d"
    echo "销毁命令"
    echo "docker-compose -f $filename down"
    echo "end"
}

bak_sql() {
    container_name=wordpress_one_db_one_1
    read -p "请输入密码:" db_password
    echo ${db_password}
    echo "start"
    docker exec -it $container_name mysqldump -uroot -p"${db_password}" wordpress >bak.sql
    echo "end"
}

resume_sql() {
    container_name=wordpress_one_db_two_1
    read -p "请输入密码:" db_password
    echo ${db_password}
    echo "start"
    docker exec -i $container_name mysql -uroot -p"${password}" <bak.sql
    echo "end"
}

install_forsaken-mail() {
    install_docker
    docker run --name forsaken-mail -d -p 25:25 -p 3000:3000 denghongcai/forsaken-mail
    echo "使用前请参考文章：https://baiyue.one/archives/416.html"
}

#开始菜单
start_menu() {
    clear
    greenbg "==============================================================="
    greenbg "简介：快捷安装脚本                "
    greenbg "==============================================================="
    echo
    white "—————————————基础环境——————————————"
    white "101.安装docker"
    white "102.安装docker-compose"
    white "103.安装docker和docker-compose"
    white "—————————————博客类程序——————————————"
    white "201.安装wordpress"
    white "202.备份sql和wordpress"
    white "203.恢复sql和wordpress"
    white "—————————————杂项——————————————"
    white "701.安装临时邮箱"
    white "702.安装Meedu付费视频"
    white "703.安装全网VIP视频解析"
    white ""
    echo
    echo
    read -p "请输入数字:" num
    case "$num" in
    101)
        install_docker
        ;;
    102)
        install_docker—compose
        ;;
    103)
        install_docker
        install_docker—compose
        ;;
    201)
        install_wordpress
        ;;
    202)
        bak_sql
        ;;
    203)
        resume_sql
        ;;
    701)
        install_forsaken-mail
        ;;
    0)
        exit 1
        ;;
    *)
        clear
        echo "请输入正确数字"
        sleep 3s
        start_menu
        ;;
    esac
}

start_menu
