# sudoers

- Manage sudoers files

## supported platforms

- CentOS
- RedHat

## Role Variables

## Manages
- /etc/sudoers
- /etc/sudoers.d/

## Role Dependencies

## Example playbook
```yaml
- hosts: all
  sudo: yes
  roles:
  - role: sudoers
```
### Author Information
- Andrew Wickham
- awickham@hy-vee.com
