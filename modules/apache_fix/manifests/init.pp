class apache_fix {
    package { 'httpd':
	ensure => present;
    }
    
    service { 'httpd':
	ensure => running,
	enable => true,
	subscribe => File["/etc/httpd/conf/httpd.conf"],
	require => Package["httpd"];
    }

    $rewrite = true
    $rewrite_cond = '%{REQUEST_URI}  !(/data\.php|images)'
    $rewrite_rule = '^(.*)$ /data.php?id=1 [L]'
    $doc_root = '/var/www/html'
    
    #Fixing ServerName issue
    file { "/etc/httpd/conf/httpd.conf":
        content => template('apache_fix/httpd.erb'),
		notify => Service["httpd"],
    }
	
	#Fixing site access issue
    file { "/etc/httpd/conf.d":
		ensure => "directory",
		notify => Service["httpd"],
    }

    file { "/etc/httpd/conf.d/virtual.conf":
		content => template('apache_fix/virtual.erb'),
		notify => Service["httpd"],
    }
    
    #Fixing Rewrite rules
    file { "/var/www/html/.htaccess":
		content => template('apache_fix/htaccess.erb'),
		notify => Service["httpd"],
    }
}

include apache_fix