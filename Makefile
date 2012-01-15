# $Id$

SHELL = /bin/bash

SUBDIRS = etc usr vdrplugin-rebuild

all:

VERSION := $(shell grep '^Version' README | awk '{ print $$2 }')
TMPDIR = /tmp
ARCHIVE = gentoo-vdr-scripts-$(VERSION)
PACKAGE = $(ARCHIVE)

info:
	@echo VERSION: $(VERSION)
	@[ -d ../tags/$(VERSION) ] && echo "Already tagged in svn"
	@echo
	@[ -d .svn ] && svn info

dist:
	@-rm -rf $(TMPDIR)/$(ARCHIVE)
	@svn export . $(TMPDIR)/$(ARCHIVE)
	@tar cjf $(PACKAGE).tar.bz2 -C $(TMPDIR) $(ARCHIVE)
	@-rm -rf $(TMPDIR)/$(ARCHIVE)
	@echo Distribution package created as $(PACKAGE).tar.bz2

install:
	@for DIR in $(SUBDIRS); do \
		$(MAKE) -C $$DIR install; \
	done
	@install -m 0755 -o vdr -g vdr -d $(DESTDIR)/var/vdr/{shutdown-data,merged-config-files}

snapshot:
	svn export . gentoo-vdr-scripts-snapshot
	tar cvfz gentoo-vdr-scripts-snapshot.tgz gentoo-vdr-scripts-snapshot
	scp gentoo-vdr-scripts-snapshot.tgz dev.gentoo.org:public_html/distfiles/gentoo-vdr-scripts-snapshot.tgz
	rm gentoo-vdr-scripts-snapshot.tgz
	rm -rf gentoo-vdr-scripts-snapshot

.PHONY: all compile install snapshot
