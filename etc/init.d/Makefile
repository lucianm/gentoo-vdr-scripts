SHELL = /bin/bash

MYDIR = $(DESTDIR)/etc/init.d
SUBDIRS =
BINS = vdr vdr-x11 wakeup-reboot-halt
CONFS =

all:

install:
	@install -m 0755 -o root -g root -d $(MYDIR)
	@install -m 0755 -o root -g root $(BINS) $(MYDIR)
	#install -m 0644 -o root -g root $(CONFS) $(MYDIR)
	@for DIR in $(SUBDIRS); do \
		$(MAKE) -C $$DIR install; \
	done

.PHONY: all install
