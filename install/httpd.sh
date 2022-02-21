#!/bin/bash
APR_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/apr/
APR_FILE=apr-1.7.0
TAR=.tar.bz2
APR_UTIL_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/apr/
APR_UTIL_FILE=apr-util-1.6.1
HTTPD_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/httpd/
HTTPD_FILE=httpd-2.4.52
INSTALL_DIR=/user/local/httpd24
CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`
MPM=event

install_httpd(){
if [ `awk -F'"' '/^ID=/{print $2}' /etc/os-release` == "centos" ] &> /dev/null;then
  yum -y install gcc make pcre-devel openssl-devel expat-devel wget bzip2
else
  apt update
  apt -y install gcc make libapr1-dev libaprutil1-dev libpcre3 libpcre3-dev libssl-dev wget
fi
cd /usr/local/src
wget $APR_URL$APR_FILE$TAR && wget $APR_UTIL_URL$APR_UTIL_FILE$TAR && wget $HTTPD_URL$HTTPD_FILE$TAR
tar xf $APR_FILE$TAR && tar xf $APR_UTIL_FILE$TAR && tar xf $HTTPD_FILE$TAR
mv $APR_FILE $HTTPD_FILE/srclib/apr
mv $APR_UTIL_FILE $HTTPD_FILE/srclib/apr-util
cd $HTTPD_FILE
./configure --prefix=$INSTALL_DIR --enable-so --enable-ssl --enable-cgi --enable-rewrite --with-zlib --with-pcre --with-included-apr --enable-modules=most --enable-mpms-shared=all --with-mpm=$MPM
make -j $CPUS && make install
useradd -s /sbin/nologin -r apache
sed -i 's/daemon/apache/' $INSTALL_DIR/conf/httpd.conf
echo "PATH=$INSTALL_DIR/bin:$PATH" > /etc/profile.d/http24.sh
. /etc/profile.d/http24.sh
cat > /lib/systemd/system/httpd.service <<EOF
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)
[Service] 
Type=forking
ExecStart=${INSTALL_DIR}/bin/apachectl start
ExecReload=${INSTALL_DIR}/bin/apachectl graceful
ExecStop=${INSTALL_DIR}/bin/apachectl stop
KillSignal=SIGCONT
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now httpd
}

install_httpd
