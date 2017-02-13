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

Chef::Log.info 'Searching for mongodb nodes'
replicaset_hosts = tag_search(node, %W(mongodb:replicaset=#{node['rsc_mongodb']['replicaset']} mongodb:PRIMARY=#{node['rsc_mongodb']['replicaset']}), match_all: true)

Chef::Log.info replicaset_hosts
if replicaset_hosts.nil?

  Chef::Log.info 'no Hosts'
else
  first_server = replicaset_hosts[0]
  ip_address = first_server['server:private_ip_0'].first.value unless first_server.nil?
  Chef::Log.info "Host ip: #{ip_address}"

  ## initiate replica set , replica set name is already in the config

  file '/tmp/mongoconfig.js' do
    content "rs.add('#{node['cloud']['private_ips'][0]}');"
  end

  execute 'configure_mongo' do
    command "/usr/bin/mongo -u #{node['rsc_mongodb']['user']} -p #{node['rsc_mongodb']['password']} --authenticationDatabase admin --host #{node['rsc_mongodb']['replicaset']}/#{ip_address} /tmp/mongoconfig.js"
  end

  service 'mongodb' do
    action :stop
  end

  execute 'rm -fr /var/lib/mongodb/*'

  service 'mongodb' do
    action :start
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
end
