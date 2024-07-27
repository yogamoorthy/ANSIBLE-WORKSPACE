#!/usr/bin/env python

import os, glob, re, tarfile

class AppInfo():
    gk_directory = '/usr/local/gkretail'
    local_gk_directory = '/usr/local/gkretail_local'
    station_path = '/usr/local/gkretail/basecomponents/sm.hybridinfoserver/config/stations'

    def __init__(self, appName, aTar=None):
        self.appName = appName
        self.aTar = aTar
        self.results = {}

    def getInfo(self):
        self._home()
        self._context()
        self._station()
        self._version()
        self._installer_file()
        self._installer_version()
        self._can_update()
        return self.results

    def _home(self):
        if self.appName in os.listdir(AppInfo.gk_directory):
            self.results['home'] = home = AppInfo.gk_directory + '/' + self.appName
        elif self.appName == 'ec':
            self.results['home'] = AppInfo.gk_directory + '/ec.server'
        elif self.appName in os.listdir(AppInfo.local_gk_directory):
            self.results['home'] = home = AppInfo.local_gk_directory + '/' + self.appName
        else:
            raise Exception('{} Home not found'.format(self.appName))

    def _context(self):
        context_full_path = glob.glob(self.results['home'] + '/setup/*' + self.appName + '.xml')
        self.results['context'] = str(context_full_path).strip('[]\'').split('/')[6].split('.')[0]

    def _station(self):
        if not os.listdir(AppInfo.station_path):
            self.results['station'] = None
        else:
            for station_file in os.listdir(AppInfo.station_path):
                with open(AppInfo.station_path + '/' + station_file) as open_file:
                    if self.appName == 'med':
                        # OK, I really hate this, there are 3 station files for med.
                        # the first file it picks up has just a v for the version.
                        # going to find a better way to parse this.
                        self.results['station'] = 'ROOT.ENTERPRISE.ENTERPRISE_CENTRAL.Menu_Editor.properties'
                    elif self.results['home'] in open_file.read():
                        self.results['station'] = station_file
                        break
                    else:
                        self.results['station'] = None

    def _version(self):
        try:
            station_full_path = AppInfo.station_path + '/' + str(self.results['station'])
            try:
                for line in open(station_full_path):
                    if 'info.version' in line:
                        self.results['current_version'] = line.split('=')[1].rstrip()
            except IOError:
                self.results['current_version'] = None
        except KeyError:
            self.results['current_version'] = None

    def _installer_file(self):
        try:
            with tarfile.open(self.aTar, 'r') as tar_file:
                search_regex = "(.)" + re.escape(self.appName) + "(.*).jar"
                for tarinfo in tar_file:
                    if re.search(search_regex, tarinfo.name):
                        tar_raw = tarinfo.name
                        self.results['installer_file'] = tar_raw.split('/')[-1]
                        break
                    else:
                        self.results['installer_file'] = None
        except (ValueError, TypeError):
            self.results['installer_file'] = None

    def _installer_version(self):
        try:
            self.results['installer_version'] = 'v' + re.search('[0-9].[0-9].[0-9]-b[0-9][0-9]', self.results['installer_file']).group(0)
        except TypeError:
            self.results['installer_version'] = None

    def _can_update(self):
        try:
            base_version_regex = '(?:[0-9][0-9].[0-9].[0-9]|[0-9].[0-9].[0-9])'
            alpha_beta_regex = '(?:-b[0-9][0-9]|.b[0-9][0-9])'
            alpha_beta_ver_regex = '[0-9][0-9]'
            versions = {
                'current_version':
                    {
                        'base_version': re.search(base_version_regex, self.results['current_version']).group(0),
                        'raw_version': self.results['current_version'],
                        'alpha_beta': 00,
                        'major': 0,
                        'minor': 0,
                        'patch': 0,
                    },
                'incoming_version':
                    {
                        'base_version': re.search(base_version_regex, self.results['installer_version']).group(0),
                        'raw_version': self.results['installer_version'],
                        'alpha_beta': 00,
                        'major': 0,
                        'minor': 0,
                        'patch': 0,
                    }
            }

            for key, value in versions.items():
                for name, number in value.items():
                    if name == 'base_version' or name == 'raw_version':
                        pass
                    elif name == 'alpha_beta':
                        try:
                            alpha_beta_version = re.search(alpha_beta_regex, versions[key]['raw_version']).group(0)
                        except AttributeError:
                            alpha_beta_version = '00'
                        versions[key][name] = re.search(alpha_beta_ver_regex, alpha_beta_version).group(0)
                    elif name == 'major':
                        versions[key][name] = re.split('\.', versions[key]['base_version'])[0]
                    elif name == 'minor':
                        versions[key][name] = re.split('\.', versions[key]['base_version'])[1]
                    elif name == 'patch':
                        versions[key][name] = re.split('\.', versions[key]['base_version'])[2]

            if versions['incoming_version']['alpha_beta'] > versions['current_version']['alpha_beta'] or \
                versions['incoming_version']['patch'] > versions['current_version']['patch']:
                self.results['can_update'] = True
            else:
                self.results['can_update'] = False

        except TypeError:
            self.results['can_update'] = False