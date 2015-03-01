
default:
	@ printf "No default target. Targets:\n"
	@ printf "    zero: remove everything that can be generated\n"
	@ printf "    init: create everything that can be generated pre-configure\n"

zero:
	$(RM) -r .gradle autom4te.cache out
	$(RM) Makefile autm4te.cache autoscan.log config.log configure 
	$(RM) config.guess config.sub config.status install-sh ltmain.sh
	$(RM) depcomp missing aclocal.m4 
	find . -type f -name '*~' -delete

install-sh:
	glibtoolize -icf
	$(RM) ltmain.sh config.guess config.sub

init: install-sh
	autoreconf --install --verbose
