#!/usr/bin/env bash

admin_user="{{ admin_user }}"

mip_name="{{ mip_name }}"
mda_name="{{ mda_name }}"
wm_name="{{ wm_name }}"
lm_name="{{ lm_name }}"
db_name="{{ db_name }}"

manh_home="{{ manh_base | default('/manh/apps/scope') }}"

wm_db_username="nagios"
wm_db_servicename="{{ wm_db_servicename }}"
wm_db_schemaname="{{ wm_db_schemaname }}"
wm_db_pass="{{ wm_db_pass }}"
wm_db_salt="{{ wm_db_salt }}"
wm_env="{{ wm_env }}"

VOCOLLECT_PORT="{{ vocollect_port }}"
PARTNER_NODE="{{ partner_node }}"
VOCOLLECT_ENDPOINT_ID="{{ vocollect_endpoint_id }}"
