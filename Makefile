# psim — Makefile
#
# Installation locale par défaut (aucun privilège requis) :
#   make install
# Installation système :
#   make install PREFIX=/usr/local
# Empaquetage (staging) :
#   make install DESTDIR=/tmp/pkg PREFIX=/usr

PREFIX     ?= $(HOME)/.local
BINDIR     ?= $(PREFIX)/bin
MANDIR     ?= $(PREFIX)/share/man
ZSHCOMPDIR ?= $(PREFIX)/share/zsh/completions
DESTDIR    ?=

INSTALL    ?= install
RM         ?= rm -f
SHELLCHECK ?= shellcheck

.PHONY: all check install install-bin install-completion install-man uninstall help

all: help

check:
	$(SHELLCHECK) --enable=all -x psim

install: install-bin install-completion install-man

install-bin:
	$(INSTALL) -Dm755 psim $(DESTDIR)$(BINDIR)/psim

install-completion:
	$(INSTALL) -Dm644 completions/_psim $(DESTDIR)$(ZSHCOMPDIR)/_psim

install-man:
	$(INSTALL) -Dm644 man/psim.1 $(DESTDIR)$(MANDIR)/man1/psim.1
	$(INSTALL) -Dm644 man/fr/psim.1 $(DESTDIR)$(MANDIR)/fr/man1/psim.1

uninstall:
	$(RM) $(DESTDIR)$(BINDIR)/psim
	$(RM) $(DESTDIR)$(ZSHCOMPDIR)/_psim
	$(RM) $(DESTDIR)$(MANDIR)/man1/psim.1
	$(RM) $(DESTDIR)$(MANDIR)/fr/man1/psim.1
	-rmdir $(DESTDIR)$(MANDIR)/fr/man1 $(DESTDIR)$(MANDIR)/fr 2>/dev/null || true

help:
	@printf '%s\n' \
	  'psim — cibles disponibles :' \
	  '  make check       vérifie psim avec shellcheck' \
	  '  make install     installe psim, la complétion zsh et les pages de manuel' \
	  '  make uninstall   retire les fichiers installés' \
	  '' \
	  'Variables : PREFIX=$(PREFIX)' \
	  '            BINDIR=$(BINDIR)' \
	  '            MANDIR=$(MANDIR)' \
	  '            ZSHCOMPDIR=$(ZSHCOMPDIR)' \
	  '            DESTDIR=$(DESTDIR)'
