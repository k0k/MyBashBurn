#
# Makefile - This file install MyBashBurn project.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
# $Id: Makefile 37 2007-05-29 01:07:43Z k0k $

name = mybashburn
version = 1.0.2
proglist = MyBashBurn.sh
confile = etc/mybashburnrc
man1list = man/mybashburn.1.gz
doclist = ChangeLog COPYING CREDITS FAQ FILES HOWTO INSTALL README TODO
langlist = English Polish Swedish German Czech Spanish Norwegian
prefix = /usr
bindir = $(DESTDIR)$(prefix)/bin
confdir = $(DESTDIR)/etc
mandir = $(DESTDIR)$(prefix)/share/man
man1dir = $(mandir)/man1
docdir = $(DESTDIR)$(prefix)/share/doc/$(name)-$(version)
datadir = $(DESTDIR)$(prefix)/share/$(name)
datalist = lang convert menus burning misc config etc
srcdir = .

# Misc tools
MKDIR = mkdir
INSTALL = install
RM = rm
CP = cp
LN = ln 

# Tools configuration
MK_DIR = $(MKDIR) -p -m 755
INSTALL_PROG = $(INSTALL) -m 755
INSTALL_DATA = $(INSTALL) -m 644
INSTALL_LIST = $(CP) -Rp
LINK_PROG = $(LN) -sf
DATE=$$(date +%Y%m%d)

# Rules section
all:
	@echo "Nothing to make, use 'make install' to perform an installation."

# the man page convert
ps: $(addsuffix .ps, $(man1list))

%.ps: %
	groff -man -ma4 -Tps $< > $@

html: $(addsuffix .html, $(man1list))

%.html: %
	groff -man -Thtml $< > $@

# Install section
install: install_dirs install_prog install_link install_man install_doc install_list

install_dirs:
	$(MK_DIR) $(bindir) $(confdir) $(man1dir) $(docdir) $(datadir)

install_prog:
	$(INSTALL_PROG) $(proglist) $(datadir)

install_link:
	 $(LINK_PROG) $(datadir)/$(proglist) $(bindir)/$(name)
	 $(LINK_PROG) $(docdir)/HOWTO $(datadir)/ 
	 $(LINK_PROG) $(docdir)/CREDITS $(datadir)/ 

conf:
	$(INSTALL_DATA) $(confile) $(HOME)/.mybashburnrc

install_man: 
	$(INSTALL_DATA) $(man1list) $(man1dir)

install_doc:
	$(INSTALL_DATA) $(doclist) $(docdir)

install_list:
	$(INSTALL_LIST) $(datalist) $(datadir)

uninstall:
	$(RM) -rf $(datadir) $(docdir)
	unlink $(bindir)/$(name)
	for i in $(proglist); do $(RM) -f $(bindir)/$$i; done
	for i in $(confile); do $(RM) -f $(confdir)/$$i; done
	for i in $(man1list); do $(RM) -f $(man1dir)/$$i; done

pack:
	tar cvjf /tmp/$(name)-$(version)-$(DATE).tar.bz2 ../$(name)
	tar --exclude .svn -cvjf /tmp/$(name)-$(version).tar.bz2 ../$(name)

# vim: set ft=make nowrap nu:
