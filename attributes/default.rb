# frozen_string_literal: true
node.default['mongodb']['cluster_name'] = 'rs_my_replicaset'
node.default['rsc_mongodb']['replicaset'] = 'rs_my_replicaset'
node.default['build-essential']['compile_time'] = true
