# frozen_string_literal: true
#
# Cookbook Name:: rsc_mongodb
# Recipe:: mongodb_backup
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

# Cron executes this recipe to take backups of the mongodb volume

node.override['rs-storage']['device']['mount_point'] = (node['rsc_mongodb']['volume_mount_point']).to_s
node.override['rs-storage']['backup']['lineage'] = (node['rsc_mongodb']['backup_lineage_name']).to_s

Chef::Log.info "Backup Lineage: #{node['rsc_mongodb']['backup_lineage_name']}"

include_recipe 'rs-storage::backup'
