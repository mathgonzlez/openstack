#Create undercloud.conf
cat <<EOT >> /home/stack/undercloud.conf
[DEFAULT]
undercloud_hostname = undercloud.local.lan
container_images_file=/home/stack/containers-prepare-parameter.yaml
container_cli = podman
local_ip = 192.168.126.1/24
undercloud_admin_host = 192.168.126.2
undercloud_public_host = 192.168.126.3
overcloud_domain_name = local.lan
undercloud_nameservers = 192.168.50.51
local_interface = eth1
enabled_hardware_types = ipmi,redfish,idrac,staging-ovirt,manual-management
subnets = ctlplane-subnet
local_subnet = ctlplane-subnet
local_mtu = 1500
inspection_interface = br-ctlplane
enable_node_discovery = false
clean_nodes = false
undercloud_enable_selinux = true
undercloud_log_file = /home/stack/install-undercloud.log


[ctlplane-subnet]
cidr = 192.168.126.0/24
dhcp_start = 192.168.126.201
dhcp_end = 192.168.126.220
gateway = 192.168.126.1
inspection_iprange = 192.168.126.221,192.168.126.240
masquerade = false
EOT

#Create container prepare parameter
cat <<EOT >> /home/stack/containers-prepare-parameter.yaml
# Generated with the following on 2021-12-26T15:58:35.953564
#
#   openstack tripleo container image prepare default --local-push-destination --output-env-file containers-prepare-parameter.yaml
#

parameter_defaults:
  ContainerImagePrepare:
  - push_destination: true
    set:
      ceph_alertmanager_image: ose-prometheus-alertmanager
      ceph_alertmanager_namespace: registry.redhat.io/openshift4
      ceph_alertmanager_tag: 4.1
      ceph_grafana_image: rhceph-4-dashboard-rhel8
      ceph_grafana_namespace: registry.redhat.io/rhceph
      ceph_grafana_tag: 4
      ceph_image: rhceph-4-rhel8
      ceph_namespace: registry.redhat.io/rhceph
      ceph_node_exporter_image: ose-prometheus-node-exporter
      ceph_node_exporter_namespace: registry.redhat.io/openshift4
      ceph_node_exporter_tag: v4.1
      ceph_prometheus_image: ose-prometheus
      ceph_prometheus_namespace: registry.redhat.io/openshift4
      ceph_prometheus_tag: 4.1
      ceph_tag: latest
      name_prefix: openstack-
      name_suffix: ''
      namespace: registry.redhat.io/rhosp-rhel8
      neutron_driver: ovn
      rhel_containers: false
      tag: '16.2.2'
    tag_from_label: '{version}-{release}'
  ContainerImageRegistryCredentials:
    registry.redhat.io:
      mathias.gonzalez.assert: 35253760m
EOT
time openstack undercloud install

#Upload OS Images
mkdir /home/stack/images
cd /home/stack/images
source /home/stack/stackrc
for i in /usr/share/rhosp-director-images/overcloud-full-latest-16.2.tar /usr/share/rhosp-director-images/ironic-python-agent-latest-16.2.tar; do tar -xvf $i; done
openstack overcloud image upload --image-path /home/stack/images/