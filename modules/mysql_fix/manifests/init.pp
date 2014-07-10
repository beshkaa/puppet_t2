class mysql_fix {

# Fixing chown.
# Puppet not able to chown socket file, so have to apply exec
class mysqlaccess {
    exec { "mysqlchown" :
    command => "/bin/chown -R mysql /var/lib/mysql; /bin/chmod -R 700 /var/lib/mysql;",
    notify => Service["mysqld"],
    }

}

include mysqlaccess


# Fixing PID File location. Generating my.cnf config for MySQL for unification. 

class { '::mysql::server':
    config_file	     => '/etc/my.cnf',
    root_password    => 'broken',
    restart => true,
    override_options => { 
    	'mysqld_safe' => { 
		'socket' => '/var/lib/mysql/mysql.sock',
		'log-error' => '/var/log/mysqld.log',
		'pid-file' => '/var/run/mysqld/mysqld.pid'
    	}, 
 	
	'client' => {
		'socket' => '/var/lib/mysql/mysql.sock',
		'user' => 'root',	
		'password' => 'broken'
   	}, 

    	'mysqld' => {
	    	'datadir' => '/var/lib/mysql',
		'socket' => '/var/lib/mysql/mysql.sock',
		'user' => 'mysql',
		'symbolic-links' => '0',
		'default-storage-engine' => 'innodb',
		'expire_logs_days' => '7',
		'innodb_additional_mem_pool_size' => '20M',
		'innodb_buffer_pool_size' => '256M',
		'innodb_file_per_table' => '1',
		'innodb_flush_log_at_trx_commit' => '1',
		'innodb_flush_method' => 'O_DIRECT',
		'innodb_log_buffer_size' => '8M',
		'innodb_rollback_on_timeout' => '1',
		'innodb_thread_concurrency' => '16',		
		'join_buffer_size' => '8M',
		'key_buffer_size' => '64M',
		'log_error' => '',
		'log_warnings' => '',
		'long_query_time' => '1',
		'max_connections' => '3000',
		'max_heap_table_size' => '64M',
		'max_tmp_tables' => '48',
		'myisam_sort_buffer_size' => '64M',
		'read_buffer_size' => '1M',
		'read_rnd_buffer_size' => '10M',
		'thread_cache_size' => '32',
		'tmp_table_size' => '64M'
	  }
    }
}

# Creating mysql test user for test DB

class mysqlupdate {

mysql_user { 'test@localhost':
 	ensure                   => 'present',
	max_connections_per_hour => '0',
	max_queries_per_hour     => '0',
	max_updates_per_hour     => '0',
	max_user_connections     => '0',
	password_hash		 => '*EEE9F8D2120BA3ECE6E06BB50EE5BF2333035F44'
}

mysql_grant { 'test@localhost/test.*':
  ensure     => 'present',
  options    => ['GRANT'],
  privileges => ['ALL'],
  table      => 'test.*',
  user       => 'test@localhost',
}

}

include mysqlupdate

}