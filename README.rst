------------
Instructions
------------

Preparation
-----------

Before building you first need to download the necessary RPMs from
Oracle for the odbc driver install. We expect the following two files
downloaded from Oracle::

 oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm
 oracle-instantclient12.2-odbc-12.2.0.1.0-1.x86_64.rpm

We've put them in a submodule, if you don't have access to that git repo,
you still need to download them into the subdirectory ``odbc-drivers``.

Configuration
-------------

Most of the configuration is done via the environment, except for
passwords which come in via a bind-mount of the file ``/etc/passwords``.
Some environment variables like ``LD_LIBRARY_PATH`` change only with the
version of the oracle odbc driver and should not be set by the user.
The following variables must be set to the respective database
configuration parameter: ``ORACLE_USER`` -- currently a single user
having access to all oracle databases is asumed, ``ORACLE_HOST`` is the
hostname or IP-address of the oracle database host, ``ORACLE_PORT`` is
the port for access to the oracle database, typically 1521.

In addition to these single-valued variables, the database configuration
is performed with a multi-valued variable ``DATABASE_INSTANCES`` with
the following format::

 DATABASE_INSTANCES=in1:db1,in2:db2,...

where in1, in2 etc. are the instance name in LDAP, while db1, db2 etc
are the database names in oracle. An example would be::

 DATABASE_INSTANCES=ph06:PH06.brz,ph08=PH08.brz,ph10=PH10.brz,ph15=PH15.brz

where in the LDAP DIT the users for ph08 are stored under::

 ou=user,ou=ph08,o=BMUKK

Note: The ``ph00`` in ou=ph08 must match the instance name ``ph08`` in
the ``DATABASE_INSTANCES`` configuration.


Password Configuration
----------------------

Password configuration is performed via the bind-mounted file
/etc/passwords. The database passwords are set in the form::

 DATABASE_PASSWORDS=in1:pw1,in2:pw2,...

where in1 is the name (see above for ``DATABASE_INSTANCES``) of the
database instance and pw1 is the associated password for this instance.
An example would be::

 DATABASE_INSTANCES=ph06:strenggeheim6,ph08:strenggeheim8
