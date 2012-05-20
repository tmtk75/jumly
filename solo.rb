log_level     :info
log_location  STDOUT
node_name     "solo"
cache_type    "BasicFile"

home = File.expand_path File.dirname __FILE__
cookbook_path [ "#{home}/cookbooks" ]
cache_options( :path => "#{home}/checksums" )

file_cache_path  "#{home}/.cache"
file_backup_path "#{home}/.backup"
data_bag_path    "#{home}/.databags"
node_path        "#{home}/.node"
role_path        "#{home}/.role"

