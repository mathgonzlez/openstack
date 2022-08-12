#Load variables
source /home/stack/osp16/overcloudrc
#...........................................................................................................
############################################################################################################
#Flavors
############################################################################################################
openstack flavor create --public m1.tiny --id auto --ram 1024 --disk 5 --vcpus 1 --public
openstack flavor create --public m1.small --id auto --ram 2048 --disk 10 --vcpus 1 --public
openstack flavor create --public m1.medium --id auto --ram 4096 --disk 30 --vcpus 1 --public
openstack flavor create --public m2.medium --id auto --ram 4096 --disk 30 --vcpus 2 --public
openstack flavor create --public m2.large --id auto --ram 6144 --disk 50 --vcpus 2 --public
openstack flavor create --public m3.large --id auto --ram 6144 --disk 50 --vcpus 3 --public
openstack flavor create --public m3.xlarge --id auto --ram 8192 --disk 60 --vcpus 3 --public
openstack flavor create --public m4.large --id auto --ram 6144 --disk 50 --vcpus 4 --public
openstack flavor create --public m4.xlarge --id auto --ram 8192 --disk 70 --vcpus 4 --public
openstack flavor create --public m6.xlarge --id auto --ram 8192 --disk 75 --vcpus 6 --public
openstack flavor create --public m6.xxlarge --id auto --ram 12288 --disk 75 --vcpus 6 --public
openstack flavor create --public m6.xxxlarge --id auto --ram 16384 --disk 75 --vcpus 6 --public
############################################################################################################
#Security groups
############################################################################################################
openstack security group rule create default --protocol icmp --ingress
openstack security group rule create default --protocol tcp --dst-port 22 --ingress
############################################################################################################
#Upload Images
############################################################################################################
glance image-create --name debian10 --visibility public --disk-format qcow2 --container-format bare --file /home/stack/nfs/images/debian10/debian10
glance image-create --name rhel8 --visibility public --disk-format qcow2 --container-format bare --file /home/stack/nfs/images/rhel8/Rhel8.3.qcow2
############################################################################################################
#Keypar
############################################################################################################
openstack keypair create admin > ./admin.pem
chmod 600 ./admin.pem
############################################################################################################
#User & groups
############################################################################################################
USERS="math"
#...........................................................................................................
for user in ${USERS}; do
openstack user create ${user} --password jksdert --email mathiias.gonzalez@gmail.com
openstack project create math-tenant --description "Project for ${user}"
openstack role add --project ${user}-tenant --user ${user} admin
tenantUser=$(openstack user list | awk '/math/ {print $2}')
tenant=$(openstack project list | awk '/math/ {print $2}')
nova quota-update $tenant --instances 50 --cores 64 --ram 128000
cinder quota-update --volumes 100 --gigabytes 7000 $tenant
done