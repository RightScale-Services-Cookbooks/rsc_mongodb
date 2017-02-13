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

# store host info for each member
Chef::Log.info 'Searching for mongodb nodes'
replicaset_hosts = tag_search(node, "mongodb:replicaset=#{node['rsc_mongodb']['replicaset']}")

# debug
Chef::Log.info "ReplicaSet #{replicaset_hosts}"

# id for each host as it's added.
host_id = 0
# start of generate config file to pass to rs.initiate()
rs_config = "config = {
    _id : \'#{node['rsc_mongodb']['replicaset']}\',
     members : ["

replicaset_hosts.each do |server|
  ip_address = server['server:private_ip_0'].first.value + ':27017'
  Chef::Log.info ip_address.to_s
  rs_config = rs_config.to_s + "{_id: #{host_id}, host: \'#{ip_address}\'},"
  host_id += 1
end

rs_config = rs_config.to_s + "     ]
}"
# end of generate config file

Chef::Log.info rs_config.to_s
## initiate replica set , replica set name is already in the config

file '/tmp/mongoconfig.js' do
  content "rs.initiate(#{rs_config});"
end

Chef::Log.info "executing replica set"
execute 'configure_mongo' do
  command '/usr/bin/mongo /tmp/mongoconfig.js'
end

Chef::Log.info "adding users to replica set"
# since we are using keyfile we need client side authentication
ruby_block 'add-admin-user' do
  block do
    require 'mongo'
    connection = Mongo::MongoClient.new(
      '127.0.0.1',
      27017,
      connect_timeout: 15,
      slave_ok: true
    )
    admin = connection.db('admin')
    db = connection.db('admin')
    db.add_user(node['rsc_mongodb']['user'], node['rsc_mongodb']['password'], false, roles: %w(userAdminAnyDatabase dbAdminAnyDatabase clusterAdmin))
  end
end

machine_tag "mongodb:#{node['rsc_mongodb']['replicaset']}=PRIMARY" do
  action :create
end
