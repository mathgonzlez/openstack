#Change hostname
hostnamectl set-hostname undercloud.local.lan
##############################################################################
#                           Virtual Networks Config                          #
##############################################################################
#Public network
cat <<EOT >> /etc/sysconfig/network-scripts/ifcfg-eth0
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
IPADDR=192.168.50.45
PREFIX=24
GATEWAY=192.168.50.1
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=no
NAME=eth0
DEVICE=eth0
ONBOOT=yes
EOT
# Provisioning network
cat <<EOT >> /etc/sysconfig/network-scripts/ifcfg-eth1
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
IPADDR=192.168.126.1
PREFIX=24
DEFROUTE=no
IPV4_FAILURE_FATAL=no
IPV6INIT=no
NAME=eth1
DEVICE=eth1
ONBOOT=yes
EOT
#
cat <<EOT >> /etc/sysconfig/network-scripts/route-eth1
ADDRESS0=192.168.126.0
NETMASK0=255.255.255.0
GATEWAY0=192.168.126.254
METRIC0=0
EOT
#
#SUSBCRIBE
subscription-manager register --username mathias.gonzalez.assert --password 35253760m
sudo subscription-manager attach --pool=8a85f9a17ebb30c9017ee7f848454d22
sudo subscription-manager release --set=8.4
#UNSUSCRIBE ALL REPOS
sudo subscription-manager repos --disable=*
# ADD OS REPOS
sudo subscription-manager repos \
--enable=rhel-8-for-x86_64-baseos-eus-rpms \
--enable=rhel-8-for-x86_64-appstream-eus-rpms \
--enable=rhel-8-for-x86_64-highavailability-eus-rpms \
--enable=ansible-2.9-for-rhel-8-x86_64-rpms \
--enable=openstack-16.2-for-rhel-8-x86_64-rpms \
--enable=fast-datapath-for-rhel-8-x86_64-rpms \
--enable=advanced-virt-for-rhel-8-x86_64-rpms
#SET CONTAINER TO 3.0 RELEASE
sudo dnf module disable -y container-tools:rhel8
sudo dnf module enable -y container-tools:3.0
#SELECT VM LATEST MODULE
sudo dnf module disable -y virt:rhel
sudo dnf module enable -y virt:av
#UPDATE
sudo dnf update -y
sudo dnf install -y python3-tripleoclient libvirt-python3 python3-virtualenv \
OpenIPMI ipmitool
#User config
useradd stack
echo jksdert | passwd --stdin stack
echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack
echo "192.168.122.90 undercloud.local.lan undercloud  " | sudo tee -a /etc/hosts
#Configure IPMI & VirtualBMC
python3 -m virtualenv --system-site-packages --download /opt/vbmc
/opt/vbmc/bin/pip install virtualbmc
modprobe ipmi_devintf
modprobe ipmi_msghandler
modprobe ipmi_si type=kcs ports=0xca2 regspacings=1 
systemctl enable --now ipmi
#Download Director Images
sudo dnf -y install rhosp-director-images rhosp-director-images-ipa-x86_64
sudo reboot