# $Id$

SHELL = /bin/bash

SUBDIRS = etc usr vdrplugin-rebuild

all:

VERSION := $(shell grep '^Version' README | awk '{ print $$2 }')
TMPDIR = /tmp
ARCHIVE = gentoo-vdr-scripts-$(VERSION)
PACKAGE = $(ARCHIVE).tar.bz2
GITREF ?= HEAD

dist:
	@git archive --prefix=$(ARCHIVE)/ $(GITREF) | bzip2 > $(PACKAGE)
	@echo Distribution package created as $(PACKAGE)

install:
	@for DIR in $(SUBDIRS); do \
		$(MAKE) -C $$DIR install; \
	done
	@install -m 0755 -o vdr -g vdr -d $(DESTDIR)/var/vdr/{shutdown-data,merged-config-files}

snapshot:
	git archive HEAD | bzip2 gentoo-vdr-scripts-snapshot.tar.bz2
	scp gentoo-vdr-scripts-snapshot.tar.bz2 dev.gentoo.org:public_html/distfiles/gentoo-vdr-scripts-snapshot.tar.bz2
	rm gentoo-vdr-scripts-snapshot.tar.bz2

.PHONY: all compile install snapshot
