# shell_snitch
Shell Snitch is like Bash History, but with greater detail.\
Logs are stored at `/var/log/shell_snitch/ss.log`

Requirement
------------
`rsyslog` OR `syslog-ng` must be installed.

Required Variables
------------------

Optional Variables
------------------

Dependencies
------------
`rsyslog` or `syslog-ng`

Example Playbook
----------------
```yaml
---
- hosts: all
  gather_facts: true

- hosts: all
  gather_facts: false
  roles:
    - role: shell_snitch
  become: true
  become_user: root  
...
```
License
-------

MIT

Author Information
------------------

Developled by - tony.welder@hy-vee.com, Hy-Vee inc.