# $Id: Makefile 454 2007-05-30 09:56:54Z zzam $

SHELL = /bin/bash

MYDIR = $(DESTDIR)/usr/sbin
SUBDIRS =
BINS = acpi-wakeup.sh vdr-watchdogd
CONFS =

all: compile

compile: $(BINS)

clean:
	rm $(BINS)

install: $(BINS)
	@install -m 0755 -o root -g root -d $(MYDIR)
	@install -m 0755 -o root -g root $(BINS) $(MYDIR)
	#install -m 0644 -o root -g root $(CONFS) $(MYDIR)
	@for DIR in $(SUBDIRS); do \
		$(MAKE) -C $$DIR install; \
	done

.PHONY: all install
