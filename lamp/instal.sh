#!/bin/bash
# Version: 1.0.0# Version: 1.0.0
# Author: Mr_miao
# Date: 2016/9/2
# Description: LANMP Install Script
lamp_path=$(cd `dirname $0`;pwd)
cd $lamp_path/tools
# gcc - cloog-ppl 依赖
rpm -ivh ppl-0.10.2-11.el6.i686.rpm
rpm -ivh cloog-ppl-0.15.7-1.2.el6.i686.rpm

# gcc - cpp  依赖
rpm -ivh mpfr-2.4.1-6.el6.i686.rpm
rpm -ivh cpp-4.4.7-3.el6.i686.rpm


# gcc - glibc-devel  依赖
rpm -ivh kernel-headers-2.6.32-358.el6.i686.rpm
rpm -ivh glibc-headers-2.12-1.107.el6.i686.rpm
rpm -ivh glibc-devel-2.12-1.107.el6.i686.rpm

# gcc 安装
rpm -ivh gcc-4.4.7-3.el6.i686.rpm

#gcc-c++安装
rpm -ivh libstdc++-devel-4.4.7-3.el6.i686.rpm
rpm -ivh gcc-c++-4.4.7-3.el6.i686.rpm
echo"
    # ---------------------------------------
                     __               
              _____ |__|____    ____  
             /     \|  \__  \  /  _ \ 
            |  Y Y  \  |/ __ \(  <_> )
            |__|_|  /__(____  /\____/ 
                  \/        \/      

    	congratulate gcc install complated!
		next install MySQL
		 Author: Mr_miao 
    # ---------------------------------------
"
sleep 2
#添加防火墙例外
sed '/22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT' -i /etc/sysconfig/iptables
sed '/80/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT' -i /etc/sysconfig/iptables
sed '/3306/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT' -i /etc/sysconfig/iptables
service iptables restart 
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config  
/usr/sbin/setenforce 0

#install MySQL
#创建目录
mkdir -p /ml/wwwroot
mkdir -p /ml/server/php
mkdir -p /ml/server/mysql
mkdir -p /ml/server/apache
mkdir -p /ml/server/data
mkdir -p /ml/server/log/install

#卸载已经安装apache 、mysql、php
rpm -e httpd-tools-2.2.15-26.el6.centos.i686 --nodeps
rpm -e httpd-2.2.15-26.el6.centos.i686 --nodeps

#安装cmake
cd $lamp_path/tools
tar zxvf cmake-2.8.5.tar.gz
cd cmake-2.8.5
./bootstrap
make && make install

#安装bison依赖
cd $lamp_path/tools
tar -zxvf bison-2.7.tar.gz
cd bison-2.7
./configure && make && make install

#安装ncurses-devel依赖
cd $lamp_path/tools
rpm -ivh ncurses-devel-5.7-3.20090208.el6.i686.rpm

#编译安装MySQL
cd $lamp_path/tools
tar zxvf mysql-5.5.17.tar.gz
cd mysql-5.5.17
cmake \
-DCMAKE_INSTALL_PREFIX=/ml/server/mysql \
-DMYSQL_DATADIR=/ml/server/data \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci
make && make install
cd $lamp_path/mysql-5.5.17
\cp -f support-files/my-medium.cnf /etc/my.cnf
sed '/myisam_/a datadir=/ml/server/data' -i  /etc/my.cnf
groupadd mysql
useradd -g mysql -s /sbin/nologin mysql
chown -R mysql:mysql /ml/server/data/
chown -R mysql:mysql /ml/server/mysql/
/ml/server/mysql/scripts/mysql_install_db \
--basedir=/ml/server/mysql \
--datadir=/ml/server/data \
--user=mysql
chown -R root /ml/server/mysql
\cp -f /ml/server/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld
service mysqld start
/ml/server/mysql/bin/mysqladmin -u root password 'admin'
/ml/server/mysql/bin/mysql -uroot -padmin <<EOF
drop database test;
delete from mysql.user where user='';
update mysql.user set password=password('admin') where user='root';
delete from mysql.user where not (user='root') ;
flush privileges;
exit
EOF

echo"
    # -----------------------------------------
                     __               
              _____ |__|____    ____  
             /     \|  \__  \  /  _ \ 
            |  Y Y  \  |/ __ \(  <_> )
            |__|_|  /__(____  /\____/ 
                  \/        \/      

       Congratulations!MySQL install completed
		next install Apache	
	user:root         password:admin 
		Author: Mr_miao
    # -----------------------------------------
"

sleep 3

#install Apache
#安装zlib压缩库
cd $lamp_path/tools
tar -zxvf zlib-1.2.5.tar.gz
cd zlib-1.2.5
./configure
make && make install

#安装apache
cd $lamp_path/tools
tar  -jxvf  httpd-2.2.19.tar.bz2
cd httpd-2.2.19
./configure --prefix=/ml/server/apache \
--enable-modules=all \
--enable-mods-shared=all \
--enable-so
make && make install

sed -i 's/#ServerName www.example.com:80/ServerName localhost:80/g' /ml/server/apache/conf/httpd.conf
sed '/Include conf/extra/httpd-vhosts.conf/a Include conf.d/*.conf' -i  /ml/server/apache/conf/httpd.conf

#将httpd加入系统服务
\cp -f /ml/server/apache/bin/apachectl /etc/init.d/httpd
sed -i "2s/#/#chkconfig: 2345 10 90/" /etc/init.d/httpd
sed '/#chkconfig: 2345 10 90/a #description: Activates/Deactivates Apache Web Server' -i /etc/init.d/httpd
chmod 755 /etc/init.d/httpd
chkconfig --add httpd
chkconfig --level 345 httpd on

echo"
    # -----------------------------------------
                     __               
              _____ |__|____    ____  
             /     \|  \__  \  /  _ \ 
            |  Y Y  \  |/ __ \(  <_> )
            |__|_|  /__(____  /\____/ 
                  \/        \/      

       Congratulations!Apache install completed
		next install PHP 5.3	
		  Author: Mr_miao
    # -----------------------------------------
"
sleep 3

#安装libxml2
cd $lamp_path/tools
tar zxvf libxml2-2.7.2.tar.gz
cd libxml2-2.7.2
./configure --prefix=/ml/server/libxml2  \
--without-zlib
make && make install

#安装jpeg8
cd $lamp_path/tools
tar -zxvf jpegsrc.v8b.tar.gz
cd jpeg-8b
./configure --prefix=/ml/server/jpeg \
--enable-shared --enable-static
make && make install

#安装libpng
cd $lamp_path/tools
tar zxvf libpng-1.4.3.tar.gz
cd libpng-1.4.3
./configure
make && make install

#安装freetype
cd $lamp_path/tools
tar zxvf freetype-2.4.1.tar.gz
cd freetype-2.4.1
./configure --prefix=/ml/server/freetype
make && make install

#安装GD库
cd $lamp_path/tools
tar -zvxf gd-2.0.35.tar.gz
mkdir -p /ml/server/gd
cd gd-2.0.35
./configure --prefix=/ml/server/gd  \
--with-jpeg=/ml/server/jpeg/ 	\
--with-png --with-zlib \
--with-freetype=/ml/server/freetype
make && make install

#安装 php5
cd $lamp_path/tools
tar -jxvf php-5.3.6.tar.bz2
cd php-5.3.6
./configure --prefix=/ml/server/php \
--with-apxs2=/ml/server/apache/bin/apxs \
--with-mysql=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-freetype-dir=/ml/server/freetype \
--with-gd=/ml/server/gd \
--with-zlib --with-libxml-dir=/ml/server/libxml2 \
--with-jpeg-dir=/ml/server/jpeg \
--with-png-dir \
--enable-mbstring=all \
--enable-mbregex \
--enable-shared
make && make install
\cp -f php.ini-development /ml/server/php/lib/php.ini

#配置PHP
sed -i "s/disable_functions =/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,escapeshellcmd,escapeshellarg,shell_exec,proc_get_status,ini_alter,ini_alter,ini_restore,dl,pfsockopen,openlog,syslog,readlink,symlink,leak,popepassthru,stream_socket_server,popen/" /ml/server/php/lib/php.ini
sed '/;date.time/a date.timezone=PRC' -i  /ml/server/php/lib/php.ini
sed -i 's/expose_php = On/expose_php = Off/g' /ml/server/php/lib/php.ini
sed -i 's/;extension=php_mysql.dll/extension=php_mysql.dll/g' /ml/server/php/lib/php.ini
sed -i 's/;extension=php_mysqli.dll/extension=php_mysqli.dll/g' /ml/server/php/lib/php.ini
echo '<?php echo phpinfo();?>' > /ml/server/apache/htdocs/index.php

#配置httpd

mkdir -p /ml/server/apache/conf.d/
#sed -i "s/ServerTokens OS/ServerTokens ProductOnly/" /etc/httpd/conf/httpd.conf
#sed -i "s/ServerSignature On/ServerSignature Off/" /etc/httpd/conf/httpd.conf
echo "Include conf.d/*.conf" >> /ml/server/apache/conf/httpd.conf
sed -i "s/Deny from all/Allow from all/" /ml/server/apache/conf/httpd.conf 
sed -i "s/AllowOverride None/AllowOverride All/" /ml/server/apache/conf/httpd.conf
sed '/libphp5.so/a AddType application/x-httpd-php .php .asp .aspx' -i  /ml/server/apache/conf/httpd.conf
sed '/x-httpd-php/a PHPIniDir /ml/server/php/lib/php.ini' -i  /ml/server/apache/conf/httpd.conf
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/g' /ml/server/apache/conf/httpd.conf
clear
echo "
    # -----------------------------------------
                     __               
              _____ |__|____    ____  
             /     \|  \__  \  /  _ \ 
            |  Y Y  \  |/ __ \(  <_> )
            |__|_|  /__(____  /\____/ 
                  \/        \/      

       Congratulations! LAMP install completed!
	
		  Author: Mr_miao
    # -----------------------------------------
"
service httpd start
sleep 3 
