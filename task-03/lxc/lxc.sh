#!/bin/bash

yes | apt-get install mc
yes | apt-get install lxc lxc-templates

# cat <<PAST | tee -a /etc/lxc/lxc-usernet
# your-username veth lxcbr0 10
# PAST

cat <<PAST | tee -a /etc/default/lxc-net
USE_LXC_BRIDGE="true"
LXC_BRIDGE="lxcbr0"
LXC_ADDR="192.168.1.1"
LXC_NETMASK="255.255.255.0"
LXC_NETWORK="192.168.1.0/24"
LXC_DHCP_RANGE="192.168.1.2,192.168.1.254"
LXC_DHCP_MAX="253"
LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf
LXC_DOMAIN=""
PAST

cat <<PAST | tee /etc/lxc/dnsmasq.conf

dhcp-hostsfile=/etc/lxc/dnsmasq-hosts.conf
PAST

cat <<PAST | tee /etc/lxc/dnsmasq-hosts.conf
centos80,192.168.1.100
centos81,192.168.1.101
PAST

sudo mkdir -p /var/lib/lxd/networks/lxcbr0/
cat <<PAST | tee /var/lib/lxd/networks/lxcbr0/dnsmasq.hosts
192.168.1.100,centos80
192.168.1.101,centos81
PAST

sudo mkdir -p /etc/dnsmasq.d-available/
cat <<PAST | tee /etc/dnsmasq.d-available/lxc
bind-interfaces
except-interface=lxcbr0
PAST

sudo systemctl enable lxc-net
sudo systemctl start lxc-net

cat <<PAST | tee /etc/lxc/default.conf
lxc.net.0.type  = veth
lxc.net.0.flags = up
lxc.net.0.link  = lxcbr0
lxc.apparmor.profile = unconfined
PAST

sudo lxc-create -t download -n centos80 -- -d centos -r 8 -a amd64
sudo lxc-create -t download -n centos81 -- -d centos -r 8 -a amd64


sudo lxc-start -n centos80
sudo lxc-start -n centos81

sleep 10

sudo lxc-attach centos80 -- yum -y install httpd
sudo lxc-attach centos80 -- systemctl enable httpd
sudo lxc-attach centos80 -- systemctl start httpd


sudo lxc-attach centos81 -- yum -y install httpd
sudo lxc-attach centos81 -- yum -y install php
sudo lxc-attach centos81 -- systemctl enable httpd
sudo lxc-attach centos81 -- systemctl start httpd



#sudo mkdir -pv /var/lib/lxc/centos80/rootfs/var/www/html/
sudo chmod -v 775 /var/lib/lxc/centos80/rootfs/var/www/html/
sudo chown -vR root:root /var/lib/lxc/centos80/rootfs/var/www/html/
sudo cp /vagrant/index.html /var/lib/lxc/centos80/rootfs/var/www/html/

sudo mkdir -pv /var/lib/lxc/centos81/rootfs/var/www/php/
sudo chmod -v 775 /var/lib/lxc/centos81/rootfs/var/www/php
sudo chown -vR root:root /var/lib/lxc/centos81/rootfs/var/www/php
sudo cp /vagrant/index.php /var/lib/lxc/centos81/rootfs/var/www/php/

# Config VirtualHosts 
#sudo mkdir -pv /var/lib/lxc/centos80/etc/httpd/sites-available
#sudo chmod -v 775 /var/lib/lxc/centos80/etc/httpd/sites-available
#sudo chown -vR root:root /var/lib/lxc/centos80/etc/httpd/sites-available

#sudo mkdir -pv /var/lib/lxc/centos80/etc/httpd/sites-enabled
#sudo chmod -v 775 /var/lib/lxc/centos80/etc/httpd/sites-enabled
#sudo chown -vR root:root /var/lib/lxc/centos80/etc/httpd/sites-enabled

# Config VirtualHosts  
#sudo mkdir -pv /var/lib/lxc/centos81/etc/httpd/sites-available
#sudo chmod -v 775 /var/lib/lxc/centos81/etc/httpd/sites-available
#sudo chown -vR root:root /var/lib/lxc/centos81/etc/httpd/sites-available

#sudo mkdir -pv /var/lib/lxc/centos81/etc/httpd/sites-enabled
#sudo chmod -v 775 /var/lib/lxc/centos81/etc/httpd/sites-enabled
#sudo chown -vR root:root /var/lib/lxc/centos81/etc/httpd/sites-enabled




#sudo rm /var/lib/lxc/centos80/rootfs/etc/httpd/conf.d/welcome.conf
#sudo rm /var/lib/lxc/centos80/rootfs/etc/httpd/conf.d/userdir.conf
#sudo rm /var/lib/lxc/centos80/rootfs/etc/httpd/conf.d/autoindex.conf

#sudo rm /var/lib/lxc/centos81/rootfs/etc/httpd/conf.d/welcome.conf
#sudo rm /var/lib/lxc/centos81/rootfs/etc/httpd/conf.d/userdir.conf
#sudo rm /var/lib/lxc/centos81/rootfs/etc/httpd/conf.d/autoindex.conf

# Enabling necessary files .conf
sudo cp /vagrant/site80.conf /var/lib/lxc/centos80/rootfs/etc/httpd/conf.d/
sudo cp /vagrant/site81.conf /var/lib/lxc/centos81/rootfs/etc/httpd/conf.d/

# Enabling VirtualHosts
#sudo cp /vagrant/centos80.conf /var/lib/lxc/centos80/rootfs/etc/httpd/sites-available/centos80.conf
#sudo cp /vagrant/php.conf /var/lib/lxc/centos81/rootfs/etc/httpd/sites-available/php.conf

#sudo ln -svf /var/lib/lxc/centos80/rootfs/etc/httpd/sites-available/centos80.conf /var/lib/lxc/centos80/rootfs/etc/httpd/sites-enabled/centos80.conf
#sudo ln -svf /var/lib/lxc/centos81/etc/httpd/sites-available/php.conf /var/lib/lxc/centos81/rootfs/etc/httpd/sites-enabled/php.conf



sudo sed -i.bak -e "/Listen 80/a Listen 81" /var/lib/lxc/centos81/rootfs/etc/httpd/conf/httpd.conf

sudo rm /var/lib/lxc/centos80/rootfs/etc/httpd/conf.d/welcome.conf
sudo rm /var/lib/lxc/centos81/rootfs/etc/httpd/conf.d/welcome.conf

sudo lxc-attach centos80 -- systemctl restart httpd
sudo lxc-attach centos81 -- systemctl restart httpd

centos80IP=$(sudo lxc-info -i -n centos80 | cut -d : -f 2)
centos81IP=$(sudo lxc-info -i -n centos81 | cut -d : -f 2)
sudo iptables -F
# sudo iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.0.3.14:80
sudo iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination ${centos80IP}:80
sudo iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 81 -j DNAT --to-destination ${centos81IP}:81

sudo lxc-ls -f