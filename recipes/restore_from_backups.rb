
# frozen_string_literal: true
node.default['rs-storage']['device']['nickname'] = (node['rsc_mongodb']['volume_nickname']).to_s
node.default['rs-storage']['device']['volume_size'] = (node['rsc_mongodb']['volume_size']).to_s
node.default['rs-storage']['device']['filesystem'] = (node['rsc_mongodb']['volume_filesystem']).to_s
node.default['rs-storage']['device']['mount_point'] = (node['rsc_mongodb']['volume_mount_point']).to_s

# installs right_api_client
include_recipe 'rightscale_volume::default'

# if "#{node.default['rs-storage']['device']['mount_point']}" exists mv

include_recipe 'rs-storage::volume'

# when using volumes we set the datadir to the mount point.
node.default['mongodb']['config']['dbpath'] = (node['rs-storage']['device']['mount_point']).to_s

node.default['rs-storage']['restore']['lineage'] = (node['rsc_mongodb']['restore_lineage_name']).to_s
