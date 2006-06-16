# $Id$

all:
	@echo nothing to compile

VERSION = $(shell grep '^Version' README | awk '{ print $$2 }')
TMPDIR = /tmp
ARCHIVE = gentoo-vdr-scripts-$(VERSION)
PACKAGE = $(ARCHIVE)

dist:
	@-rm -rf $(TMPDIR)/$(ARCHIVE)
	@svn export . $(TMPDIR)/$(ARCHIVE)
	@tar cjf $(PACKAGE).tar.bz2 -C $(TMPDIR) $(ARCHIVE)
	@-rm -rf $(TMPDIR)/$(ARCHIVE)
	@echo Distribution package created as $(PACKAGE).tar.bz2
						
install:
	mkdir -p $(DESTDIR)/etc/conf.d
	mkdir -p $(DESTDIR)/etc/init.d
	install -m 0644 -o root -g root etc/conf.d/vdr* $(DESTDIR)/etc/conf.d
	install -m 0755 -o root -g root etc/init.d/vdr $(DESTDIR)/etc/init.d
	install -m 0755 -o root -g root etc/init.d/wakeup-reboot-halt $(DESTDIR)/etc/init.d

	mkdir -p $(DESTDIR)/usr/sbin
	install -m 0755 -o root -g root usr/sbin/vdr-watchdogd $(DESTDIR)/usr/sbin
	install -m 0755 -o root -g root usr/sbin/acpi-wakeup.sh $(DESTDIR)/usr/sbin

	#mkdir -p $(DESTDIR)/usr/bin
	#install -m 0755 -o root -g root usr/bin/vdr-start $(DESTDIR)/usr/bin

	mkdir -p $(DESTDIR)/usr/lib/vdr/rcscript
	install -m 0644 -o root -g root usr/lib/vdr/rcscript/*.sh $(DESTDIR)/usr/lib/vdr/rcscript/

	mkdir -p $(DESTDIR)/usr/lib/vdr/shutdown
	install -m 0644 -o root -g root usr/lib/vdr/shutdown/{shutdown,pre,periodic}*.sh $(DESTDIR)/usr/lib/vdr/shutdown/
	install -m 0644 -o root -g root usr/lib/vdr/shutdown/wakeup-acpi.sh $(DESTDIR)/usr/lib/vdr/shutdown/

ifdef NVRAM
	install -m 0644 -o root -g root usr/lib/vdr/shutdown/wakeup-nvram.sh $(DESTDIR)/usr/lib/vdr/shutdown/
endif

	mkdir -p $(DESTDIR)/usr/share/vdr/inc
	install -m 0644 -o root -g root usr/share/vdr/inc/*.sh $(DESTDIR)/usr/share/vdr/inc/
	
	mkdir -p $(DESTDIR)/usr/lib/vdr/record
	install -m 0644 -o root -g root usr/lib/vdr/record/*.sh $(DESTDIR)/usr/lib/vdr/record/

	mkdir -p $(DESTDIR)/usr/lib/vdr/bin
	install -m 0755 -o root -g root usr/lib/vdr/bin/*.sh $(DESTDIR)/usr/lib/vdr/bin/

	mkdir -p $(DESTDIR)/var/vdr/{video,shutdown-data,merged-config-files}
	chown vdr:vdr -R $(DESTDIR)/var/vdr

	mkdir -p $(DESTDIR)/etc/vdr/commands
	install -m 0644 -o vdr -g vdr etc/vdr/commands/commands.*.conf* $(DESTDIR)/etc/vdr/commands
	mkdir -p $(DESTDIR)/etc/vdr/reccmds
	install -m 0644 -o vdr -g vdr etc/vdr/reccmds/reccmds.*.conf $(DESTDIR)/etc/vdr/reccmds
	chown vdr:vdr -R $(DESTDIR)/etc/vdr


snapshot:
	svn export . gentoo-vdr-scripts-snapshot
	tar cvfz gentoo-vdr-scripts-snapshot.tgz gentoo-vdr-scripts-snapshot
	scp gentoo-vdr-scripts-snapshot.tgz dev.gentoo.org:public_html/distfiles/gentoo-vdr-scripts-snapshot.tgz
	rm gentoo-vdr-scripts-snapshot.tgz
	rm -rf gentoo-vdr-scripts-snapshot

.PHONY: all install snapshot
