#!/bin/bash

xclip -h > /dev/null  2>&1

if [ "$?" != "0" ]; then
   echo "You need to install xclip"
   exit 1
fi

printf "$(xclip -o)\n" | while read -r line;
do

  #[WARNING]    com.google.code.findbugs:jsr305:jar:3.0.2:compile
  clean_line=$(echo "${line}" | sed -e 's|\[WARNING\]\s*||g' )
  groupId=$(echo "${clean_line}" | cut -d: -f1)
  artifactId=$(echo "${clean_line}" | cut -d: -f2)
  #artifactType=$(echo "${clean_line}" | cut -d: -f3)
  #version=$(echo "${clean_line}" | cut -d: -f4)

  indent="  "
  version=
  versionEntry=

  if [ "${groupId}" = "com.gene42.phenotips.components" ]; then
     version="\${project.version}"
     groupId="\${components.groupId}"
  elif [ "$(echo "${groupId}" | grep "org.xwiki.")" ]; then
     version="\${xwiki.version}"
  elif [ "${groupId}" = "com.gene42.commons" ]; then
     version="\${commons.version}"
  fi


  artifactIdEntry="${indent}<artifactId>${artifactId}</artifactId>\n"
  groupIdEntry="${indent}<groupId>${groupId}</groupId>\n"

  if [ "${version}" ]; then
     versionEntry="${indent}<version>${version}</version>\n"
  fi

  printf "<dependency>\n${groupIdEntry}${artifactIdEntry}${versionEntry}</dependency>\n"
done

