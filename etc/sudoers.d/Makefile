SHELL = /bin/bash

MYDIR = $(DESTDIR)/etc/sudoers.d
SUBDIRS =
BINS =
CONFS = vdr

all:

install:
	@install -m 0750 -o root -g root -d $(MYDIR)
	#install -m 0755 -o root -g root $(BINS) $(MYDIR)
	@install -m 0440 -o root -g root $(CONFS) $(MYDIR)
	@for DIR in $(SUBDIRS); do \
		$(MAKE) -C $$DIR install; \
	done

.PHONY: all install
