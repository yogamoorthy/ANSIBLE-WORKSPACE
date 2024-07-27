# snapshot
Ansible role for creating, and deleting, snapshots.\
***Currently, this does not support managing snapshots in the EFT Vsphere.*

Requirement
------------
- PyVmomi
- pypsrp
- pykerberos
- requests
- requests-kerberos

Required Variables
------------------
### input:
- Default values - add
- Possible values - 'add, remove, OR create, delete'
- Description - 'add' or 'create' will create a snapshot for the specified VM. 'remove' or 'delete' will delete all snapshots on the specified VM.

### snapshot_name:
- Default values - "Maintenance"
- Possible values - 'any'
- Description - 'The name of the snapshot.'

### snapshot_description:
- Default values - "Before server maintenance"
- Possible values - 'any'
- Description - 'The description of the snapshot.'

Optional Variables
------------------
### jenkins:
- Default values - "False"
- Possible values - 'True', 'False'
- Description - 'This is used in the snapshot_cleanup Jenkins job. This deletes snapshots greater than, or equal to, 7 days.'

Dependencies
------------

Example Playbook
----------------
```yaml
---
- hosts: example
  gather_facts: true

- hosts: example
  gather_facts: false
  roles:
    - role: snapshot
  vars: 
    input: add
    snapshot_name: "Maintenance"
    snapshot_description: "Before server maintenance"
...
```
License
-------

MIT

Author Information
------------------

Developled by - wmclean@hy-vee.com, Hy-Vee, inc. & jricheson@hy-vee.com, Hy-vee inc.\
Expanded by - jiovanni.tapia@hy-vee.com, Hy-Vee inc.
