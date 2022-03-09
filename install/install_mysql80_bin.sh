#!/bin/bash
yum -y install libaio numactl-libs
id -g mysql &> /dev/null || groupadd mysql
id mysql &> /dev/null || useradd -r -g mysql -s /bin/nologin mysql
mkdir -p /data/mysql && chown -R mysql.mysql /data/mysql
[ -f mysql-8.0.27-linux-glibc2.12-x86_64.tar.xz ] || wget https://cdn.mysql.com/archives/mysql-8.0/mysql-8.0.27-linux-glibc2.12-x86_64.tar.xz
tar xf mysql-8.0.27-linux-glibc2.12-x86_64.tar.xz -C /usr/local/
mv /usr/local/mysql-8.0.27-linux-glibc2.12-x86_64 /usr/local/mysql
chown -R mysql.mysql /usr/local/mysql/
echo 'PATH=/usr/local/mysql/bin:$PATH' > /etc/profile.d/mysql.sh
. /etc/profile.d/mysql.sh
cat > /etc/my.cnf <<EOF
[mysqld]
datadir=/data/mysql
skip_name_resolve=1
socket=/data/mysql/mysql.sock
log-error=/data/mysql/mysql.log
pid-file=/data/mysql/mysql.pid
[client] 
socket=/data/mysql/mysql.sock
EOF
/usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --datadir=/data/mysql
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld
service mysqld start
