# aide

 Advanced Intrusion Detection Environment (AIDE)

Requirement
------------

Required Variables
------------------

Optional Variables
------------------

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
    - role: aide
  become: true
  become_user: root
...
```
License
-------

MIT

Author Information
------------------

twelder@hy-vee.com, Hy-Vee, inc.