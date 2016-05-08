#!/bin/bash
while true; do

name=$(repo sync 2>&1|grep 'remove-project element specifies non-existent project'|cut -d ':' -f 3|tr -d ' ')
if [[ q"$name" == q ]]; then
  echo Cleaning project-objects
  list=$(cat .repo/local_manifests/cleanup.xml |cut -d '"' -f 2|sort|grep -v '>')
  for project in $list; do
    project_path=$(dirname "$project")
    if [ -d .repo/project-objects/${project}.git ] ; then
      mkdir -p "../moved/$project_path"
      echo Moving .repo/project-objects/${project}.git to ../moved/${project_path}
      mv .repo/project-objects/${project}.git ../moved/${project_path}
    else
      if [ -d ../moved/$(basename ${project}).git ]; then
        echo "Found ../moved/$(basename ${project}).git"
        mv "../moved/$(basename ${project}).git" "../moved/${project_path}"
      else
        if [ -d "../moved/${project}.git" ]; then
          echo "$project already moved"
        else
          echo "${project}.git not found!"
        fi
      fi
    fi
  done
  echo Cleaned!
  exit
fi
echo "Found bad repo $name"
grep -v "$name" .repo/local_manifests/cleanup.xml > /tmp/cleanup.xml
mv /tmp/cleanup.xml .repo/local_manifests/cleanup.xml -f

done
