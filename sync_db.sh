#!/bin/bash

# Created by argbash-init v2.10.0
# ARG_OPTIONAL_SINGLE([host],[r],[Remote database host])
# ARG_OPTIONAL_SINGLE([user],[u],[Remote database user])
# ARG_OPTIONAL_SINGLE([pass],[p],[Remote database password])
# ARG_OPTIONAL_BOOLEAN([go],[g],[Perform import. Otherwise diagnostic information will be shown.])
# ARG_OPTIONAL_BOOLEAN([skip-download],[d],[Skip download step])
# ARG_OPTIONAL_BOOLEAN([skip-import],[i],[Skip import step])
# ARG_POSITIONAL_SINGLE([dbname],[The name of the database we are importing],[""])
# ARG_DEFAULTS_POS([])
# ARG_HELP([A helper for syncing local data from remote])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.10.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info


die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}


begins_with_short_option()
{
	local first_option all_short_options='rupgdih'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
_arg_dbname=""
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_host=
_arg_user=
_arg_pass=
_arg_go="off"
_arg_skip_download="off"
_arg_skip_import="off"


print_help()
{
	printf '%s\n' "A helper for syncing local data from remote"
	printf 'Usage: %s [-r|--host <arg>] [-u|--user <arg>] [-p|--pass <arg>] [-g|--(no-)go] [-d|--(no-)skip-download] [-i|--(no-)skip-import] [-h|--help] [<dbname>]\n' "$0"
	printf '\t%s\n' "<dbname>: The name of the database we are importing (default: '""')"
	printf '\t%s\n' "-r, --host: Remote database host (no default)"
	printf '\t%s\n' "-u, --user: Remote database user (no default)"
	printf '\t%s\n' "-p, --pass: Remote database password (no default)"
	printf '\t%s\n' "-g, --go, --no-go: Perform import. Otherwise diagnostic information will be shown. (off by default)"
	printf '\t%s\n' "-d, --skip-download, --no-skip-download: Skip download step (off by default)"
	printf '\t%s\n' "-i, --skip-import, --no-skip-import: Skip import step (off by default)"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	_positionals_count=0
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-r|--host)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_host="$2"
				shift
				;;
			--host=*)
				_arg_host="${_key##--host=}"
				;;
			-r*)
				_arg_host="${_key##-r}"
				;;
			-u|--user)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_user="$2"
				shift
				;;
			--user=*)
				_arg_user="${_key##--user=}"
				;;
			-u*)
				_arg_user="${_key##-u}"
				;;
			-p|--pass)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_pass="$2"
				shift
				;;
			--pass=*)
				_arg_pass="${_key##--pass=}"
				;;
			-p*)
				_arg_pass="${_key##-p}"
				;;
			-g|--no-go|--go)
				_arg_go="on"
				test "${1:0:5}" = "--no-" && _arg_go="off"
				;;
			-g*)
				_arg_go="on"
				_next="${_key##-g}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-g" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			-d|--no-skip-download|--skip-download)
				_arg_skip_download="on"
				test "${1:0:5}" = "--no-" && _arg_skip_download="off"
				;;
			-d*)
				_arg_skip_download="on"
				_next="${_key##-d}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-d" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			-i|--no-skip-import|--skip-import)
				_arg_skip_import="on"
				test "${1:0:5}" = "--no-" && _arg_skip_import="off"
				;;
			-i*)
				_arg_skip_import="on"
				_next="${_key##-i}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-i" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_last_positional="$1"
				_positionals+=("$_last_positional")
				_positionals_count=$((_positionals_count + 1))
				;;
		esac
		shift
	done
}


handle_passed_args_count()
{
	test "${_positionals_count}" -le 1 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect between 0 and 1, but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


assign_positional_args()
{
	local _positional_name _shift_for=$1
	_positional_names="_arg_dbname "

	shift "$_shift_for"
	for _positional_name in ${_positional_names}
	do
		test $# -gt 0 || break
		eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
		shift
	done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

if [[ $_arg_go == 'on' && -z $_arg_dbname ]]; then
	echo Must specify a database to import
	exit 1
fi

if [[ $_arg_skip_download == 'off' ]]; then
	echo -n 'Retrieving size information for '
	if [[ -n $_arg_dbname ]]; then
		echo "remote database '$_arg_dbname'"
		schema_filter="AND table_schema = '$_arg_dbname'"
	else
		echo all remote databases
	fi
	remote_size="
	SELECT
		table_schema AS 'Database'
		,COUNT(*) AS '#Tables'
		,ROUND(SUM(table_rows)/1000000,4) AS '#Rows (M)'
		,ROUND(SUM(data_length+index_length)/(1024*1024),4) 'Size (Mb)'
	FROM information_schema.TABLES
	WHERE table_schema <> 'information_schema'
	$schema_filter
	GROUP BY table_schema
	ORDER BY SUM(data_length+index_length)
	DESC;
	"

	if [[ -n $_arg_pass ]]; then
		echo 'TODO: remote password not presently supported, sorry'
		exit 1
	fi
	marg_h=${_arg_host:+"-h$_arg_host"}
	marg_u=${_arg_user:+"-u$_arg_user"}
	echo $remote_size | mysql -t $marg_h $marg_u
fi

if [[ $_arg_go == 'on' ]]; then
	if [[ -d ./temp/sync_db/ ]]; then
		pushd ./temp/sync_db/ &> /dev/null
		intempdir=yes
	fi
	temp_file=$_arg_dbname.sql.gz
	if [[ $_arg_skip_download == 'off' ]]; then
		echo "Performing download of '$_arg_dbname'"
		mysqldump --lock-tables=false --single-transaction=true --default-character-set=latin1 $marg_h $marg_u --add-drop-database --databases $_arg_dbname | pv -trb | gzip > $temp_file
	fi
	if [[ -r $temp_file && $_arg_skip_import == 'off' ]]; then
		echo Importing data to local database
		pv $temp_file | gunzip | mysql -uroot --password="$MARIADB_ROOT_PASSWORD"
	fi
	if [[ -n $intempdir ]]; then
		popd &> /dev/null
	fi
fi

exit 0

# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^

# ] <-- needed because of Argbash
