#!/bin/bash
THT=/usr/share/openstack-tripleo-heat-templates
OSPE=/home/stack/osp16/templates/environments
OSPP=/home/stack/osp16/postconfig


openstack overcloud deploy --templates $THT --timeout 180 --stack overcloud \
-n $OSPE/02-network_data.yaml \
-r $OSPE/00-roles_data.yaml \
-e $OSPE/01-node-info.yaml \
-e $THT/environments/network-isolation.yaml \
-e $THT/environments/network-environment.yaml \
-e $THT/environments/services/neutron-ovn-dvr-ha.yaml \
-e $THT/environments/disable-telemetry.yaml \
-e /home/stack/containers-prepare-parameter.yaml \
-e $OSPE/10-network-environment.yaml \
-e $OSPE/30-vips-fixed-ip.yaml \
-e $OSPE/31-ips-from-pool-all.yaml \
-e $OSPE/41-ldap_config.yaml \
-e $OSPE/50-overcloud-misc.yaml
-e $OSPE/85-nova-custom.yaml \
-e $OSPP/70_root_password.yaml \
-e $THT/environments/network-isolation.yaml \
#-e $THT/environments/ceph-ansible/ceph-ansible.yaml \
#-e $THT/environments/ceph-ansible/ceph-dashboard.yaml