#!/usr/bin/env bash

set -o nounset -o errexit -o pipefail

root_dir=$(dirname "$0")/..
. "$root_dir"/share/'MACRO_WRTOOLS_CORE_PACKAGE_NAME'/opt_help.bash
. "$root_dir"/share/'MACRO_WRTOOLS_CORE_PACKAGE_NAME'/opt_verbose.bash
. "$root_dir"/share/'MACRO_WRTOOLS_CORE_PACKAGE_NAME'/fail.bash
. "$root_dir"/share/'MACRO_WRTOOLS_CORE_PACKAGE_NAME'/temp.bash
. "$root_dir"/share/'MACRO_WRTOOLS_CORE_PACKAGE_NAME'/paranoia.bash

share_dir="$root_dir"/'M_SHARE_DIR_REL'

#HELP:COMMAND_NAME: Run a pre-compiled Schematron XSLT against a subject file
#HELP:Usage: COMMAND_NAME --xslt=$schema.sch.xsl $subject.xml
#HELP:Options:
#HELP:  --help | -h: print this help
#HELP:  --verbose | -v: print debugging and status output
#HELP:  --keep-temps | -k: Don't delete temporary files
#HELP:  --not-paranoid: Omit basic/foundational validations

#HELP:  --xslt-file=$schema.sch.xsl | -s $schema.sch.xsl: Execute Schematron XSLT
unset xslt_file
opt_xslt_file () {
    (( $# == 1 )) || fail_assert "need 1 arg (got $#)"
    xslt_file=$1
}

#HELP:  --param=$variable=$value: Set XSLT parameter, using Saxon syntax
#HELP:    e.g., --param=+xml-catalog=subset/xml-catalog.xml
#HELP:    Run "saxon -- -?" to see Saxon parameter syntax
params=()
opt_param () {
    (( $# == 1 )) || fail_assert "need 1 arg (got $#)"
    params+=("$1")
}

#HELP:  --output-file=$out | -o $out: Write output to file (default stdout)
unset output_file
opt_output_file () {
    (( $# == 1 )) || fail_assert "need 1 arg (got $#)"
    output_file=$1
}

#HELP:  --format=$format: Generate output in indicated format (default is text). Options:
#HELP:      svrl: Schematron Validation Report Langugage
#HELP:      text: grep-like text output
format=text
opt_format () {
    (( $# == 1 )) || fail "$FUNCNAME must have 1 argument, an output format"
    case $1 in
        svrl | text ) format=$1;;
        * ) fail "Option --format got unexpected format \"$1\"";;
    esac
}

OPTIND=1
while getopts :hkvs:-: OPTION
do
    case "$OPTION" in
        h ) opt_help;;
        k ) opt_keep_temps;;
        o ) opt_output_file "$OPTARG";;
        v ) opt_verbose;;
        s ) opt_xslt_file "$OPTARG";;
        - )
            case "$OPTARG" in
                help ) opt_help;;
                keep-temps ) opt_keep_temps;;
                verbose ) opt_verbose;;
                not-paranoid ) opt_not_paranoid;;
                help=* | keep-temps=* | verbose=* | not-paranoid=* ) 
                    fail "No argument expected for long option \"${OPTARG%%=*}\"";;
                output-file=* ) opt_output_file "${OPTARG#*=}";;
                param=* ) opt_param "${OPTARG#*=}";;
                format=* ) opt_format "${OPTARG#*=}";;
                xslt-file=* ) opt_xslt_file "${OPTARG#*=}";;
                param | format | xslt-file )
                    fail "Missing required argument for long option \"$OPTARG\"";;
                * ) fail "Unexpected long option \"$OPTARG\"";;
            esac;;
        '?' ) fail "Unknown short option \"$OPTARG\"";;
        : ) fail "Short option \"$OPTARG\" missing argument";;
        * ) fail "bad state OPTARG=\"$OPTARG\"";;
    esac
done
shift $((OPTIND-1))

[[ is-set = ${xslt_file+is-set} ]] || fail "Missing required argument --xslt-file"
vecho "Schematron XSLT file is $xslt_file"

(( $# == 1 )) || fail "Need 1 argument (got $#)"
subject_file=$1
vecho "Subject file is $subject_file"

! is_paranoid || [[ -f $xslt_file && -r $xslt_file ]] || fail "Schematron XSLT must be a readable file ($xslt_file)"
! is_paranoid || check-xml "$xslt_file" || fail "Schematron XSLT did not pass XML check ($xslt_file)"

! is_paranoid || [[ -f $subject_file && -r $subject_file ]] || fail "Subject file needs to be readable file"
! is_paranoid || check-xml "$subject_file" || fail "Subject file did not pass XML check ($subject_file)"

vecho "Validating file \"$subject_file\" against Schematron XSLT \"$xslt_file\""
vecho "Format is $format"

command=( saxon --in="$subject_file" --xsl="$xslt_file" )

case $format in
    svrl )
        if [[ -n ${output_file+is-set} ]]
        then command+=( --out="$output_file" )
        fi;;
    text )
        temp_make_file stage_1_plain_svrl stage_2_annotated_svrl
        command+=( --out=$stage_1_plain_svrl )
        ;;
esac

command+=( -- -l:on )

if (( ${#params[@]} > 0 ))
then command+=( "${params[@]}" )
fi

vrun "${command[@]}"

if [[ $format = text ]]
then vrun xalan \
          --in="$stage_1_plain_svrl" \
          --xsl="$share_dir"/annotate-svrl.xsl \
          --out="$stage_2_annotated_svrl" \
          -- -L
     command=(xalan \
                --in="$stage_2_annotated_svrl" \
                --xsl="$share_dir"/annotated-svrl-to-text.xsl \
                --param=filename="$subject_file")
     if [[ -n ${output_file+is-set} ]]
     then command+=( --out="$output_file" )
     fi
     vrun "${command[@]}"
fi
