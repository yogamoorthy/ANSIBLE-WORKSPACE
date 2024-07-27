# Crowdstrike
Ansible role for crowdstrike installation.  Will work on RedHat/CentOS, Debian, and SUSE/SLES.

Requirement
------------
The CrowdStrike packages are distro-specific. \
*RHEL/CentOS* - 'falcon-sensor-7.17.0-17005.el$VERSION.x86_64.rpm' \
*SUSE/SLES* - 'falcon-sensor-7.17.0-17005.suse12.x86_64.rpm' \
*Debian/Ubuntu* - 'falcon-sensor_7.17.0-17005_amd64.deb'

The $VERSION for RHEL/CentOS will automatically be determined during the Ansible play.

Servers must have 80/443 firewall access to the following URLs: \
ts01-b.cloudsink.net \
lfodown01-b.cloudsink.net \
lfoup01-b.cloudsink.net \
falcon.crowdstrike.com \
assets.falcon.crowdstrike.com \
assets-public.falcon.crowdstrike.com \
api.crowdstrike.com

Required Variables
------------------
### cid:
- Default values - 888369C970B245BC800C3B60DEFBAFB2-3F
- Description - This is the Hy-Vee customer ID needed to register the CrowdStrike/Falcon-sensor product.

### artifactory:
- Default values - https://artifactory.prod.hy-vee.cloud/artifactory
- Description - This is the artifactory repo where packages are stored.

### rhel7_package:
- Default values - falcon-sensor-7.17.0-17005.el7.x86_64.rpm
- Description - This tells Ansible which package to install. This variable will be updated as new versions of the falcon-sensor are released.

### rhel8_package: 
- Default values - falcon-sensor-7.17.0-17005.el8.x86_64.rpm
- Description - This tells Ansible which package to install. This variable will be updated as new versions of the falcon-sensor are released.

### rhel9_package: 
- Default values - falcon-sensor-7.15.0-16803.el9.x86_64.rpm
- Description - This tells Ansible which package to install. This variable will be updated as new versions of the falcon-sensor are released.

### suse_package:
- Default values - falcon-sensor-7.17.0-17005.suse12.x86_64.rpm
- Description - This tells Ansible which package to install. This variable will be updated as new versions of the falcon-sensor are released.

### deb_package: 
- Default values - falcon-sensor_7.17.0-17005_amd64.deb
- Description - This tells Ansible which package to install. This variable will be updated as new versions of the falcon-sensor are released.

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
    - role: crowdstrike
...
```
License
-------

MIT

Author Information
------------------

tony.welder@hy-vee.com, Hy-Vee inc.\
jiovanni.tapia@hy-vee.com, Hy-Vee inc.
