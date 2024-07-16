SHELL = /bin/bash

SUBDIRS = etc usr vdrplugin-rebuild

SUBDIRS +=  usr/lib/systemd/system etc/systemd/system/vdr.service.d usr/lib/tmpfiles.d

all:

VERSION := $(shell grep '^Version' README | awk '{ print $$2 }')
TMPDIR = /tmp
ARCHIVE = gentoo-vdr-scripts-$(VERSION)
PACKAGE = $(ARCHIVE).tar.bz2
GITREF ?= HEAD
# look up vdr's home found on system
VDR_HOME ?= $(shell eval echo ~vdr)

dist:
	@git archive --prefix=$(ARCHIVE)/ $(GITREF) | bzip2 > $(PACKAGE)
	@echo Distribution package created as $(PACKAGE)

install:
	@for DIR in $(SUBDIRS); do \
		$(MAKE) -C $$DIR install; \
	done
	# create directories in $(VDR_HOME)git@github.com:lucianm/gentoo-vdr-scripts.git
	@install -m 0755 -o vdr -g vdr -d $(DESTDIR)/$(VDR_HOME)/{shutdown-data,merged-config-files}
	@install -m 0755 -o root -g root -d $(DESTDIR)/$(VDR_HOME)/tmp
	# create empty systemd_env file, writable for user vdr
	@install -m 0644 -o vdr -g vdr /dev/null $(DESTDIR)/$(VDR_HOME)/tmp/systemd_env
	# replace %HOME% placeholder with $(VDR_HOME)
	@sed -e "s|%HOME%|$(VDR_HOME)|" -i \
		$(DESTDIR)/etc/conf.d/vdr \
		$(DESTDIR)/etc/vdr/commands/commands.system.conf \
		$(DESTDIR)/etc/vdr/commands/commands.system.conf.de \
		$(DESTDIR)/usr/lib/systemd/system/vdr.service \
		$(DESTDIR)/usr/lib/tmpfiles.d/gentoo-vdr-scripts.conf

snapshot:
	git archive HEAD | bzip2 gentoo-vdr-scripts-snapshot.tar.bz2
	scp gentoo-vdr-scripts-snapshot.tar.bz2 hd_brummy@dev.gentoo.org:public_html/distfiles/gentoo-vdr-scripts-snapshot.tar.bz2
	rm gentoo-vdr-scripts-snapshot.tar.bz2

.PHONY: all compile install snapshot
