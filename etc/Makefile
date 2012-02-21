# $Id: Makefile 454 2007-05-30 09:56:54Z zzam $

SHELL = /bin/bash

MYDIR = $(DESTDIR)/etc
SUBDIRS = conf.d init.d vdr sudoers.d

all:

install:
	@install -m 0755 -o root -g root -d $(MYDIR)
	@for DIR in $(SUBDIRS); do \
		$(MAKE) -C $$DIR install; \
	done

.PHONY: all install
