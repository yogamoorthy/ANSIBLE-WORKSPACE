# rapid7_scan_assistant
Ansible Role for installing and managing Rapid7 Scan Assistant. This is used for running credentialed scans via Rapid7.

Requirement
------------

Required Variables
------------------

### rpm_package:
- Default values - R7ScanAssistant_amd64.rpm
- Description - This tells Ansible which package to install. This variable should be updated as new versions of the Scan Assistant are released.

### deb_package: 
- Default values - R7ScanAssistant_amd64.deb
- Description - This tells Ansible which package to install. This variable should be updated as new versions of the Scan Asisstant are released.

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
    - role: rapid7_scan_assistant
...
```
License
-------

MIT

Author Information
------------------

Developled by - jiovanni.tapia@hy-vee.com, Hy-Vee inc.