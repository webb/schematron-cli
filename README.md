# schematron-cli: A command-line interface for Schematron

This package contains software supporting the development and execution of other
tools.

Copyright 2020 Georgia Tech Research Corporation (GTRC). All rights reserved.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.

# About

This script set uses the canonical schematron implementation, refined to my needs.

It presumes that it is targeting XSLT 2/saxon

Stages:

1. input file
2. process with XSLT 1 processor through iso_dsdl_include.xsl
3. process with XSLT 1 processor through iso_abstract_expand.xsl
4. process with XSLT 1 processor through iso_svrl_for_xslt1.xsl
5. yielding output file



