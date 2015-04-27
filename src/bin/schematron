#!/usr/bin/env bash

#HELP:COMMAND_NAME: run a Schematron document against an XML document, producing SVRL output
#HELP:Usage: COMMAND_NAME option* $file-to-test.xml
#HELP:Options:
#HELP:  --help | -h: print this help
#HELP:  --verbose | -v: print debugging and status output
#HELP:  --keep-temps | -k: Don't delete temporary files

set -o nounset -o errexit

root_dir=$(dirname "$0")/..
. "$root_dir"/share/'MACRO_WRTOOLS_CORE_PACKAGE_NAME'/opt_help.bash
. "$root_dir"/share/'MACRO_WRTOOLS_CORE_PACKAGE_NAME'/opt_verbose.bash
. "$root_dir"/share/'MACRO_WRTOOLS_CORE_PACKAGE_NAME'/fail.bash
. "$root_dir"/share/'MACRO_WRTOOLS_CORE_PACKAGE_NAME'/temp.bash

#HELP:  --schema=$schema | -s $schema: validate against Schematron schema
unset SCHEMA
opt_schema () {
    (( $# == 1 )) || fail "$FUNCNAME requires 1 arg (got $#)"
    [[ ${SCHEMA+is-set} != is-set ]] || fail "Option --schema must be used no more than once"
    [[ -f $1 ]] || fail "Argument to --schema must be a file ($1)"
    vecho "Validating against Schematron schema \"$1\""
    SCHEMA=$1
}

#HELP:  --format=$format: Generate output in indicated format
#HELP:      The default format is "svrl"
#HELP:      Formats available:
#HELP:        svrl: Schematron Validation Report Langugage
#HELP:        text: grep-like text output
format=svrl
opt_format () {
    (( $# == 1 )) || fail "$FUNCNAME must have 1 argument, an output format"
    case $1 in
        svrl | text ) format=$1;;
        * ) fail "Option --format got unexpected format \"$1\"";;
    esac
}

#HELP:  --force-rebuild | -f: Always rebuild XSLTs from Schematrons, even if they have not changed.
FORCE_REBUILD=false
opt_force_rebuild () {
    FORCE_REBUILD=true
}

#HELP:  --param=$variable=$value: set XSLT parameter, using Saxon syntax
#HELP:    e.g., --param=+xml-catalog=subset/xml-catalog.xml
#HELP:    Use "saxon -- -?" to see Saxon parameter syntax
PARAMS=()
opt_param () {
    PARAMS+=("$1")
}

OPTIND=1
while getopts :fhkvs:-: OPTION
do
    case "$OPTION" in
        f ) opt_force_rebuild;;
        h ) opt_help;;
        k ) opt_keep_temps;;
        v ) opt_verbose;;
        s ) opt_schema "$OPTARG";;
        - )
            case "$OPTARG" in
                force-rebuild ) opt_force_rebuild;;
                help ) opt_help;;
                keep-temps ) opt_keep_temps;;
                verbose ) opt_verbose;;
                force-rebuild=* | help=* | keep-temps=* | verbose=* ) 
                    fail "No argument expected for long option \"${OPTARG%%=*}\"";;

                format=* ) opt_format "${OPTARG#*=}";;
                param=* ) opt_param "${OPTARG#*=}";;
                schema=* ) opt_schema "${OPTARG#*=}";;
                format | param | schema )
                    fail "Missing required argument for long option \"$OPTARG\"";;
                
                * ) fail "Unexpected long option \"$OPTARG\"";;
            esac;;
        '?' ) fail "Unknown short option \"$OPTARG\"";;
        : ) fail "Short option \"$OPTARG\" missing argument";;
        * ) fail "bad state OPTARG=\"$OPTARG\"";;
    esac
done
shift $((OPTIND-1))

# check options
[[ ${SCHEMA+is-set} = is-set ]] || fail "Required option --schema not used" 

# check args
(( $# == 1 )) || fail "Must be 1 file to validate (got $#)"
[[ -f $1 ]] || fail "File to test not found ($1)"

SCHEMA_DIR=$(dirname "$SCHEMA")
SCHEMA_BASE=$(basename "$SCHEMA")
INCLUDE=$SCHEMA_DIR/tmp.$SCHEMA_BASE.include.xml
ABSTRACT=$SCHEMA_DIR/tmp.$SCHEMA_BASE.abstract.xml
XSL=$SCHEMA_DIR/tmp.$SCHEMA_BASE.xsl

if [[ "$FORCE_REBUILD" = true || "$INCLUDE" -ot "$SCHEMA" ]]
then vrun saxon \
          --in="$SCHEMA" \
          --out="$INCLUDE" \
          --xsl="$root_dir"/share/'MACRO_PACKAGE_NAME'/iso-schematron-xslt2/iso_dsdl_include.xsl
     
else vecho "No need to rebuild \"$INCLUDE\""
fi

if [[ "$FORCE_REBUILD" = true || "$ABSTRACT" -ot "$INCLUDE" ]]
then vrun saxon \
          --in="$INCLUDE" \
          --out="$ABSTRACT" \
          --xsl="$root_dir"/share/'MACRO_PACKAGE_NAME'/iso-schematron-xslt2/iso_abstract_expand.xsl
else vecho "No need to rebuild \"$ABSTRACT\""
fi

if [[ "$FORCE_REBUILD" = true || "$XSL" -ot "$ABSTRACT" ]]
then vrun saxon \
          --in="$ABSTRACT" \
          --out="$XSL" \
          --xsl="$root_dir"/share/'MACRO_PACKAGE_NAME'/iso-schematron-xslt2/iso_svrl_for_xslt2.xsl \
          -- allow-foreign=true full-path-notation=4
else vecho "No need to rebuild \"$XSL\""
fi

vecho "Validating file \"$1\" against schema \"$SCHEMA\"" 
COMMAND=(saxon \
           --in="$1" \
           --xsl="$XSL" \
           -- -l:on)

if (( ${#PARAMS[@]} > 0 ))
then COMMAND+=("${PARAMS[@]}")
fi

exec 3>&1
if [[ $format = text ]]
then temp_make_file plain_svrl annotated_svrl
     exec 3>"$plain_svrl"
fi

vrun "${COMMAND[@]}" >&3

if [[ $format = text ]]
then vrun xalan \
          --in="$plain_svrl" \
          --xsl="$root_dir"/share/'MACRO_PACKAGE_NAME'/annotate-svrl.xsl \
          --out="$annotated_svrl" \
          -- -L
     vrun xalan \
          --in="$annotated_svrl" \
          --xsl="$root_dir"/share/'MACRO_PACKAGE_NAME'/annotated-svrl-to-text.xsl \
          --param=filename="$1"
fi
     



