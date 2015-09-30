class Chef::Recipe
  include Chef::MachineTagHelper
end

include_recipe 'machine_tag::default'


Chef::Log.info 'Searching for mongodb nodes'
replicaset_hosts = tag_search(node, "mongodb:replicaset=#{node[:rsc_mongodb][:replicaset]}")


Chef::Log.info "replicaset_hosts[1]['server:private_ip_0'].first.value"

#   $ip_address = server['server:private_ip_0'].first.value + ':27017'




#find primary
#{primary_mongo_node} = mongo --quiet --eval "db.isMaster()['primary']"

# ## initiate replica set , replica set name is already in the config
# bash 'initiate the node' do
#   code <<-EOH
#     mongo --host #{node[:rsc_mongodb][:replicaset]}/#{$ip_address}<<CONFIG
#       rs.add("#{node[:cloud][:private_ips][0]}");
#     CONFIG
#   EOH
#   flags '-xe'
# end
#
# machine_tag "mongodb:replicaset=#{node[:rsc_mongodb][:replicaset]}" do
#    action :create
# end

#connects to primary everytime.
#mongo --host my_repl_set_name/my_mongo_server1
