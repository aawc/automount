#!/bin/bash

set -eu

DEBUG_=0
PREFIX_FILE_="remote_prefix.txt"

function Printf()
{
  if [ $DEBUG_ -eq 1 ]; then
    printf "$@"
  fi
}

function MountDirsFromMachineInDir()
{
  if [ $# -ne 2 ]; then
    Printf "Wrong arguments\n"
    Printf "Expected: %s <baseDirectory> <remoteMachine>\n" $0
    Printf "Example: %s %s %s\n" $0 $PWD "myremotemachine.exmaple.com"
    return
  fi

  local baseDirectory="${1}"
  Printf "baseDirectory: %s\n" "${baseDirectory}"
  local remoteMachine="${2}"
  Printf "remoteMachine: %s\n" "${remoteMachine}"
  if [ ! -d "${baseDirectory}" ]; then
    Printf "Error: no directory exists at: %s\n" "${baseDirectory}"
    return
  fi
  local fullRemoteMachineDirectory="${baseDirectory}/${remoteMachine}"
  Printf "fullRemoteMachineDirectory: %s\n" "${fullRemoteMachineDirectory}"
  if [ ! -d "${fullRemoteMachineDirectory}" ]; then
    Printf "Error: no directory exists at: %s\n" "${fullRemoteMachineDirectory}"
    return
  fi

  for directoryToMount in \
    $(find "${fullRemoteMachineDirectory}" -type d -links 2); do
    Printf "Need to mount: %s\n" "${directoryToMount}"
    local remotePath="${directoryToMount#$fullRemoteMachineDirectory}"
    Printf "remotePath: %s\n" "${remotePath}"

    local command="umount ${directoryToMount}"
    Printf "Executing: %s\n" "${command}"
    ${command} || [ $? -eq 1 ];

    local sshfsOpt="-oauto_cache,reconnect,defer_permissions,noappledouble,workaround=rename"
    local remotePrefix="$(cat ${fullRemoteMachineDirectory}/${PREFIX_FILE_})"
    Printf "remotePrefix: %s\n" "${remotePrefix}"
    command="sshfs ${USER}@${remoteMachine}:${remotePrefix}/${remotePath} \
      ${directoryToMount} ${sshfsOpt}"
    printf "Executing: %s\n" "${command}"
    ${command} || [ $? -eq 1 ];
  done
}

function main()
{
  if [ $# -ne 1 ]; then
    Printf "Wrong arguments\n"
    Printf "Expected: %s <baseDirectory>\n" $0
    Printf "Example: %s %s\n" $0 $PWD
    return
  fi

  local baseDirectory="${1}"
  if [ ! -d "${baseDirectory}" ]; then
    Printf "Error: no directory exists at: %s\n" "${baseDirectory}"
    return
  fi
  local resolvedBaseDirectory="$(cd ${baseDirectory}; printf '%s' ${PWD})"
  Printf "resolvedBaseDirectory: %s\n" "${resolvedBaseDirectory}"

  for remoteMachineDir in "$(ls -d ${resolvedBaseDirectory}/*/)"; do
    Printf "remoteMachineDir: %s\n" "${remoteMachineDir}"
    local remoteMachineDirBase="$(basename ${remoteMachineDir})"
    Printf "remoteMachineDirBase: %s\n" "${remoteMachineDirBase}"
    MountDirsFromMachineInDir "${resolvedBaseDirectory}" "${remoteMachineDirBase}"
  done;
}

main "$@"
exit

umount /Users/vakh/sshfs/daansi.mtv/work/chrome/src/chrome \
  /Users/vakh/sshfs/daansi.mtv/work/chrome/src/components || [ $? -eq 1 ]

sshfs vakh@daansi.mtv:/usr/local/google/home/vakh/work/chrome/src/chrome \
/Users/vakh/sshfs/daansi.mtv/work/chrome/src/chrome \
-oauto_cache,reconnect,defer_permissions,noappledouble,volname=LOCALVOLUMENAME,workaround=rename

sshfs vakh@daansi.mtv:/usr/local/google/home/vakh/work/chrome/src/components \
/Users/vakh/sshfs/daansi.mtv/work/chrome/src/components \
-oauto_cache,reconnect,defer_permissions,noappledouble,volname=LOCALVOLUMENAME,workaround=rename
