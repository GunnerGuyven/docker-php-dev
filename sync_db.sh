#!/bin/bash

# Created by argbash-init v2.10.0
# ARG_OPTIONAL_SINGLE([host],[r],[Remote database host])
# ARG_OPTIONAL_SINGLE([user],[u],[Remote database user])
# ARG_OPTIONAL_SINGLE([pass],[p],[Remote database password])
# ARG_OPTIONAL_BOOLEAN([go],[g],[Perform import])
# ARG_OPTIONAL_BOOLEAN([skip-download],[d],[Skip download step])
# ARG_OPTIONAL_BOOLEAN([skip-import],[i],[Skip import step])
# ARG_OPTIONAL_BOOLEAN([psql],[],[Use PostgreSQL mode])
# ARG_OPTIONAL_BOOLEAN([maria],[],[Use MariaDB mode])
# ARG_OPTIONAL_BOOLEAN([locale-fix],[],[Replace known Windows locale with Unix (PostgreSQL only)],[on])
# ARG_OPTIONAL_BOOLEAN([include-roles],[],[Grab all roles from target server (PostgreSQL only)])
# ARG_POSITIONAL_INF([dbname],[The name of the database we are importing])
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
_arg_dbname=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_host=
_arg_user=
_arg_pass=
_arg_go="off"
_arg_skip_download="off"
_arg_skip_import="off"
_arg_psql="off"
_arg_maria="off"
_arg_locale_fix="on"
_arg_include_roles="off"


print_help()
{
	printf '%s\n' "A helper for syncing local data from remote"
	printf 'Usage: %s [-r|--host <arg>] [-u|--user <arg>] [-p|--pass <arg>] [-g|--(no-)go] [-d|--(no-)skip-download] [-i|--(no-)skip-import] [--(no-)psql] [--(no-)maria] [--(no-)locale-fix] [--(no-)include-roles] [-h|--help] [<dbname-1>] ... [<dbname-n>] ...\n' "$0"
	printf '\t%s\n' "<dbname>: The name of the database we are importing"
	printf '\t%s\n' "-r, --host: Remote database host (no default)"
	printf '\t%s\n' "-u, --user: Remote database user (no default)"
	printf '\t%s\n' "-p, --pass: Remote database password (no default)"
	printf '\t%s\n' "-g, --go, --no-go: Perform import (off by default)"
	printf '\t%s\n' "-d, --skip-download, --no-skip-download: Skip download step (off by default)"
	printf '\t%s\n' "-i, --skip-import, --no-skip-import: Skip import step (off by default)"
	printf '\t%s\n' "--psql, --no-psql: Use PostgreSQL mode (off by default)"
	printf '\t%s\n' "--maria, --no-maria: Use MariaDB mode (off by default)"
	printf '\t%s\n' "--locale-fix, --no-locale-fix: Replace known Windows locale with Unix (PostgreSQL only) (on by default)"
	printf '\t%s\n' "--include-roles, --no-include-roles: Grab all roles from target server (PostgreSQL only) (off by default)"
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
			--no-psql|--psql)
				_arg_psql="on"
				test "${1:0:5}" = "--no-" && _arg_psql="off"
				;;
			--no-maria|--maria)
				_arg_maria="on"
				test "${1:0:5}" = "--no-" && _arg_maria="off"
				;;
			--no-locale-fix|--locale-fix)
				_arg_locale_fix="on"
				test "${1:0:5}" = "--no-" && _arg_locale_fix="off"
				;;
			--no-include-roles|--include-roles)
				_arg_include_roles="on"
				test "${1:0:5}" = "--no-" && _arg_include_roles="off"
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


assign_positional_args()
{
	local _positional_name _shift_for=$1
	_positional_names=""
	_our_args=$((${#_positionals[@]} - 0))
	for ((ii = 0; ii < _our_args; ii++))
	do
		_positional_names="$_positional_names _arg_dbname[$((ii + 0))]"
	done

	shift "$_shift_for"
	for _positional_name in ${_positional_names}
	do
		test $# -gt 0 || break
		eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
		shift
	done
}

parse_commandline "$@"
assign_positional_args 1 "${_positionals[@]}"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

if [[ $_arg_go == 'on' && -z $_arg_dbname ]]; then
	echo 'Must specify a database to import'
	exit 1
fi

if [[ $_arg_psql == 'on' ]]; then
	DB_MODE="psql"
elif [[ $_arg_maria == 'on' ]]; then
	DB_MODE="maria"
elif [[ -n $PG_VERSION ]]; then
	DB_MODE="psql"
elif [[ -n $MARIADB_VERSION ]]; then
	DB_MODE="maria"
else
	echo 'Unable to automatically detect which database mode should be used'
	echo 'Please use one of --psql or --maria to insist which'
	exit 1
fi

rdbs="${_arg_dbname[@]}"

if [[ $_arg_skip_download == 'off' ]]; then
	echo -n 'Retrieving size information for '
	if [[ -n $_arg_dbname ]]; then
		if [[ $DB_MODE == 'psql' ]]; then
			db_name_field="d.datname"
		else
			db_name_field="table_schema"
		fi
		echo "remote database(s) '$rdbs'"
		schema_filter="$db_name_field IN ('$_arg_dbname'"
		for (( i=1; i<${#_arg_dbname[@]}; i++ )); do
			schema_filter+=",'${_arg_dbname[$i]}'"
		done
		schema_filter+=')'
	else
		echo 'all remote databases'
	fi

	if [[ $DB_MODE == 'psql' ]]; then
		remote_size="
		SELECT d.datname as Database,  pg_catalog.pg_get_userbyid(d.datdba) as Owner,
    CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
        THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
        ELSE 'No Access'
    END as Size
		FROM pg_catalog.pg_database d
		${schema_filter:+WHERE $schema_filter}
    ORDER BY
    CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
        THEN pg_catalog.pg_database_size(d.datname)
        ELSE NULL
    END DESC;
		"
		# credit to: https://stackoverflow.com/a/70843687

		marg_h=${_arg_host:+"-h$_arg_host"}
		marg_u=${_arg_user:+"-U$_arg_user"}
		echo $remote_size | PGPASSWORD=$_arg_pass psql $marg_h $marg_u --no-password
	else
		remote_size="
		SELECT
			table_schema AS 'Database'
			,COUNT(*) AS '#Tables'
			,ROUND(SUM(table_rows)/1000000,4) AS '#Rows (M)'
			,ROUND(SUM(data_length+index_length)/(1024*1024),4) 'Size (Mb)'
		FROM information_schema.TABLES
		WHERE table_schema <> 'information_schema'
		${schema_filter:+AND $schema_filter}
		GROUP BY table_schema
		ORDER BY SUM(data_length+index_length)
		DESC;
		"

		marg_h=${_arg_host:+"-h$_arg_host"}
		marg_u=${_arg_user:+"-u$_arg_user"}
		marg_p=${_arg_pass:+"-p$_arg_pass"}
		echo $remote_size | mysql -t $marg_h $marg_u $marg_p
	fi
fi

if [[ $_arg_go == 'on' ]]; then
	if [[ -d ./temp/sync_db/ ]]; then
		pushd ./temp/sync_db/ &> /dev/null
		intempdir=yes
	fi
	if [[ $DB_MODE == 'psql' ]]; then
		temp_file="${rdbs// /+}.tar.gz"
	else
		temp_file="${rdbs// /+}.sql.gz"
	fi
	if [[ $_arg_skip_download == 'off' ]]; then
		echo "Performing download of '$rdbs'"
		if [[ $DB_MODE == 'psql' ]]; then
			__out_files=()
			if [[ $_arg_include_roles == 'on' ]]; then
				PGPASSWORD=$_arg_pass pg_dumpall $marg_h $marg_u --no-password --roles-only --no-role-passwords | pv -trb -N roles > "roles"
				__out_files+=("roles")
			fi
			for (( i=0; i<${#_arg_dbname[@]}; i++ )); do
				__db=${_arg_dbname[$i]}
				__file="${__db// /_}"
				__out_files+=($__file)
				PGPASSWORD=$_arg_pass pg_dump $marg_h $marg_u --no-password --create --clean --if-exists --dbname="$__db" | pv -trb -N $__file > $__file
				if [[ $_arg_locale_fix == 'on' ]]; then
					sed -i "s|LOCALE = 'English_United States.1252'|LOCALE = 'en_US.utf8'|" $__file
				fi
			done
			tar -czf $temp_file ${__out_files[@]} --remove-files
		else
			mysqldump --lock-tables=false --single-transaction=true --default-character-set=latin1 $marg_h $marg_u $marg_p --add-drop-database --databases $rdbs | pv -trb | gzip > "$temp_file"
		fi
	fi
	if [[ -r $temp_file && $_arg_skip_import == 'off' ]]; then
		echo 'Importing data to local database'
		if [[ $DB_MODE == 'psql' ]]; then
			PGPASSWORD=$POSTGRES_PASSWORD tar -xzf $temp_file --to-command="pv -trbp -N \$TAR_FILENAME -s \$TAR_SIZE | psql -U$POSTGRES_USER --quiet --output=/dev/null"
		else
			pv "$temp_file" | gunzip | mysql -uroot --password="$MARIADB_ROOT_PASSWORD"
		fi
	fi
	if [[ -n $intempdir ]]; then
		popd &> /dev/null
	fi
fi

exit 0

# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^

# ] <-- needed because of Argbash
