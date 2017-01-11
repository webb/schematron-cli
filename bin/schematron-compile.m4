#!/usr/bin/env bash

set -o nounset -o errexit -o pipefail

root_dir=$(dirname "$0")/..
. "$root_dir"/share/wrtools-core/opt_help.bash
. "$root_dir"/share/wrtools-core/opt_verbose.bash
. "$root_dir"/share/wrtools-core/fail.bash
. "$root_dir"/share/wrtools-core/temp.bash
. "$root_dir"/share/wrtools-core/paranoia.bash

share_dir="$root_dir"/'M_SHARE_DIR_REL'

#HELP:COMMAND_NAME: Compile a Schematron document into an XSLT document
#HELP:Usage: COMMAND_NAME (option)* $file.sch
#HELP:Options:
#HELP:  --help | -h: print this help
#HELP:  --verbose | -v: print debugging and status output
#HELP:  --keep-temps | -k: Don't delete temporary files
#HELP:  --not-paranoid: Omit basic/foundational validations

#HELP:  --output-file=$file.xsl | -o $file.xsl: Send output to file
#HELP:      (Default filename is the name of the Schematron file, with .xsl appended)
unset output_file
opt_output_file () {
    (( $# == 1 )) || fail_assert "need 1 arg (got $#)"
    output_file="$1"
}

OPTIND=1
while getopts :fhko:s:v-: OPTION
do
    case "$OPTION" in
        h ) opt_help;;
        k ) opt_keep_temps;;
        o ) opt_output_file "$OPTARG";;
        v ) opt_verbose;;
        - )
            case "$OPTARG" in
                help ) opt_help;;
                keep-temps ) opt_keep_temps;;
                verbose ) opt_verbose;;
                help=* | keep-temps=* | verbose=* ) 
                    fail "No argument expected for long option \"${OPTARG%%=*}\"";;
                output-file=* ) opt_output_file "${OPTARG#*=}";;
                output-file )
                    fail "Missing required argument for long option \"$OPTARG\"";;
                * ) fail "Unexpected long option \"$OPTARG\"";;
            esac;;
        '?' ) fail "Unknown short option \"$OPTARG\"";;
        : ) fail "Short option \"$OPTARG\" missing argument";;
        * ) fail "bad state OPTARG=\"$OPTARG\"";;
    esac
done
shift $((OPTIND-1))

(( $# == 1 )) || fail "Need 1 argument (got $#)"
input_file=$1
[[ -f $input_file && -r $input_file ]] || fail "Input file needs to be readable file"

vecho "input file is $input_file"

if [[ is-set != ${output_file+is-set} ]]
then output_file=$input_file.xsl
fi

vecho "output file is $output_file"

! is_paranoid || check-xml "$input_file" || fail "input file did not pass XML check ($input_file)"

temp_make_file stage_1_includes stage_2_abstracts_expanded

vrun saxon \
     --in="$input_file" \
     --out="$stage_1_includes" \
     --xsl="$share_dir"/iso-schematron-xslt2/iso_dsdl_include.xsl

vrun saxon \
     --in="$stage_1_includes" \
     --out="$stage_2_abstracts_expanded" \
     --xsl="$share_dir"/iso-schematron-xslt2/iso_abstract_expand.xsl

vrun saxon \
     --in="$stage_2_abstracts_expanded" \
     --out="$output_file" \
     --xsl="$share_dir"/iso-schematron-xslt2/iso_svrl_for_xslt2.xsl \
     -- allow-foreign=true full-path-notation=4

