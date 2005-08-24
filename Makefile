
all:
	@echo nothing to compile

install:
	mkdir -p $(DESTDIR)/etc/{conf.d,init.d}
	install -m 0644 -o root -g root etc/conf.d/{vdr,vdr.watchdogd} $(DESTDIR)/etc/conf.d
	install -m 0755 -o root -g root etc/init.d/vdr $(DESTDIR)/etc/init.d

	mkdir -p $(DESTDIR)/usr/sbin
	install -m 0755 -o root -g root usr/sbin/vdr-watchdogd $(DESTDIR)/usr/sbin
	install -m 0755 -o root -g root usr/sbin/acpi-wakeup.sh $(DESTDIR)/usr/sbin

	#mkdir -p $(DESTDIR)/usr/bin
	#install -m 0755 -o root -g root usr/bin/vdr-start $(DESTDIR)/usr/bin

	mkdir -p $(DESTDIR)/usr/lib/vdr/rcscript
	install -m 0644 -o root -g root usr/lib/vdr/rcscript/*.sh $(DESTDIR)/usr/lib/vdr/rcscript/

	mkdir -p $(DESTDIR)/var/vdr

	mkdir -p $(DESTDIR)/etc/vdr/commands
	install -m 0644 -o root -g root etc/vdr/commands/commands.*.conf $(DESTDIR)/etc/vdr/commands
	mkdir -p $(DESTDIR)/etc/vdr/reccmds
	install -m 0644 -o root -g root etc/vdr/reccmds/reccmds.*.conf $(DESTDIR)/etc/vdr/reccmds

.PHONY: all install
