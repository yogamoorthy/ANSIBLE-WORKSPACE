#!/usr/bin/env python

import requests
import argparse

def get_info(session, hostname, app_name, get_status=False, get_context=False ):
    response = session.get('http://' + hostname + ':8080' + '/manager/text/list', timeout=180)

    for line in response.text.split('\n'):
        if app_name in line:
            if get_status:
                result = line.split(':')[1]
            elif get_context:
                result = line.split(':')[3]
            else:
                print('Provide bool get_status or get_context')
            return result

def tomcat_action(context, action, session, hostname):
    response = session.get('http://' + hostname + ':8080' + '/manager/text/' + action + '?path=/' + context, timeout=480)

    cmd_response = response.text
    return cmd_response

def main(application_name, username, password, hostname, action):
    session = requests.Session()
    session.auth = (username, password)
    context = get_info(session, hostname, application_name, get_context=True)

    if action == 'status':
        status = get_info(session, hostname, application_name, get_status=True)
        print('{} is {}'.format(application_name, status))
    elif action == 'start':
        cmd_response = tomcat_action(context, action, session, hostname)
        print(cmd_response.rstrip())
    elif action == 'stop':
        cmd_response = tomcat_action(context, action, session, hostname)
        print(cmd_response.rstrip())
    elif action == 'restart':
        cmd_stop_response = tomcat_action(context, 'stop', session, hostname)
        print(cmd_stop_response.rstrip())
        cmd_start_response = tomcat_action(context, 'start', session, hostname)
        print(cmd_start_response.rstrip())
    elif action == 'reload':
        cmd_response = tomcat_action(context, action, session, hostname)
        print(cmd_response.rstrip())
    elif action == 'undeploy':
        cmd_response = tomcat_action(context, undeploy, session, hostname)
        print(cmd_response.rstrip())
    else:
        print('Nothing was triggered')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--app',  help="The name of the GK Tomcat application", required="true")
    parser.add_argument('--username',  help="The User Account for Tomcat Manager tool", required="true")
    parser.add_argument('--password',  help="The Password for the Tomcat Manager", required="true")
    parser.add_argument('--hostname',  help="The FQDN of the Server running Tomcat Service", required="true")
    parser.add_argument('--action',  help="This is one of the following options status, start, stop, restart, reload, undeploy.")
    args = parser.parse_args()

    main(args.app, args.username, args.password, args.hostname, args.action)