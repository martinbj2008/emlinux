#!/bin/sh
#
# Copyright 2006 6WIND, All rights reserved
#   Vincent.Jardin@6wind.com
# $Id: romfs2cpio_list.sh,v 1.2 2006-09-19 15:04:25 andriot Exp $
#
# Generate a descriptor of cpio file from:
#   the romfs (arg1) + the dev_all.txt (arg2)
# this descriptor can be used be gen_cpio of Linux Kernel 2.6
ROMFSDIR=$1
DEVALL=$2

usage()
{
  echo "$0 romfs/ path/dev_all.txt" >&2
  exit 1
}

# dir <name> <mode> <uid> <gid>
# we assume uid, gid = 0, 0
# arg1 = name of the directory to be added
process_dir()
{
  MODE=`stat -c %a ${ROMFSDIR}/$1`
  echo "dir /$1 ${MODE} 0 0"
}

# slink <name> <target> <mode> <uid> <gid>
# we assume uid, gid = 0, 0
# arg1 = name of the symlink to be added
process_symlink()
{
  MODE=`stat -c %a ${ROMFSDIR}/$1`
  TARGET=`stat -c %N ${ROMFSDIR}/$1  | cut -f 3 -d ' ' | cut -c 2- | cut -f 1 -d "'"`
  echo "slink /$1 ${TARGET} ${MODE} 0 0"
}

# file <name> <location> <mode> <uid> <gid>
# we assume uid, gid = 0, 0
# arg1 = name of the file to be added
process_regfile()
{
  MODE=`stat -c %a ${ROMFSDIR}/$1`
  echo "file /$1 ${ROMFSDIR}/$1 ${MODE} 0 0"
}

is_symlink()
{
  TYPE=`stat -c %f $1`
  if [ "${TYPE}" != "a1ff" ] ; then
    return 1
  fi
  return 0
}

if [ ! -d ${ROMFSDIR} ] ; then
  usage
  exit 1
fi

if [ ! -f ${DEVALL} ] ; then
  usage
  exit 1
fi

echo "# Copyright 2006 6WIND"
echo "# generated with"
echo "#    $0 $1 $2"

# 1/ process romfs/
# list of files without the . characters
LIST_FILE=`cd ${ROMFSDIR} && find . | cut -c 3-`

for i in ${LIST_FILE} ; do
  # -L cannot be used because the symlink exist, but not the file
  if is_symlink ${ROMFSDIR}/$i ; then
    process_symlink $i
    continue
  fi
  if [ -d ${ROMFSDIR}/$i ] ; then
    process_dir $i
    continue
  fi
  if [ -f ${ROMFSDIR}/$i ] ; then
    process_regfile $i
    continue
  fi
  if [ -b ${ROMFSDIR}/$i ] ; then
    # ignore block files TBD??
    continue
  fi
  if [ -c ${ROMFSDIR}/$i ] ; then
    # ignore char files TBD??
    continue
  fi
  echo "[WARNING] Type of $i is unknown" >&2
  echo "[WARNING] Cannot put file $i in ramfs" >&2
  echo "[WARNING] FILE SYSTEM WILL BE INCOMPLETE" >&2
  exit 1
done
