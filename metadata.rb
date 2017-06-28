# frozen_string_literal: true
name             'rsc_mongodb'
maintainer       'RightScale Inc'
maintainer_email 'premium@rightscale.com'
license          'Apache 2.0'
description      'Installs/Configures Mongo DB'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.0.4'
chef_version '>= 12.9'
issues_url 'https://github.com/RightScale-Services-Cookbooks/rsc_mondodb/issues'
source_url 'https://github.com/RightScale-Services-Cookbooks/rsc_mondodb'

depends 'build-essential'
depends 'mongodb'
depends 'machine_tag'
depends 'rs-storage'
depends 'rs-base'
depends 'rightscale_backup'
depends 'rightscale_volume'
depends 'marker'
depends 'apt'

recipe 'rsc_mongodb::default', 'Installs mongodb and sets the replicaset name'
recipe 'rsc_mongodb::replicaset', 'Configures nodes into a replicaset'
recipe 'rsc_mongodb::volume_default', 'Creates , attaches and formats a volume'
recipe 'rsc_mongodb::mongodb_backup', 'Backsup the mongodb volume on secondary nodes'
recipe 'rsc_mongodb::add_to_replicaset', 'Add this node to an existing replicaset , users the replicaset name to find nodes.'

attribute 'rsc_mongodb/replicaset',
   display_name: 'MongoDB ReplicaSet Name',
   description: 'The replicaset name to use for the mongodb replica',
   required: 'required',
   category: 'MongoDB',
   type: 'string',
   recipes: ['rsc_mongodb::default', 'rsc_mongodb::replicaset', 'rsc_mongodb::add_to_replicaset']

attribute 'rsc_mongodb/use_storage',
  display_name: 'Enable volumes',
  description: 'Enables the use of volumes for the Mongodb data store',
  required: 'optional',
  category: 'MongoDB',
  default: 'false',
  type: 'string',
  recipes: ['rsc_mongodb::volume_default', 'rsc_mongodb::default']

attribute 'rsc_mongodb/volume_nickname',
  display_name: 'Volume Name',
  description: 'Name of the volume',
  required: 'optional',
  category: 'MongoDB',
  default: 'mongodb_data_volume',
  type: 'string',
  recipes: ['rsc_mongodb::volume_default']

attribute 'rsc_mongodb/volume_size',
  display_name: 'Volume Size',
  description: 'the size of the volume to create',
  required: 'optional',
  category: 'MongoDB',
  default: '10',
  type: 'string',
  recipes: ['rsc_mongodb::volume_default']

attribute 'rsc_mongodb/volume_filesystem',
  display_name: 'Volume Filesystem',
  description: 'the filesystem size',
  required: 'optional',
  category: 'MongoDB',
  default: 'ext4',
  type: 'string',
  recipes: ['rsc_mongodb::volume_default']

attribute 'rsc_mongodb/volume_mount_point',
  display_name: 'Volume Mount Point ',
  description: 'the location to mount the volume',
  required: 'optional',
  category: 'MongoDB',
  default: '/var/lib/mongodb',
  type: 'string',
  recipes: ['rsc_mongodb::volume_default']

attribute 'rsc_mongodb/backup_lineage_name',
  display_name: 'Lineage name for backups',
  description: 'lineage name used for backups',
  required: 'optional',
  category: 'MongoDB',
  default: 'mongodb_backups',
  type: 'string',
  recipes: ['rsc_mongodb::mongodb_backup']

attribute 'rsc_mongodb/restore_from_backup',
  display_name: 'Restore From Backup',
  description: 'if set to true volume creation will use a snapshot',
  required: 'optional',
  category: 'MongoDB',
  default: 'false',
  type: 'string',
  recipes: ['rsc_mongodb::volume_default', 'rsc_mongodb::default']

attribute 'rsc_mongodb/restore_lineage_name',
  display_name: 'Lineage name of the volume to restore from',
  description: 'lineage name to restore from',
  required: 'optional',
  category: 'MongoDB',
  type: 'string',
  recipes: ['rsc_mongodb::volume_default']

attribute 'rsc_mongodb/user',
  display_name: 'MongoDB User',
  description: 'user to authenticate with',
  required: 'optional',
  category: 'MongoDB',
  type: 'string',
  recipes: ['rsc_mongodb::volume_default', 'rsc_mongodb::add_to_replicaset']

attribute 'rsc_mongodb/password',
  display_name: 'MongoDB Password',
  description: 'password to authenticate with',
  required: 'optional',
  category: 'MongoDB',
  type: 'string',
  recipes: ['rsc_mongodb::volume_default', 'rsc_mongodb::add_to_replicaset']
