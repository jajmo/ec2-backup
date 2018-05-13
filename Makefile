# Jason Ajmo and Bradford Smith
# CS 615 HW6 ec2-backup Makefile

PREFIX ?= /usr/local
BINPREFIX ?= "$(PREFIX)/bin"
MANPREFIX ?= "$(PREFIX)/share/man/man1"

PRG = ec2-backup
MAN = man/ec2-backup.1
RM = rm -f

.PHONY: all install uninstall

all:
	@echo "usage: make install"
	@echo "       make test"
	@echo "       make uninstall"

install:
	install -Dm 0755 $(PRG) -t $(DESTDIR)$(BINPREFIX)
	install -Dm 0644 $(MAN) -t $(DESTDIR)$(MANPREFIX)

test:
	./test.sh

uninstall:
	$(RM) $(DESTDIR)$(BINPREFIX)/$(PRG)
	$(RM) $(DESTDIR)$(MANPREFIX)/$(MAN)
