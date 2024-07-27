#!/usr/bin/env bash

admin_user="scopeadm"

mip_name="{{ gro_mip_name }}"
mda_name="{{ gro_mda_name }}"
wm_name="{{ gro_wm_name }}"
lm_name="{{ gro_lm_name }}"
db_name="{{ gro_db_name }}"

env_override="gro"

manh_home="/manh/apps/scope/gro"

wm_db_username="nagios"
wm_db_servicename="{{ gro_wm_db_servicename }}"
wm_db_schemaname="{{ gro_wm_db_schemaname }}"
wm_db_pass="{{ gro_wm_db_pass }}"
wm_db_salt="{{ gro_wm_db_salt }}"
wm_env="{{ gro_wm_env }}"

VOCOLLECT_PORT="{{ gro_vocollect_port }}"
PARTNER_NODE="{{ partner_node }}"

VOCOLLECT_ENDPOINT_ID="{{ vocollect_endpoint_id }}"
