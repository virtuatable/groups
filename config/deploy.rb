lock '~> 3.11.0'

set :application, 'virtuadmin-groups'
set :deploy_to, '/var/www/groups'

set :repo_url, 'git@github.com:jdr-tools/groups.git'
set :branch, 'master'

append :linked_files, 'config/mongoid.yml'
append :linked_files, '.env'

append :linked_dirs, 'bundle'