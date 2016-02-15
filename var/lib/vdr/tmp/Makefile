SHELL = /bin/bash

MYDIR = $(DESTDIR)/var/lib/vdr/tmp
SUBDIRS =
BINS =
CONFS = systemd_env

all:

install:
	@install -m 0755 -o vdr -g vdr -d $(MYDIR)
	@install -m 0644 -o vdr -g vdr $(CONFS) $(MYDIR)

.PHONY: all install
