# frozen_string_literal: true
#
# Cookbook Name:: rsc_mongodb
# Recipe:: default
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
marker 'recipe_start'

marker 'recipe_start_rightscale' do
  template 'rightscale_audit_entry.erb'
end

include_recipe 'build-essential::default'

node.default['mongodb']['config']['replSet'] = (node['rsc_mongodb']['replicaset']).to_s

# since we are using keyfile we need client side authentication
node.default['mongodb']['mongos_create_admin'] = true
node.default['mongodb']['authentication']['username'] = node['rsc_mongodb']['user']
node.default['mongodb']['authentication']['password'] = node['rsc_mongodb']['password']

# fix bug with name change mongodb vs mongod .conf
node.override['mongodb']['default_init_name'] = 'mongod'

include_recipe 'mongodb::mongodb_org_repo'
include_recipe 'machine_tag::default'

case node['platform']
when 'ubuntu'
  file '/etc/apt/sources.list.d/mongodb-org-3.0.list' do
    action :create_if_missing
    content 'deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse'
  end
end

apt_update 'default' do
  action :update
end if node['platform_family'] == 'debian'

Chef::Log.info 'Running the mongodb installer'
include_recipe 'mongodb::default'

# don't tag host if recovering from backup
# Tag host with replica set name
machine_tag "mongodb:replicaset=#{node['rsc_mongodb']['replicaset']}" do
  action :create
  not_if node['rsc_mongodb']['restore_from_backup'] == true
end

# if we are using volumes, set up backups on all nodes.
# the cron script will check if it running on a secondary
if node['rsc_mongodb']['use_storage'] == 'true' && node['rsc_mongodb']['restore_from_backup'] != 'true'

  Chef::Log.info 'Volumes are being used. Adding backup script and cronjob'

  # create the backup script.
  template '/usr/bin/mongodb_backup.sh' do
    source 'mongodb_backup.erb'
    owner 'root'
    group 'root'
    mode '0755'
  end

  cron 'mongodb-backup' do
    minute  '0'
    hour    '*/1'
    command 'sleep $[RANDOM\%300];/usr/bin/mongodb_backup.sh'
    user    'root'
  end
  # mongo --quiet --eval "d=db.isMaster(); print( d['ismaster'] );"
  # if true , exit. false run the backups.
end
