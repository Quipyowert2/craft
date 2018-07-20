# @(#)default.mk	1.21 SMI Copyright 1986
# copied by FJS to janus from /usr/include/make/default.mk
# much deleted....

#	Miscellaneous section.
LD=ld
LDFLAGS=
LDLIBS=
MAKE=make
RM=rm -f
AR=ar
ARFLAGS=rv
GET=/usr/sccs/get
GFLAGS=

markfile.o:	markfile
	echo "static char _sccsid[] = \"`grep @'(#)' markfile`\";" > markfile.c
	cc -c markfile.c
	$(RM) markfile.c

SCCSFLAGS=
SCCSGETFLAGS=-s
.SCCS_GET:
	?sccs $(SCCSFLAGS) get $(SCCSGETFLAGS) $@ -G$@
