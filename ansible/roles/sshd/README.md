# sshd

- Manage ssh configuration and groups accessible to servers

## supported platforms

- CentOS
- RedHat
- Rocky
- SUSE
- Debian

## Role Variables

- default_ssh_admins: This is default set for linux-admins 
- ssh_users: any additional groups that need access go here

## Manages
- sshd (service3)
- sshd_config

## Role Dependencies
- DNS
- active_directory_clients

## Example playbook
```yaml
- hosts: all
  sudo: yes
  vars:
    sshd_users: 'Administrators'
    default_ssh_admins: 'linux-admins'
  roles:
  - role: sshd
```

### Bypass AD-Join - for templating

```yaml
- hosts: all
  sudo: yes
  vars:
    sshd_users: 'Administrators'
    default_ssh_admins: 'linux-admins'
    ad_action: 'bypass'
  roles:
  - role: sshd
```

### Author Information
- Andrew Wickham
- awickham@hy-vee.com
