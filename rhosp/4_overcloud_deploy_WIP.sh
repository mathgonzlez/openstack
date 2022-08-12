#################################################
#Create RHOSP directory
#################################################
mkdir -p /home/stack/osp16/environments
mkdir -p /home/stack/osp16/introspection/hw-introspect
mkdir -p /home/stack/osp16/postconfig
mkdir -p /home/stack/osp16/scripts  
mkdir -p /home/stack/osp16/templates/environments
#################################################
#INTROSPECT DOCS
#################################################
############CONTROLLERS INTROSPECT
touch /home/stack/osp16/introspection/hw-introspect/controller.json
cat <<EOT >> /home/stack/osp16/introspection/hw-introspect/controller.json
{
      "nodes": [
          {
              "name":"osp16-controller-0",
              "pm_type":"staging-ovirt",
              "mac":[
                  "56:6f:ae:1d:00:0b"
              ],
              "cpu":"2",
              "memory":"4096",
              "disk":"40",
              "arch":"x86_64",
              "pm_user":"admin@internal",
              "pm_password":"jksdert",
              "pm_addr":"rhvirt.local.lan",
              "pm_vm_name":"overcloud.local.lan",
              "capabilities": "profile:control,boot_option:local"

                 }
        ]
}
EOT
############COMPUTES INTROSPECT
# touch /home/stack/osp16/introspection/hw-introspect/computes.json
# cat <<EOT >> /home/stack/osp16/introspection/hw-introspect/computes.json
# {
#     "nodes": [
#          {
#             "name":"osp16-compute-0",
#             "pm_type":"manual-management",
#             "mac":[
#                 "40:2c:f4:e9:f0:c9"
#             ],
#             "cpu":"2",
#             "memory":"4096",
#             "disk":"40",
#             "arch":"x86_64",
#             "capabilities": "profile:compute,boot_option:local"
#                }
#       ]
# }
# EOT
############Import & introspect Overcloud
source /home/stack/stackrc
openstack overcloud node import /home/stack/osp16/introspection/hw-introspect/controller.json && openstack overcloud node import /home/stack/osp16/introspection/hw-introspect/computes.json \
&& openstack overcloud node introspect --all-manageable --provide