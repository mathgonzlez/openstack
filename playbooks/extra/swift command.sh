


##
##
##
swift-ring-builder account.builder create 10 1 1

#RING ACCOUNT
swift-ring-builder account.builder \
  add --region 1 --zone 1 --ip STORAGE_NODE_MANAGEMENT_INTERFACE_IP_ADDRESS --port 6202 \
  --device DEVICE_NAME --weight DEVICE_WEIGHT

swift-ring-builder account.builder add --region 1 --zone 1 --ip 192.168.50.80 --port 6202 --device sdc --weight 100


#RING CONTAINER

swift-ring-builder container.builder \
  add --region 1 --zone 1 --ip STORAGE_NODE_MANAGEMENT_INTERFACE_IP_ADDRESS --port 6201 \
  --device DEVICE_NAME --weight DEVICE_WEIGHT

  swift-ring-builder container.builder add --region 1 --zone 1 --ip 192.168.50.80 --port 6201 --device sdc --weight 100

  #RING OBJECT

  swift-ring-builder object.builder \
  add --region 1 --zone 1 --ip STORAGE_NODE_MANAGEMENT_INTERFACE_IP_ADDRESS --port 6200 \
  --device DEVICE_NAME --weight DEVICE_WEIGHT

  swift-ring-builder object.builder add --region 1 --zone 1 --ip 192.168.50.80 --port 6200 --device sdc --weight 100








systemctl enable --now openstack-swift-account.service openstack-swift-account-auditor.service openstack-swift-account-reaper.service openstack-swift-account-replicator.service




systemctl enable --now openstack-swift-container.service openstack-swift-container-auditor.service openstack-swift-container-replicator.service openstack-swift-container-updater.service


systemctl enable --now openstack-swift-object.service openstack-swift-object-auditor.service openstack-swift-object-replicator.service openstack-swift-object-updater.service
