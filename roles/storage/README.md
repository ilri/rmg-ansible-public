# Storage Role
This role configures a host as either a storage client or a storage server depending on the value of a host or group's `glusterfs_role` variable.

## GlusterFS Client
To specify a host as a storage client, you need to assign the value `client` to `glusterfs_role` variable in `host_vars/$hostname` or in `group_vars/$groupname`.

The following tasks are carried out on storage clients:
  - Install glusterfs-fuse package
  - Create mount points for glusterfs volumes
  - Mount glusterfs volumes
  - Configure SELinux boolean to allow home dirs on fuse mount points

To create mount points and mount volumes, you need to define the `glusterfs_mounts` variable, which is a list of one or more dictionaries containing mount points and volume details.

You can define the `glusterfs_mounts` variable in your `host_vars` or `group_vars` For example:

```jinja
    glusterfs_mounts:
       - { mount_point: '/export/data', mount_src: 'wingu1:data', mount_fs: 'glusterfs', mount_opts: 'defaults,acl,_netdev,backupvolfile-server=wingu0', mount_state: 'mounted', owner: 'root', group: 'root', mode: '0755', state: 'directory' }
```

## GlusterFS Server
To specify a host as a storage server, you need to assign the value `server` to `glusterfs_role` in `host_vars/$hostname` or in `group_vars/$groupname`. This will install the glusterfs-server package along with its dependencies and a few other disk utilities. It does not configure GlusterFS — you will need to go to the server(s) and do this manually!

# OS Family Supported
- CentOS Stream 8
