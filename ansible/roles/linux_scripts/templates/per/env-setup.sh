#!/usr/bin/env bash

admin_user="scopeadm"

mip_name="{{ per_mip_name }}"
mda_name="{{ per_mda_name }}"
wm_name="{{ per_wm_name }}"
lm_name="{{ per_lm_name }}"
db_name="{{ per_db_name }}"

env_override="per"

manh_home="/manh/apps/scope/per"

wm_db_username="nagios"
wm_db_servicename="{{ per_wm_db_servicename }}"
wm_db_schemaname="{{ per_wm_db_schemaname }}"
wm_db_pass="{{ per_wm_db_pass }}"
wm_db_salt="{{ per_wm_db_salt }}"
wm_env="{{ per_wm_env }}"

VOCOLLECT_PORT="{{ per_vocollect_port }}"
PARTNER_NODE="{{ partner_node }}"

VOCOLLECT_ENDPOINT_ID="{{ vocollect_endpoint_id }}"
