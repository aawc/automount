# automount

## Overview

I wrote this simple script to automate the mounting of directories from one of more remote machines. It deduces the directories to mount from the remote machine by looking at the directory structore on the local machine.

```
automount.sh <BaseDirectoryOnLocalMachine>
```

where ```<BaseDirectoryOnLocalMachine>``` refers to the base directory on the local machine that contains sub-directories with names such as ```<HostName1>```, ```<HostName2>```, ```<HostName3>```.

The script looks for leaf folders under each of the hostname directories listed above and mounts the same path from that hostname.

## Prerequisites

You need [```sshfs```](https://github.com/osxfuse/sshfs) installed.

## Examples

### Example 1

Let's assume that the following directory structure exists on the local machine:

```
├── A/
│   ├── B/
│   │   ├── Hostname_1/
│   │   │   ├── AA/
│   │   │   │   ├── AAA/
│   │   │   ├── EE/
```

```
$ automount.sh /A/B/
```
Invoking ```autmount.sh``` like that leads to the following commands getting executed:

```
$ umount /A/B/HostName_1/AA/AAA
$ mount ${USER}@HostName_1:/AA/AAA /A/B/HostName_1/AA/AAA

$ umount /A/B/HostName_1/EE
$ mount ${USER}@HostName_1:/EE /A/B/HostName_1/EE

```

### Example 2

Let's assume that the following directory structure exists on the local machine:

```
├── A/
│   ├── B/
│   │   ├── Hostname_1/
│   │   │   ├── AA/
│   │   │   │   ├── AAA/
│   │   │   ├── BB/
│   │   │   │   ├── BBA/
│   │   │   │   ├── BBB/
│   │   ├── Hostname_4/
│   │   │   ├── DD/
│   │   │   │   ├── DDA/
│   │   │   │   │   ├── DDAA/
```

```
$ automount.sh /A/B/
```
Invoking ```autmount.sh``` like that leads to the following commands getting executed:

```
$ umount /A/B/HostName_1/AA/AAA
$ mount ${USER}@HostName_1:/AA/AAA /A/B/HostName_1/AA/AAA

$ umount /A/B/HostName_1/BB/BBA
$ mount ${USER}@HostName_1:/BB/BBA /A/B/HostName_1/BB/BBA

$ umount /A/B/HostName_1/BB/BBB
$ mount ${USER}@HostName_1:/BB/BBB /A/B/HostName_1/BB/BBB


$ umount /A/B/HostName_4/DD/DDA/DDAA
$ mount ${USER}@HostName_4:/DD/DDA/DDAA /A/B/HostName_4/DD/DDA/DDAA

```

## ToDo

1. Add documentation about the remote prefix file.
2. Add documentation about the ```DEBUG_``` variable.
3. Better error handling.