SHELL = /bin/bash

MYDIR = $(DESTDIR)/usr/share/vdr/rcscript
SUBDIRS =
BINS =
CONFS = $(wildcard *.sh)

all:

install:
	@install -m 0755 -o root -g root -d $(MYDIR)
	#install -m 0755 -o root -g root $(BINS) $(MYDIR)
	@install -m 0644 -o root -g root $(CONFS) $(MYDIR)
	@for DIR in $(SUBDIRS); do \
		$(MAKE) -C $$DIR install; \
	done

.PHONY: all install
