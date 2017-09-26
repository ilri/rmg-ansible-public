# Ansible scripts for ILRI research-computing infrastructure
In order for these playbooks to work, your host must:

- have finished installation, have working networking, and an SSH daemon running
- have added a `provisioning` user via kickstart / preseed
- have an entry in the `private/hosts`
- have a var file in `host_vars/` which defines _at least_ an `ansible_host` variable

Assuming the above are true, you should be able to run these playbooks successfully.

## Post-install Ansible invocation
Take note that the first-ever invocation after the clean installation of a machine is different than subsequent invocations due to the way SSH public keys are copied to the host.

On the first run, you need to use `-k --ask-become-pass` to prompt for the SSH/sudo password of the provisioning user:

    ansible-playbook site.yml --limit=ilrinrb10 -k --ask-become-pass

On subsequent runs, after SSH keys have been deployed, you only need `--ask-become-pass` for the sudo password of the provisioning user:

    ansible-playbook site.yml --limit=ilrinrb10 --ask-become-pass

## License
Copyright (C) 2015–2016 International Livestock Research Institute (ILRI)

The contents of this repository are free software: you can redistribute
it and/or modify it under the terms of the GNU General Public License
as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
