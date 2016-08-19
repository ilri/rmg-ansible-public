## Storage Role
- This role configures a host as either a storage client or a storage
server depending on the value of `glusterfs_role` variable.

### Storage client
- To specify a host as a storage client, you need to assign the value
`client` to `glusterfs_role`variable i.e. `glusterfs_role = client`
in `host_vars/$hostname` or in `group_vars/$groupname`
- The following tasks are carried out on storage clients:
    - Add glusterfs-epel yum repo
    - Install glusterfs-fuse package
    - Create mount points for glusterfs volumes
    - Mount glusterfs volumes
    - Configure SELinux boolean to allow home dirs on fuse mount points
- To create mount points & mount volumes, you need to define
`glusterfs_mounts` variable which is a list of dictionaries containing
mount point(s) & volume(s) details.
- You can define `glusterfs_mounts` variable in your `host_vars` or
`group_vars` For example:
```jinja
    glusterfs_mounts:
       - { mount_point: '/export/data', mount_src: 'wingu1:data', mount_fs: 'glusterfs', mount_opts: 'defaults,acl,_netdev,backupvolfile-server=wingu0', mount_state: 'mounted', owner: 'root', group: 'root', mode: '0755', state: 'directory' }
```

### Glusterfs server
- To specify a host as a storage server, you need to assign the value
`server` to `glusterfs_role` variable i.e. `glusterfs_role = server`
in `host_vars/$hostname` or in `group_vars/$groupname`
- The following tasks are carried out on storage servers:
    - Add glusterfs-epel yum repo
    - Install glusterfs-server package

## OS Family Supported
- CentOS 6.5/6.6
