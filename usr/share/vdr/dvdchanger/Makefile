SHELL = /bin/bash

MYDIR = $(DESTDIR)/usr/share/vdr/dvdchanger
BINS = dvdchanger_readdvd.sh dvdchanger_writedvd.sh

all:

install:
	@install -m 0755 -o root -g root -d $(MYDIR)
	@install -m 0755 -o root -g root $(BINS) $(MYDIR)

.PHONY: all install
