SHELL = /bin/bash

MYDIR = $(DESTDIR)/usr/lib/tmpfiles.d
SUBDIRS =
BINS =
CONFS = gentoo-vdr-scripts.conf

all:

install:
	@install -m 0755 -o root -g root -d $(MYDIR)
	@install -m 0644 -o root -g root $(CONFS) $(MYDIR)

.PHONY: all install
