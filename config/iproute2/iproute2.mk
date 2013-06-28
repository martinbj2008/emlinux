include ../env.mk
ROOTDIR=$(DESTDIR)

# Path to db_185.h include
DBM_INCLUDE:=$(ROOTDIR)/usr/include

SHARED_LIBS = y

DEFINES= -DRESOLVE_HOSTNAMES -DLIBDIR=\"$(LIBDIR)\"
ifneq ($(SHARED_LIBS),y)
DEFINES+= -DNO_SHARED_LIBS
endif

#options if you have a bind>=4.9.4 libresolv (or, maybe, glibc)
LDLIBS=-lresolv
ADDLIB=

#options for decnet
ADDLIB+=dnet_ntop.o dnet_pton.o

#options for ipx
ADDLIB+=ipx_ntop.o ipx_pton.o

CC = gcc
HOSTCC = gcc
DEFINES += -D_GNU_SOURCE
CCOPTS = -O2
WFLAGS = -Wall -Wstrict-prototypes
CFLAGS = $(WFLAGS) $(CCOPTS) -I../include $(DEFINES)
YACCFLAGS = -d -t -v

SUBDIRS=lib ip tc bridge misc netem genl man

LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
LDLIBS += $(LIBNETLINK)

all: 
	make -C lib
	make -C ip

install:
	@cp -v ip/ip ${ROMFS_ROOT}/sbin/.

.EXPORT_ALL_VARIABLES:
