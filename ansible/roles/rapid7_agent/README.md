# Rapid7 Agent Install
Ansible role for installing the Rapid7 Agent.  Will work on RedHat, CentOS, Rocky, and SUSE/SLES.

Requirement
------------

Required Variables
------------------
### r7_agent:
- Default values - agent_installer-3.2.3.7.sh
- Description - This is the latest version of the Rapid7 Agent. 

### r7_token:
- Default values - us:6a78c155-e528-49d3-b5d4-6bb98614a40f
- Description - This is the Hy-Vee customer ID needed to register the Rapid7 Agent. 

### artifactory:
- Default values - https://artifactory.prod.hy-vee.cloud/artifactory
- Description - This is the artifactory repo where packages are stored.

Optional Variables
------------------

Dependencies
------------

Example Playbook
----------------
```yaml
---
- hosts: all
  gather_facts: true

- hosts: all
  gather_facts: false
  roles:
    - role: rapid7_agent
...
```
License
-------

MIT

Author Information
------------------

Developled by - awickham@hy-vee.com, Hy-Vee inc.
Expanded by - jiovanni.tapia@hy-vee.com, Hy-Vee inc.
