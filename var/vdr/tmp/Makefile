#$Id: $

SHELL = /bin/bash

MYDIR = $(DESTDIR)/var/vdr/tmp
SUBDIRS =
BINS =
CONFS = systemd_env plugins_skipped_ALL

all:

install:
	@install -m 0755 -o root -g root -d $(MYDIR)
	@install -m 0644 -o vdr -g vdr $(CONFS) $(MYDIR)

.PHONY: all install
