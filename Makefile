GIT_ROOT=$(shell git remote show  origin | grep Fetch | awk '{print $$3}' | xargs dirname)
progs=busybox iproute2

BASE_ROOT=$(shell pwd)
BUILD_ROOT=$(BASE_ROOT)/build
CFG_ROOT=$(BASE_ROOT)/config
SCRIPT_ROOT=$(BASE_ROOT)/script
ROMFS_ROOT=$(BASE_ROOT)/romfs

KERNEL_ROOT=${BUILD_ROOT}/linux

APPS= linux ${progs}
#strongswan

env_mk=${BUILD_ROOT}/env.mk

all: prepare app romfs image

romfs_basic: 
	rm -fr  ${ROMFS_ROOT}
	@cp -vr $(CFG_ROOT)/romfs .
	@mkdir  -p ${ROMFS_ROOT}/bin
	@mkdir  -p ${ROMFS_ROOT}/sbin
	@mkdir  -p ${ROMFS_ROOT}/boot
	@mkdir  -p ${ROMFS_ROOT}/var
	@mkdir  -p ${ROMFS_ROOT}/sys
	@mkdir  -p ${ROMFS_ROOT}/proc
	@mkdir  -p ${ROMFS_ROOT}/tmp
	@mkdir  -p ${ROMFS_ROOT}/root
	@mkdir  -p ${ROMFS_ROOT}/home/admin/bin
	@mkdir  -p ${ROMFS_ROOT}/update
	@mkdir  -p ${ROMFS_ROOT}/mnt

romfs: romfs_basic
	@for app in ${progs} ; do \
		make -C ${BUILD_ROOT}/$${app} -f $${app}.mk install; \
	done

image: romfs
	@cp -v ${CFG_ROOT}/romfs_cpio.desc ${KERNEL_ROOT}
	sh ${SCRIPT_ROOT}/romfs2cpio_list.sh ${ROMFS_ROOT} >> ${KERNEL_ROOT}/romfs_cpio.desc
	make -C ${KERNEL_ROOT} bzImage

prepare:
	mkdir -p ${BUILD_ROOT}
	@( \
	echo CFG_ROOT=${CFG_ROOT}; \
	echo BASE_ROOT=${BASE_ROOT}; \
	echo BUILD_ROOT=${BUILD_ROOT}; \
	echo SCRIPT_ROOT=${SCRIPT_ROOT}; \
	echo ROMFS_ROOT=${ROMFS_ROOT}; \
	echo GIT_ROOT=${GIT_ROOT}; \
	echo LOCAL_GIT_ROOT=${HOME}/git; \
	echo APPS=\"${APPS}\"; \
	) > ${env_mk}
	sh ${SCRIPT_ROOT}/prepare.sh  ${env_mk}

app:
	@for app in ${APPS} ; do \
		make -C ${BUILD_ROOT}/$${app} -f $${app}.mk; \
	done

%_only:
	@echo "making $@" ;
	make -C build/$(patsubst %_only,%,$@) -f $(patsubst %_only,%,$@).mk || exit 1;
	make -C build/$(patsubst %_only,%,$@) -f $(patsubst %_only,%,$@).mk install || exit 1;
	make image
