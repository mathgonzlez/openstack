echo -e "Node Import"
openstack overcloud node import /home/stack/osp16/hw-introspect/controller.json
openstack overcloud node import /home/stack/osp16/hw-introspect/computes.json
#echo -e "Node compute delete"
#openstack baremetal node delete osp16-compute
echo -e "Node introspect"
openstack overcloud node introspect --all-manageable --provide
echo "Finish"