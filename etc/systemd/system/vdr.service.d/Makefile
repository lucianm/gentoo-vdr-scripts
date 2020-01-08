SHELL = /bin/bash

MYDIR = $(DESTDIR)/etc/systemd/system/vdr.service.d
SUBDIRS =
BINS =
CONFS = 00-gentoo-vdr-user.conf

all:

install:
	@install -m 0755 -o root -g root -d $(MYDIR)
	@install -m 0644 -o root -g root $(CONFS) $(MYDIR)

.PHONY: all install
