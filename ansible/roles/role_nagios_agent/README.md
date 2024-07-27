Role Nagios Agent
=========

This is the installation for the Nagios Client Install.

Requirements
------------

No Known Requirements.

Role Variables
--------------

No variables.

Dependencies
------------

No Known Dependencies

Example Playbook
----------------


    - hosts: servers
      roles:
         - role: role_nagios_agent
           tags: ['monitoring','nagios_client']

License
-------

BSD

Author Information
------------------

email: wmclean@hy-vee.com
