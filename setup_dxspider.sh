#!/bin/bash
# Script for Installation and configuration DxSpider Cluster  
# Create By Yiannis Panagou, SV5FRI
# http://www.sv5fri.eu
# E-mail:sv5fri@gmail.com
# Version 0.7 - Last Modify 11/06/2018
#
#==============================================
# Function Check Distribution and Version
check_distro() {

        arch=$(uname -m)
        kernel=$(uname -r)
        if [ -n "$(command -v lsb_release)" ]; then
                distroname=$(lsb_release -s -d)
        elif [ -f "/etc/os-release" ]; then
                distroname=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="')
        elif [ -f "/etc/debian_version" ]; then
                distroname="Debian $(cat /etc/debian_version)"
        elif [ -f "/etc/redhat-release" ]; then
                distroname=$(cat /etc/redhat-release)
        else
                distroname="$(uname -s) $(uname -r)"
        fi

        echo "${distroname}"

        if [ "${distroname}" == "CentOS Linux 7 (Core)" ]; then
                install_epel_7
                install_package_CentOS_7
		elif [ "${distroname}" == "Raspbian GNU/Linux 7 (wheezy)" ]; then
				install_package_debian
        elif [ "${distroname}" == "Raspbian GNU/Linux 8 (jessie)" ]; then
				install_package_debian
		elif [ "${distroname}" == "Raspbian GNU/Linux 9 (stretch)" ]; then
				install_package_debian
		elif [ "${distroname}" == "Debian GNU/Linux 9 (stretch)" ]; then
				install_package_debian
		else
        exit 1
        fi
}
#
install_epel_7() {
#Install epel repository
## RHEL/CentOS 7 64-Bit ##
# wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# rpm -ivh epel-release-latest-7.noarch.rpm
# Update the system
yum check-update
# Install the additional package repository EPEL
yum -y install epel-release
}
#
#
#install_epel_6_32b() {
## RHEL/CentOS 6 32-Bit ##
# wget http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
# rpm -ivh epel-release-6-8.noarch.rpm
# rm epel-release-6-8.noarch.rpm
#}
#
#install_epel_6_64b() {
## RHEL/CentOS 6 64-Bit ##
# wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
# rpm -ivh epel-release-6-8.noarch.rpm
# rm epel-release-6-8.noarch.rpm
#}
#
# Install extra packages for CentOS 7
install_package_CentOS_7() {
# Update the system
#yum check-update
# Install extra packages
yum -y install perl-TimeDate perl-Time-HiRes perl-Digest-SHA1 perl-Curses perl-Net-Telnet git gcc make perl-Data-Dumper perl-DB_File git
}
#
install_package_debian() {
# Update the system
apt-get update
# Install extra packages
apt-get -y install libtimedate-perl libnet-telnet-perl libcurses-perl libdigest-sha-perl libdata-dumper-simple-perl git
}
#
# Create User and group - Create Directory and Symbolic Link
#
check_if_exist_user() {
egrep -i "^sysop:" /etc/passwd;
if [ $? -eq 0 ]; then
   echo "User Exists no created"
else
   echo "User does not exist -- proceed to create user"
   useradd -m sysop
   echo "Please insert password for user sysop"
   echo " Please enter password for sysop user"
   passwd sysop
   fi
}
#
check_if_exist_group() {
egrep -i "^spider" /etc/group;
if [ $? -eq 0 ]; then
   echo "Group Exists"
else
   echo "Group does not exist -- procced to create group"
   groupadd -g 251 spider
fi
}
#
create_user_group() {
# Greate user
check_if_exist_user
# Create group
check_if_exist_group
# Add the users to the spider group
usermod -aG spider sysop
usermod -aG spider root
}

# Enter CallSign for cluster
 insert_cluster_call() {
 echo -n "Please enter CallSign for DxCluster: "
 chr="\""
 read DXCALL
 echo ${DXCALL}
 su - sysop -c "sed -i 's/mycall =.*/mycall = ${chr}${DXCALL}${chr};/' /spider/local/DXVars.pm"
}

# Enter your CallSign
insert_call() {
 echo -n "Please enter your CallSign: "
 chr="\""
 read SELFCALL
 echo ${SELFCALL}
 su - sysop -c "sed -i 's/myalias =.*/myalias = ${chr}${SELFCALL}${chr};/' /spider/local/DXVars.pm"
}

# Enter your Name
insert_name() {
 echo -n "Please enter your Name: "
 chr="\""
 read MYNAME
 echo ${MYNAME}
 su - sysop -c "sed -i 's/myname =.*/myname = ${chr}${MYNAME}${chr};/' /spider/local/DXVars.pm"
}

# Enter your E-mail
insert_email() {
 echo -n "Please enter your E-mail Address: "
 chr="\""
 read EMAIL
 echo ${EMAIL}
 su - sysop -c "sed -i 's/myemail =.*/myemail = ${chr}${EMAIL}${chr};/' /spider/local/DXVars.pm"
}

# Enter your mylocator
insert_locator() {
 echo -n "Please enter your Locator(Use Capital Letter): "
 chr="\""
 read MYLOCATOR
 echo ${MYLOCATOR}
 su - sysop -c "sed -i 's/mylocator =.*/mylocator = ${chr}${MYLOCATOR}${chr};/' /spider/local/DXVars.pm"
}

# Enter your myqth
insert_qth() {
 echo -n "Please enter your QTH(use comma without space): "
 chr="\""
 read MYQTH
 echo ${MYQTH}
 su - sysop -c "sed -i 's/myqth =.*/myqth = ${chr}${MYQTH}${chr};/' /spider/local/DXVars.pm"
}

install_app() {
# Download Application dxspider with git
su - sysop -c "git clone git://scm.dxcluster.org/scm/spider"
# Create symbolic links
ln -s /home/sysop/spider /spider
}

config_app(){
#
# Fix up permissions ( AS THE SYSOP USER )
su - sysop -c "chown -R sysop.spider spider"
su - sysop -c "find ./ -type d -exec chmod 2775 {} \;"
su - sysop -c "find ./ -type f -exec chmod 775 {} \;"
su - sysop -c "mkdir -p /spider/local"
su - sysop -c "mkdir -p /spider/local_cmd"
su - sysop -c "cp /spider/perl/DXVars.pm.issue /spider/local/DXVars.pm"
su - sysop -c "cp /spider/perl/Listeners.pm /spider/local/Listeners.pm"
su - sysop -c "sed -i '17s/#//' /spider/local/Listeners.pm"
#
insert_cluster_call
insert_call
insert_name
insert_email
insert_locator
insert_qth
#
#echo -n "Now create basic user file"
su - sysop -c "/spider/perl/create_sysop.pl"
echo -n " "
echo -n " "
echo -n " "
}

main() {
        check_distro
        create_user_group
        install_app
        config_app
}
# Execute Script Main
main
exit 0
