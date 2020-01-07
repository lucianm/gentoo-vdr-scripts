# $Id$

SHELL = /bin/bash

MYDIR = $(DESTDIR)/usr/share/vdr/shutdown
SUBDIRS =
BINS =
WAKEUP = wakeup-rtc.sh wakeup-nvram.sh wakeup-none.sh
CONFS = $(wildcard shutdown*.sh pre*.sh periodic*.sh) $(WAKEUP)

all:

install:
	@install -m 0755 -o root -g root -d $(MYDIR)
	#install -m 0755 -o root -g root $(BINS) $(MYDIR)
	@install -m 0644 -o root -g root $(CONFS) $(MYDIR)
	@for DIR in $(SUBDIRS); do \
		$(MAKE) -C $$DIR install; \
	done

.PHONY: all install
