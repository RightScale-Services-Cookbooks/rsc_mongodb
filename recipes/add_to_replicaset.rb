# frozen_string_literal: true
#
# Cookbook Name:: rsc_mongodb
# Recipe:: add_to_replicaset
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

class Chef::Recipe
  include Chef::MachineTagHelper
end

include_recipe 'machine_tag::default'

machine_tag "mongodb:replicaset=#{node['rsc_mongodb']['replicaset']}" do
  action :delete
end

Chef::Log.info 'Searching for mongodb nodes'
replicaset_hosts = tag_search(node, "mongodb:replicaset=#{node['rsc_mongodb']['replicaset']}")

ip_address = replicaset_hosts[1]['server:private_ip_0'].first.value
Chef::Log.info "Host ip: #{ip_address}"

## initiate replica set , replica set name is already in the config

file '/tmp/mongoconfig.js' do
  content "rs.add('#{node['cloud']['private_ips'][0]}');"
end

execute 'configure_mongo' do
  command "/usr/bin/mongo --host #{node['rsc_mongodb']['replicaset']}/#{ip_address} /tmp/mongoconfig.js"
end

Chef::Log.info "Node's Current IP: #{node['cloud']['private_ips'][0]}"

machine_tag "mongodb:replicaset=#{node['rsc_mongodb']['replicaset']}" do
  action :create
end

# Backup the restored node only after it has joined the replicaset

if node['rsc_mongodb']['restore_from_backup'] == 'true'

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
    command '/usr/bin/mongodb_backup.sh'
    user    'root'
  end

end
