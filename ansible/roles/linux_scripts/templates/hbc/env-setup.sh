#!/usr/bin/env bash

admin_user="scopeadm"

mip_name="{{ hbc_mip_name }}"
mda_name="{{ hbc_mda_name }}"
wm_name="{{ hbc_wm_name }}"
lm_name="{{ hbc_lm_name }}"
db_name="{{ hbc_db_name }}"

env_override="hbc"

manh_home="/manh/apps/scope/hbc"

wm_db_username="nagios"
wm_db_servicename="{{ hbc_wm_db_servicename }}"
wm_db_schemaname="{{ hbc_wm_db_schemaname }}"
wm_db_pass="{{ hbc_wm_db_pass }}"
wm_db_salt="{{ hbc_wm_db_salt }}"
wm_env="{{ hbc_wm_env }}"

VOCOLLECT_PORT="{{ hbc_vocollect_port }}"
PARTNER_NODE="{{ partner_node }}"

VOCOLLECT_ENDPOINT_ID="{{ vocollect_endpoint_id }}"
