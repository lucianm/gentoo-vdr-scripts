# $Id$

SHELL = /bin/bash

MYDIR = $(DESTDIR)/etc/vdr/reccmds
SUBDIRS =
BINS =
CONFS = $(wildcard reccmds.*.conf*)

all:

install:
	@install -m 0755 -o vdr -g vdr -d $(MYDIR)
	#install -m 0755 -o vdr -g vdr $(BINS) $(MYDIR)
	@install -m 0644 -o vdr -g vdr $(CONFS) $(MYDIR)
	@for DIR in $(SUBDIRS); do \
		$(MAKE) -C $$DIR install; \
	done

.PHONY: all install
