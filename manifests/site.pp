# Fixing Vurtual Packages warnings
if versioncmp($::puppetversion,'3.6.1') >= 0 {

  $allow_virtual_packages = hiera('allow_virtual_packages',false)

  Package {
    allow_virtual => $allow_virtual_packages,
  }
}

# Fixing of FQDN issue on VM
$fqdn_virtual = 'broken.box.local'

# IPTables, no-root-ssh, admin-ssh account (password broken) 
include security_fix

# Hostname2IP mapping
include hosts

# FIXING: ServerName, virtual.conf access, .htaccess rewrite rule
include apache_fix

# FIXING: /var/lib/mysql access, pid file location, creating mysql test user
include mysql_fix