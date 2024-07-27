# ssh_keys

- Manage and deploy ssh keys. 

## supported platforms

- CentOS
- RedHat
- SUSE

## Role Variables

- ssh_users: any additional groups that need access go here

## Manages
- User authorized_keys

## Role Dependencies
- sshd
- active_directory_client

## Example playbook
```yaml
- hosts: all
  roles:
    - role: ssh_keys
  vars:
    sshd_users: 'Administrators'
    default_ssh_admins: 'linux-admins'
  become: yes
  become_user: root
```

### Author Information
- Andrew Wickham
- awickham@hy-vee.com
