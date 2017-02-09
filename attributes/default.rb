# frozen_string_literal: true
default['mongodb']['cluster_name'] = 'rs_my_replicaset'
default['rsc_mongodb']['replicaset'] = 'rs_my_replicaset'
default['rsc_mongodb']['restore_from_backup'] = false
default['build-essential']['compile_time'] = true
default['mongodb']['config']['keyFile'] = '/etc/mongodb_keyfile'
