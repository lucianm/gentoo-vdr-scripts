# $Id$

all:
	@echo nothing to compile

VERSION := $(shell grep '^Version' README | awk '{ print $$2 }')
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
	install -m 0755 -o root -g root -d $(DESTDIR)/etc/conf.d
	install -m 0755 -o root -g root -d $(DESTDIR)/etc/init.d

	install -m 0644 -o root -g root etc/conf.d/vdr* $(DESTDIR)/etc/conf.d
	install -m 0755 -o root -g root etc/init.d/vdr $(DESTDIR)/etc/init.d
	install -m 0755 -o root -g root etc/init.d/wakeup-reboot-halt $(DESTDIR)/etc/init.d


	install -m 0755 -o root -g root -d $(DESTDIR)/usr/sbin
	install -m 0755 -o root -g root usr/sbin/vdr-watchdogd $(DESTDIR)/usr/sbin
	install -m 0755 -o root -g root usr/sbin/acpi-wakeup.sh $(DESTDIR)/usr/sbin

	#install -m 0755 -o root -g root -d $(DESTDIR)/usr/bin
	#install -m 0755 -o root -g root usr/bin/vdr-start $(DESTDIR)/usr/bin

	install -m 0755 -o root -g root -d $(DESTDIR)/usr/share/vdr/rcscript
	install -m 0644 -o root -g root usr/share/vdr/rcscript/*.sh $(DESTDIR)/usr/share/vdr/rcscript/

	install -m 0755 -o root -g root -d $(DESTDIR)/usr/share/vdr/shutdown
	install -m 0644 -o root -g root usr/share/vdr/shutdown/{shutdown,pre,periodic}*.sh $(DESTDIR)/usr/share/vdr/shutdown/
	install -m 0644 -o root -g root usr/share/vdr/shutdown/wakeup-{acpi,none}.sh $(DESTDIR)/usr/share/vdr/shutdown/

ifdef NVRAM
	install -m 0644 -o root -g root usr/share/vdr/shutdown/wakeup-nvram.sh $(DESTDIR)/usr/share/vdr/shutdown/
endif

	install -m 0755 -o root -g root -d $(DESTDIR)/usr/share/vdr/inc
	install -m 0644 -o root -g root usr/share/vdr/inc/*.sh $(DESTDIR)/usr/share/vdr/inc/
	
	install -m 0755 -o root -g root -d $(DESTDIR)/usr/share/vdr/record
	install -m 0644 -o root -g root usr/share/vdr/record/*.sh $(DESTDIR)/usr/share/vdr/record/

	install -m 0755 -o root -g root -d $(DESTDIR)/usr/share/vdr/bin
	install -m 0755 -o root -g root usr/share/vdr/bin/*.sh $(DESTDIR)/usr/share/vdr/bin/

	install -m 0755 -o vdr -g vdr -d $(DESTDIR)/var/vdr/{shutdown-data,merged-config-files}

	install -m 0755 -o vdr -g vdr -d $(DESTDIR)/etc/vdr
	install -m 0755 -o vdr -g vdr -d $(DESTDIR)/etc/vdr/commands
	install -m 0644 -o vdr -g vdr etc/vdr/commands/commands.*.conf* $(DESTDIR)/etc/vdr/commands
	install -m 0755 -o vdr -g vdr -d $(DESTDIR)/etc/vdr/reccmds
	install -m 0644 -o vdr -g vdr etc/vdr/reccmds/reccmds.*.conf $(DESTDIR)/etc/vdr/reccmds


snapshot:
	svn export . gentoo-vdr-scripts-snapshot
	tar cvfz gentoo-vdr-scripts-snapshot.tgz gentoo-vdr-scripts-snapshot
	scp gentoo-vdr-scripts-snapshot.tgz dev.gentoo.org:public_html/distfiles/gentoo-vdr-scripts-snapshot.tgz
	rm gentoo-vdr-scripts-snapshot.tgz
	rm -rf gentoo-vdr-scripts-snapshot

.PHONY: all install snapshot
