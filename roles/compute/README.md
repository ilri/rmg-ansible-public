# Compute Role
This role does the following:

- Installs and configures GlusterFS client software and mounts home, apps, and data directories
- Installs and configures [SLURM](https://slurm.schedmd.com)
- Installs various dependencies used by [bioinformatics software](https://hpc.ilri.cgiar.org/list-of-software) used on the cluster
- Installs the `environment-modules` package and adds modulefiles from the [HPC environment modules repository](https://github.com/ilri/hpc-environment-modules)

## OS Families Supported
Developed for CentOS Stream 9.
