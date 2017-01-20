
this_makefile = ${lastword ${MAKEFILE_LIST}}

source_sch = \
share/schematron-schema/schematron.sch \
share/schematron-schema/svrl.sch \

compiled_sch_as_xsl = ${source_sch:%.sch=%.sch.xsl}

#HELP:The default target is "all".
#HELP:Targets:

.PHONY: all #    Do all steps. Steps include:
all:
	${MAKE} clean
	${MAKE} xsl

.PHONY: clean #        Remove build products
clean:
	rm -f ${compiled_sch_as_xsl}

.PHONY: xsl #        Compile Schematron files into XSLTs
xsl: ${compiled_sch_as_xsl}

.PHONY: help #  Print this help
help:
	@ sed -e '/^\.PHONY:/s/^\.PHONY: *\([^ #]*\) *\#\( *\)\([^ ].*\)/\2\1: \3/p;/^[^#]*#HELP:/s/[^#]*#HELP:\(.*\)/\1/p;d' ${this_makefile}

%.sch.xsl: %.sch
	schematron-compile --output-file=$@ $<

