## PostgreSQL Role
This role installs & configures postgresql-9.3 server.

By default, postgresql-server listens on `127.0.0.1` but you can
override this by assigning an ip address to `pg_listen_addresses`.
For example to configure postgresql-server to service requests on
the public ip address but you can define the `pg_listen_addresses`
variable in your `host_vars` or `group_vars` i.e.
```jinja
    pg_listen_addresses: 192.168.1.7
```

Postgresql-server uses a [host-based authentication
file](http://www.postgresql.org/docs/9.3/static/auth-pg-hba-conf.html)
to control how clients are authenticated & which databases they can
access. To allow connections from specific ipsets, you need to define
`pg_db_connections` variable which is a list of dictionaries containing
connection type, db names, source addresses e.t.c. You can define
`pg_db_connections` variable in your `host_vars` or `group_vars`.
For example:
```jinja
    pg_db_connections:
      - { type: "host", db: "all", user: "all", src_addr: "{{ghetto_ipsets['ilri_nbo_dmz'].src }}", method: "md5" }
```

> **NOTE**
> This role doesn't create/manage postgresql users and or databases.
> To do so, you need to create tasks in your playbook to manage
> dbs/users.

## OS Family Supported
- Ubuntu 14.04
