# Compute Role
This role does the following:

- Installs and configures GlusterFS client software and mounts home, apps, and data directories
- Installs and configure [slurm](http://slurm.schedmd.com)
- Installs various dependencies used by [bioinformatics software](http://hpc.ilri.cgiar.org/list-of-software) used on the cluster
- Installs the `environment-modules` package and add modulefiles from the [HPC environment modules repository](https://github.com/ilri/hpc-environment-modules)

## OS Families Supported
Developed for CentOS 6 and adapted for CentOS 7.
