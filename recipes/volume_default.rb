# frozen_string_literal: true
#
# Cookbook Name:: rsc_mongodb
# Recipe:: volume_default
#
# Copyright (C) 2015 RightScale Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# if restoring from backups , then enable the volume use
if node['rsc_mongodb']['use_storage'] == 'true' || node['rsc_mongodb']['restore_from_backup'] == 'true'
  node.default['rs-storage']['device']['nickname'] = (node['rsc_mongodb']['volume_nickname']).to_s
  node.default['rs-storage']['device']['volume_size'] = (node['rsc_mongodb']['volume_size']).to_s
  node.default['rs-storage']['device']['filesystem'] = (node['rsc_mongodb']['volume_filesystem']).to_s
  node.default['rs-storage']['device']['mount_point'] = (node['rsc_mongodb']['volume_mount_point']).to_s

  # installs right_api_client
  include_recipe 'rightscale_volume::default'

  # add the restore lineage here if you'd like to create a volume from a snapshot.
  if node['rsc_mongodb']['restore_from_backup'] == 'true'
    Chef::Log.info "Restoring from  lineage: #{node['rsc_mongodb']['backup_lineage_name']}"
    node.default['rs-storage']['restore']['lineage'] = (node['rsc_mongodb']['restore_lineage_name']).to_s
  end

  include_recipe 'rs-storage::volume'

  # when using volumes we set the datadir to the mount point.
  node.default['mongodb']['config']['dbpath'] = (node.default['rs-storage']['device']['mount_point']).to_s

end

# test data
# Retrieve the dataset from https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/dataset.json and save to a file named primer-dataset.json.
# mongoimport --db test --file primer-dataset.json
# on a slave host db.getMongo().setSlaveOk()   - check to see if data is on that node.
# mongo --host x.x.x.x `mongo --quiet --eval "db.isMaster()['primary']"`
# rs.add("54.161.200.221")
# mongo --host 54.161.172.179 `mongo --quiet --eval "db.isMaster()['primary']"`
