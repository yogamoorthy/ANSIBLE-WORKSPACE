# auditd

- Installs and manages auditd services as well as enforcing configuration files.

## supported platforms

- CentOS
- RedHat
- SLES
- Debian

## Role Variables

## Manages

- auditd (service)
- auditd.conf
- audit.rules

## Role Dependencies

- DNS
- yum/zipper

## Example Playbook

```yaml
- hosts: all
  sudo: yes
  roles:
    - role: auditd
```
### Author Information

- Andrew Wickham
- awickham@hy-vee.com
