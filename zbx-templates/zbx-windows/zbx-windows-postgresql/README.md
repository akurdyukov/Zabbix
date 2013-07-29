ZBX-WINDOWS-POSTGRESQL
=================

This template use Zabbix agent to discover and manage PostgreSQL server on Windows.

Items
-----

  * PostgreSQL port 5432 availability
  * Discovery: Database cache percentage for each database
  * Discovery: Number of rows commited for each database
  * Discovery: Number on rows deleted for each database
  * Discovery: Number of rows fetched for each database
  * Discovery: Number of rows inserted for each database
  * Discovery: Number of rows updated for each database
  * Discovery: Database size in bytes for each database
  * Discovery: Successfully commited transactions percentage for each database

Triggers
--------

  * **[HIGH]** => PostgreSQL database server is down

Graphs
------

  * Database size

Installation
------------

1. Install the Zabbix agent on your host or download my automated package [`Zabbix agent`](https://github.com/jjmartres/Zabbix/tree/master/zbx-agent)

  If your choose to install the Zabbix agent from the source, you need to :
  1. Install [`zabbix_postgresql.vbs`](https://github.com/jjmartres/Zabbix/tree/master/zbx-templates/zbx-windows/zbx-windows-postgresql/zabbix_postgresql.vbs) in the script directory of your Zabbix agent.
  2. Add the following line to your Zabbix agent configuration file. Note that `<zabbix_script_path>` is your Zabbix agent script path, `<postgresql_bin_path>` is your PostgreSQL installation `bin` directory path :

			EnableRemoteCommands=1
			UnsafeUserParameters=1
			UserParameter=psql.db.discovery,%systemroot%\system32\cscript.exe /nologo /T:30 <zabbix_script_path>\zabbix_postgresql.vbs "<postgresql_bin_path>" detect
			UserParameter=psql.db.size[*],%systemroot%\system32\cscript.exe /nologo /T:30 <zabbix_script_path>\zabbix_postgresql.vbs "<postgresql_bin_path>" db_size $1
			UserParameter=psql.db.cache[*],%systemroot%\system32\cscript.exe /nologo /T:30 <zabbix_script_path>\zabbix_postgresql.vbs "<postgresql_bin_path>" db_cache $1
			UserParameter=psql.db.connections[*],%systemroot%\system32\cscript.exe /nologo /T:30 <zabbix_script_path>\zabbix_postgresql.vbs "<postgresql_bin_path>" db_connections $1
			UserParameter=psql.db.fetched[*],%systemroot%\system32\cscript.exe /nologo /T:30 <zabbix_script_path>\zabbix_postgresql.vbs "<postgresql_bin_path>" db_fetched $1
			UserParameter=psql.db.inserted[*],%systemroot%\system32\cscript.exe /nologo /T:30 <zabbix_script_path>\zabbix_postgresql.vbs "<postgresql_bin_path>" db_inserted $1
			UserParameter=psql.db.updated[*],%systemroot%\system32\cscript.exe /nologo /T:30 <zabbix_script_path>\zabbix_postgresql.vbs "<postgresql_bin_path>" db_updated $1
			UserParameter=psql.db.deleted[*],%systemroot%\system32\cscript.exe /nologo /T:30 <zabbix_script_path>\zabbix_postgresql.vbs "<postgresql_bin_path>" db_deleted $1
			UserParameter=psql.db.commited[*],%systemroot%\system32\cscript.exe /nologo /T:30 <zabbix_script_path>\zabbix_postgresql.vbs "<postgresql_bin_path>" db_commited $1
			UserParameter=psql.db.rolled[*],%systemroot%\system32\cscript.exe /nologo /T:30 <zabbix_script_path>\zabbix_postgresql.vbs "<postgresql_bin_path>" db_rolled $1
			UserParameter=psql.db.success[*],%systemroot%\system32\cscript.exe /nologo /T:30 <zabbix_script_path>\zabbix_postgresql.vbs "<postgresql_bin_path>" db_success $1

5. Import **zbx-windows-postgresql.xml** file into Zabbix.
6. Associate **ZBX-WINDOWS-POSTGRESQL** template to the host.

### Requirements

This template was tested for Zabbix 2.0.0 and higher.

##### [Zabbix agent](http://www.zabbix.com) 2.0.x
##### [zabbix_postgresql.vbs](https://github.com/jjmartres/Zabbix/tree/master/zbx-templates/zbx-windows/zbx-windows-postgresql/zabbix_postgresql.vbs) 1.0

License
-------

This template is distributed under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the  License, or (at your option) any later version.

### Copyright

  Copyright (c) 2013 Alik Kurdyukov

### Authors

  Alik Kurdyukov
  (akurdyukov |at| gmail |dot| com)
  Kravchuk S.V.
  (alfss.obsd |at| gmail |dot| com)
