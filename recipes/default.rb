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
marker "recipe_start"

marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

include_recipe 'build-essential::default'

node.default[:mongodb][:config][:replSet] = "#{node[:rsc_mongodb][:replicaset]}"

#fix bug with name change mongodb vs mongod .conf
node.override['mongodb']['default_init_name'] = 'mongod'

include_recipe 'mongodb::mongodb_org_repo'
include_recipe 'machine_tag::default'


node.default[:mongodb][:config][:replset] = "#{node[:rsc_mongodb][:replicaset]}"

include_recipe 'mongodb::default'

#Tag host with replica set name
machine_tag "mongodb:replicaset=#{node[:rsc_mongodb][:replicaset]}" do
   action :create
end

#if we are using volumes, set up backups on all nodes.
#the cron script will check if it running on a secondary
if node['rsc_mongodb']['use_storage'] == 'true'

Chef::Log.info "Volumes are being used. Adding backup script and cronjob"

    #create the backup script.
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
#mongo --quiet --eval "d=db.isMaster(); print( d['ismaster'] );"
#if true , exit. false run the backups.
end
