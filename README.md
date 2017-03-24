# rs-mongodb cookbook



Provides recipes for managing volumes on a Server in a RightScale supported cloud which include:

* Creation of a replicaset with or without volume support (volumes required for backup and restore functionality)
* Taking backups of volumes

### Use Cases 

Replicaset without volume support.
 - Set use_storage and restore_from_backup inputs to false and boot 3 nodes.
 - Once operational, on a single node execute the "rsc_mongodb::replicaset" recipe.
 - Once that completes you should have a replicaset configured and ready.
 
Replicaset with volume support.
 - Set the use_storage input to true and boot 3 nodes.
 - Once operational, on a single node execute the "rsc_mongodb::replicaset" recipe.
 - Once that completes you should have a replicaset configured and ready.
 
Restore Replicaset Node from a backup.
 - Set the restore_from_backup to true and boot a single node.
 - Once operational, execute the "rsc_mongodb::add_to_replicaset" recipe.
 - Once that completes you should have that member added to the replicaset



Github Repository: [https://github.com/RightScale-Services-Cookbooks/rsc_mongodb](https://github.com/RightScale-Services-Cookbooks/rsc_mongodb)

# Requirements

* Requires Chef 11 or higher
* Platform
  * Ubuntu 12.04
* Cookbooks
  * [chef_handler](http://community.opscode.com/cookbooks/chef_handler)


# Usage


# Attributes



# Recipes

## `rs-storage::default`

Simply includes the `rightscale_volume::default` and `rightscale_backup::default` recipes to meet the requirements of
using the resources in these cookbooks.



# Author

Author:: RightScale Inc (<premium@rightscale.com>)
