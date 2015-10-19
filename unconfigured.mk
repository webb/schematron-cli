
.PHONY: all # create everything that can be generated pre-configure
all: install-sh
	autoreconf --install --verbose

.PHONY: help # print this help
help:
	@ echo Not doing anything. Maybe you wanted one of these targets:
	@ sed -e 's/^.PHONY: *\([^ #]*\) *\# *\(.*\)$$/  \1: \2/p;d' unconfigured.mk

.PHONY: clean # remove everything that can be generated
clean: 
	$(RM) -r .gradle autom4te.cache out tmp
	$(RM) Makefile stow.mk configure
	$(RM) autm4te.cache autoscan.log config.log configure 
	$(RM) config.guess config.sub config.status install-sh ltmain.sh
	$(RM) depcomp missing aclocal.m4 
	find . -type f -name '*~' -delete

install-sh:
	glibtoolize -icf
	$(RM) ltmain.sh config.guess config.sub

