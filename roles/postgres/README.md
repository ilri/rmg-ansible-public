# PostgreSQL Role
This role installs and configures the PostgreSQL server from the [official upstream repository](https://www.postgresql.org/download/linux/).

## Configuring
By default, PostgreSQL listens on `127.0.0.1`, but you can override this by setting an IP address with `pg_listen_addresses` in group or host vars.

For example:

```jinja
pg_listen_addresses: 192.168.1.7
```

PostgreSQL uses a [host-based authentication file](http://www.postgresql.org/docs/9.6/static/auth-pg-hba-conf.html) to control how clients are authenticated and which databases they can access. To allow connections from specific ipsets, you need to define a `pg_db_connections` variable containing a list of dictionaries with the connection type, db name, source address, etc.

For example:

```jinja
pg_db_connections:
  - { type: "host", db: "all", user: "all", src_addr: "{{ghetto_ipsets['ilri_nbo_dmz'].src }}", method: "md5" }
```

**NOTE:** this role doesn't create or manage PostgreSQL users/databases—you must create tasks in your playbooks for that purpose.

## OS Family Supported
Tested and working on the following OS versions:

- Ubuntu 18.04
- Ubuntu 20.04
