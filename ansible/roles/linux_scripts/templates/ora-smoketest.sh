#!/bin/bash

function colorOutput() {
  # outputType Expects: [ header|path|content ]
  outputType=$1
  # data: info to be colored and printed to console
  data=$2

  yellow='\033[0;33m'
  cyan='\033[1;36m'
  purple='\033[1;35m'
  poop='\033[1;37m'
  nc='\033[0m'

  case $outputType in
    header)
      echo -e "${yellow}[${nc} ${cyan}${data}${nc} ${yellow}]${nc}";;
    path)
      echo -e "${yellow}[${nc} ${purple}${data}${nc} ${yellow}]${nc}";;
    content)
      echo -e "${data}";;
    *)
      echo -e "${poop}${data}${nc}";;
  esac

}

function pingScanName() {

  # [Source - tnsorafile]
  # 1. Dynamically locate
  # 2. ignore any samples
  tnsOraFile=$(find /manh -name tnsnames.ora | grep -v samples)


  # [Get - Oracle Scan Name]
  # 1. Print tnsames.ora file
  # 2. Locate all Host entries (ie. oracle1-scan.company.com )
  # 3. Dedup the output
  # 4. Pull out 'Host = oracle1-scan.company.com)'
  # 5. Remove the trailing ')'
  # 6. Pull out 'oracle1-scan.company.com'
  # 7. remove whitespace
  oraScanName=$(cat $tnsOraFile | grep HOST | sort -u | awk -F\( '{ print $4 }' | sed 's/)//' | awk -F= '{ print $2 }' | sed 's/ //')


  # [run - tns ping]
  # 1. ping Oracle Scan Name
  # 2. Remove Extra Info
  tnsPingResult=$(tnsping $oraScanName | tail -1)


  echo $tnsPingResult
}

function locateConfig() {
  profileRoot=$(find /manh  -name profile-root)

  for path in $profileRoot; do
    currentApp=$(echo $path | rev | cut -d '/' -f 2 | rev)

    colorOutput header $currentApp

    configDirs=$(find $path -type d -regextype posix-egrep -regex ".*/(configuration|conf|config)" )

    for confDir in $configDirs; do

      content=$(egrep -rnw "db.hostname|db.url" $confDir \
        | sed -e "s|^$confDir/||" \
        | sed -e  "s|:|#|1" -e "s|:|#|1" \
        | column -t -s'#')

      if [ ! -z "$content" ]; then
        colorOutput path $confDir
        echo "$content"
      fi

      unset content

    done

    echo ""

    unset currentApp
  done
}

locateConfig
