#!/usr/bin/env python

import argparse
import gk_info

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--app',  help="The name of the GK Tomcat application", required=True)
    parser.add_argument('--atar',  help="The install tarball", required=False)
    args = parser.parse_args()

    gkData = gk_info.AppInfo(args.app, args.atar)
    gkData.getInfo()
    print(gkData.results)