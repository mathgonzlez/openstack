#Change hostname
hostnamectl set-hostname undercloud.local.lan
##############################################################################
#                            Networks Config                                 #
##############################################################################
#Public network
cat <<EOT >> /etc/sysconfig/network-scripts/ifcfg-eth0
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
IPADDR=192.168.50.60
PREFIX=24
GATEWAY=192.168.50.1
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=no
NAME=eth0
DEVICE=eth0
ONBOOT=yes
EOT
##############################################################################
#Provisioning network
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
##############################################################################
#                          Susbcription Config                               #
##############################################################################
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
sudo dnf install -y python3-tripleoclient libvirt-python3 python3-virtualenv cloud-utils-growpart
##############################################################################
#                               SO Config                                    #
##############################################################################
#User config
useradd stack
echo jksdert | passwd --stdin stack
echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
# chmod 0440 /etc/sudoers.d/stack
#MOUNT NFS
# mkdir /nfs
# sudo mount -t nfs 192.168.50.80:/export/nfs nfs/
echo "192.168.50.60 undercloud.local.lan undercloud  " | sudo tee -a /etc/hosts
#Expand disk
# growpart /dev/sda 2
# xfs_growfs /dev/sda2
#Download Director Images
sudo dnf -y install rhosp-director-images rhosp-director-images-ipa-x86_64
sudo reboot
##############################################################################