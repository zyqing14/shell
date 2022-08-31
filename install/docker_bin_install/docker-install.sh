#!/bin/bash
DIR=`pwd`
PACKAGE_NAME="docker-20.10.17.tgz"
DOCKER_FILE=${DIR}/${PACKAGE_NAME}

[ -f ${PACKAGE_NAME} ] || wget https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/x86_64/${PACKAGE_NAME}

centos_install_docker(){
  grep "Kernel" /etc/issue &> /dev/null
  if [ $? -eq 0 ];then
    /bin/echo "当前系统是`cat /etc/redhat-release`，即将开始系统初始化、配置docker-compose与安装docker" && sleep 1
    systemctl stop firewalld && systemctl disable firewalld && echo "防火墙已关闭" && sleep 1
    systemctl stop NetworkManager && systemctl disable NetworkManager && echo "NetworkManager已关闭" && sleep 1
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux && setenforce 0 && echo "selinux 已关闭" && sleep 1
#   \cp ${DIR}/limits.conf /etc/security/limits.conf
#   \cp ${DIR}/sysctl.conf /etc/sysctl.conf

    /bin/tar xvf ${DOCKER_FILE}
    \cp docker/* /usr/bin

    \cp containerd.service /lib/systemd/system/containerd.service
    \cp docker.service /lib/systemd/system/docker.service
    \cp docker.socket /lib/systemd/system/docker.socket

#    \cp ${DIR}/docker-compose-Linux-X86_64_1.24.1 /usr/bin/docker-compose

  groupadd docker

  systemctl enable containerd.service && systemctl restart containerd.service
  systemctl enable docker.service && systemctl restart docker.service
  systemctl enable docker.socket && systemctl restart docker.socket

  /bin/echo "docker 安装完成!" && sleep 1

  fi 
}

ubuntu_install_docker(){
  grep "Ubuntu" /etc/issue > /dev/null
  if [ $? -eq 0 ];then
    /bin/echo "当前系统是`cat /etc/issue`，即将开始系统初始化、配置docker-dompose与安装docker" && sleep 1
#    \cp ${DIR}/limits.conf /etc/security/limits.conf
#    \cp ${DIR}/sysctl.conf /etc/sysctl.conf

    /bin/tar xvf ${DOCKER_FILE}
    \cp docker/* /usr/bin

    \cp containerd.service /lib/systemd/system/containerd.service
    \cp docker.service /lib/systemd/system/docker.service
    \cp docker.socket /lib/systemd/system/docker.socket

#    \cp ${DIR}/docker-compose-Linux-x86_64_1.24.1 /usr/bin/docker-compose
#    ulimit -n 1000000

    groupadd docker

    systemctl enable containerd.service && systemctl restart containerd.service
    systemctl enable docker.service && systemctl restart docker.service
    systemctl enable docker.socket && systemctl restart docker.socket
  
     /bin/echo "安装完成!" && sleep 1
fi
}

main(){
  centos_install_docker
  ubuntu_install_docker
}

main
