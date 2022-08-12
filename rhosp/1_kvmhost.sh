##############################################################################
#                           Host Configuration                               #
##############################################################################
hostnamectl set-hostname kvmhost.local.lan
#SUSBCRIBE
subscription-manager unregister
subscription-manager register --username mathgonzlez --password 35253760m
sudo subscription-manager attach --pool=2c9280817af91203017b0a5014c56bbc
sudo subscription-manager release --set=8.4
# Update
dnf -y update
dnf -y install @virt cockpit libvirt-client libvirt-daemon qemu-kvm \
 libvirt-daemon-kvm virt-install rsync libguestfs-tools virt-install cockpit-machines nfs-utils
#Enable Services
systemctl enable --now libvirtd cockpit.socket
##############################################################################
#                           Virtual Networks Config                          #
##############################################################################
#Remove default network
virsh net-destroy default
virsh net-undefine default
virsh net-list 
#Create external network for VMs
cat <<EOT >> /tmp/external.xml
<network>
   <name>external</name>
   <forward mode='nat'>
      <nat> <port start='1024' end='65535'/>
      </nat>
   </forward>
   <ip address='192.168.122.1' netmask='255.255.255.0'>
   </ip>
</network>
EOT
virsh net-define /tmp/external.xml
virsh net-autostart external
virsh net-start external
#Create provisioning network for VMs
cat <<EOT >> /tmp/provisioning.xml
<network>
   <name>provisioning</name>
   <ip address='192.168.126.254' netmask='255.255.255.0'>
   </ip>
</network>
EOT
virsh net-define /tmp/provisioning.xml
virsh net-autostart provisioning
virsh net-start provisioning
#Disable firewalld
systemctl disable --now firewalld
##############################################################################
#                           Undercloud VM Config                             #
##############################################################################
#Download RHEL Image
mkdir /NAS
mount -t nfs 192.168.50.13:/mnt/pool/NAS/NAS /NAS/
rsync -av -P /NAS/images/rhel8/rhel8.4.qcow2 /var/lib/libvirt/images/
sudo qemu-img create -f qcow2 -o preallocation=metadata /var/lib/libvirt/images/undercloud.qcow2 150G;
#Customize RHEL image
sudo virt-resize --expand /dev/sda3 /var/lib/libvirt/images/rhel8.4.qcow2 /var/lib/libvirt/images/undercloud.qcow2
sudo virt-customize -a /var/lib/libvirt/images/undercloud.qcow2 --uninstall cloud-init --root-password password:jksdert
#Create Undercloud VM
sudo virt-install --ram 20480 --vcpus 4 --os-variant rhel8.0 \
--disk path=/var/lib/libvirt/images/undercloud.qcow2,device=disk,bus=virtio,format=qcow2 \
--graphics vnc,listen=0.0.0.0 --noautoconsole \
--network type=direct,source=eno1,source_mode=bridge,model=virtio \
--name undercloud.local.lan --dry-run \
--print-xml > /tmp/undercloud.xml;
sudo virsh define --file /tmp/undercloud.xml
##############################################################################
#                           Overcloud VM Config                             #
##############################################################################
#Download RHEL Image
sudo qemu-img create -f qcow2 -o preallocation=metadata /var/lib/libvirt/images/overcloud.qcow2 150G;
#Customize RHEL image
#Create overcloud VM
sudo virt-install --ram 12480 --vcpus 8 --os-variant rhel8.0 \
--disk path=/var/lib/libvirt/images/overcloud.qcow2,device=disk,bus=virtio,format=qcow2 \
--graphics vnc,listen=0.0.0.0 --noautoconsole \
--name overcloud.local.lan --dry-run \
--print-xml > /tmp/overcloud.xml;
sudo virsh define --file /tmp/overcloud.xml