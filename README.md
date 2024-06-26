# Ansible Scripts for ILRI Research-Computing Infrastructure
In order for these playbooks to work, your host must:

- have finished installation, have working networking, have an SSH daemon running
- have added a `provisioning` user via kickstart, preseed, or cloud-init
- have an entry in the `private/hosts`
- have a vars file in `host_vars/` which defines _at least_ an `ansible_host` variable

Assuming the above are true, you should be able to run these playbooks successfully.

## Post-install Ansible Invocation
Take note that the first-ever invocation after the clean installation of a machine is different than subsequent invocations due to the way SSH public keys are copied to the host.

On the first run, you need to use `-k --ask-become-pass` to prompt for the SSH/sudo password of the provisioning user:

    $ ansible-playbook site.yml --limit=ilrinrb10 -k --ask-become-pass -t sshd,ssh-keys,sudoers

On subsequent runs, after SSH keys and sudo configurations have been deployed, you should be able to run like this:

    $ ansible-playbook site.yml --limit=ilrinrb10

## TODO

- Update: sysctl.conf template for Ubuntu, using CentOS template as a reference
- Update: make SSH rate limits configurable

## License
Copyright (C) 2015–2024 International Livestock Research Institute (ILRI)

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
