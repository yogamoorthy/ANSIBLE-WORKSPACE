# ansible-workspace
Workspace for pulling roles and executing Playbooks.

## How to use

### Setup
1. Clone Github Ansible Roles
  * Follow the format in `./ansible/requirements.yml`
2. Construct Playbook
  * Follow the format in `./ansible/site.yml`
3. Setup workspace (downloads inventory and roles)
  * `make setup` or `. ./do/setup`
### Run Playbooks
- Run the base test (check mode)
  - `make test` or `./do/run -c`
- Run the Playbook
  - `make run` or `./do/run` or `./do/run [dev, qa, prod]`
### Cleanup
- Cleanup your workspace
  - `deactivate`
  - `make cleanup` or `./do/cleanup`
- Cleanup workspace but keep Python venv
  - `make prune`
  
