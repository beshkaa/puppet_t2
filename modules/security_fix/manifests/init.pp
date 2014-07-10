class security_fix {


# Creating admin user for SSH acces

user {'admin':
    home => '/home/admin',
    managehome => true,
    groups => ['wheel'],
    password => '$1$8r.MwTiF$.dzPKs1LJN6ErlPsx5z8u/'
}

# Modify sudo for wheel access

package { 'sudo':
    ensure => installed,
}

augeas { 'sudoweel':
    context => '/files/etc/sudoers',
    changes => [
    'set spec[user = "%wheel"]/user %wheel',
    'set spec[user = "%wheel"]/host_group/host ALL',
    'set spec[user = "%wheel"]/host_group/command ALL',
    'set spec[user = "%wheel"]/host_group/command/runas_user ALL',
    ],
}

# SSHd configuration / no root and empty password access

package { 'openssh-server':
    ensure => installed,
    }

service { 'sshd':
    enable => true,
    ensure => running,
    require => Package['openssh-server'],
    }

augeas {'sshd_config':
    context => '/files/etc/ssh/sshd_config',
    notify => Service['sshd'],
    changes => [
	'set PermitRootLogin no',
	'set PermitEmptyPasswords no',
    ],
}

# IPTables configuration

package {'iptables':
    ensure => installed,
    }    

# Adding nessesary configuration to puppet config. 

exec {'puppetconfig':
    command => "/usr/bin/puppet config set libdir /var/lib/puppet/lib;"
}

# Applying rules for IPTables

iptables { 'allow established, related':
    state => ['ESTABLISHED', 'RELATED'],
    proto => 'all',
    jump  => 'ACCEPT',
}

iptables { 'allow localhost':
    source => '127.0.0.1',
    proto  => 'all',
    jump   => 'ACCEPT',
}

iptables { 'allow LAN':
    source => '10.0.2.0/24',
    proto  => 'all',
    jump   => 'ACCEPT',
}

iptables { 'allow ssh':
    proto => 'tcp',
    dport => 22,
    jump => 'ACCEPT',
}

iptables { 'allow web':

    proto => 'tcp',
    dport => 80,
    jump => 'ACCEPT',
}

iptables { 'drop incoming packets':
    chain => 'INPUT',
    proto => 'all',
    jump  => 'DROP',
} 


}

include security_fix