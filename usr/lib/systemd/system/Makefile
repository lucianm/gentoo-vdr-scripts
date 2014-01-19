# $ID: $

SHELL = /bin/bash

MYDIR = $(DESTDIR)/usr/lib/systemd/system
SUBDIRS =
BINS =
CONFS = vdr.service

all:

install:
	@install -m 0755 -o root -g root -d $(MYDIR)
	@install -m 0644 -o root -g root $(CONDS) $(MYDIR)

.PHONY: all install
