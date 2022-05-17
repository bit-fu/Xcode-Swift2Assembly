# vim:sts=8 sw=8 ts=8 noexpandtab:
#
#   Makefile
#   ~~~~~~~~
#
#   Project:		swift2asm
#
#   Created 2021-03-22:	Ulrich Singer
#

# Where to install
BINDIR	= $(HOME)/bin

# Tools
SHELL	= /bin/sh
INSTALL	= /usr/bin/install -C

# Targets

.PHONY: all
all: install

$(BINDIR)/swift2asm: swift2asm.sh
	mkdir -p "$(BINDIR)"
	$(INSTALL) -p -o $(USER) -m 0755 $^ $@

.PHONY: install
install: $(BINDIR)/swift2asm

# ~ Makefile ~ #
