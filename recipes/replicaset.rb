# frozen_string_literal: true
#
# Cookbook Name:: rsc_mongodb
# Recipe:: replicaset
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

class Chef::Recipe
  include Chef::MachineTagHelper
end

include_recipe 'machine_tag::default'
include_recipe 'mongodb::mongo_gem'

Chef::Log.info 'Searching for mongodb nodes to store'
replicaset_hosts = tag_search(node, "mongodb:replicaset=#{node['rsc_mongodb']['replicaset']}")

Chef::Log.info "Debug:ReplicaSet #{replicaset_hosts}"

# id for each host as it's added.
host_id = 0
# start of generate config file to pass to rs.initiate()
rs_config = "config = {
    _id : \'#{node['rsc_mongodb']['replicaset']}\',
     members : ["

replicaset_hosts.each do |server|
  ip_address = server['server:private_ip_0'].first.value + ':27017'
  Chef::Log.info ip_address.to_s
  priority = 0.5
  priority = 1 if server['server:private_ip_0'].first.value == node['ipaddress'].to_s
  rs_config = rs_config.to_s + "{_id: #{host_id}, host: \'#{ip_address}\',priority:#{priority}},"
  host_id += 1
end

rs_config = rs_config.to_s + "     ]
}"
# end of generate config file

Chef::Log.info rs_config.to_s
## initiate replica set , replica set name is already in the config
if node['rsc_mongodb']['restore_from_backup'] == 'true'
  Chef::Log.info 'Replica previously configured, rs.reconfig running'
  file '/tmp/mongoconfig.js' do
    content "rs.reconfig(#{rs_config},{ force: true });"
  end

  Chef::Log.info 'executing replica set'
  execute 'configure_mongo' do
    command "/usr/bin/mongo --username #{node['rsc_mongodb']['user']} --password #{node['rsc_mongodb']['password']} admin /tmp/mongoconfig.js"
  end
else
  file '/tmp/mongoconfig.js' do
    content "rs.initiate(#{rs_config});"
  end

  Chef::Log.info 'executing replica set'
  execute 'configure_mongo' do
    command '/usr/bin/mongo /tmp/mongoconfig.js'
  end
end

Chef::Log.info 'adding users to replica set'
# since we are using keyfile we need client side authentication
ruby_block 'add-admin-user' do
  block do
    require 'mongo'
    connection = Mongo::MongoClient.new('127.0.0.1', 27017, connect_timeout: 15, slave_ok: true)
    admin = connection.db('admin')
    cmd = BSON::OrderedHash['replSetGetStatus', 1]
    @result = admin.command(cmd)
    Chef::Log.info @result
    sleep_counter = 2
    while @result['members'].select { |a| a['self'] && a['stateStr'] == 'PRIMARY' }.count == 0
      Chef::Log.info "No Primary Members, sleeping:#{sleep_counter}, \nresult:#{@result}"
      sleep sleep_counter
      @result = admin.command(cmd)
      sleep_counter += 2
    end
    admin.add_user(node['rsc_mongodb']['user'], node['rsc_mongodb']['password'], false, roles: %w(userAdminAnyDatabase dbAdminAnyDatabase clusterAdmin))
    ::FileUtils.touch('/var/lib/mongodb/.admin_created')
  end
  not_if do
    node['rsc_mongodb']['restore_from_backup'] == 'true'
  end
end

machine_tag "mongodb:PRIMARY=#{node['rsc_mongodb']['replicaset']}" do
  action :create
end
