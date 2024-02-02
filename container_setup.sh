#!/bin/bash

# set -e #stop on error
# set -x #echo all lines to console

context_mount=/mnt/context
pub_php_ini_defaults=/mnt/php_ini
php_ini_defaults_path=/usr/src/php         # php 5.4
php_ini_defaults_path2=/usr/local/etc/php  # php 7.4

# colors
[[ -t 1 ]] || export TERM=dumb
declare -A colors_fg
colors_fg[black]=$(tput setaf 0)
colors_fg[red]=$(tput setaf 1)
colors_fg[green]=$(tput setaf 2)
colors_fg[yellow]=$(tput setaf 3)
colors_fg[blue]=$(tput setaf 4)
colors_fg[purple]=$(tput setaf 5)
colors_fg[cyan]=$(tput setaf 6)
colors_fg[white]=$(tput setaf 7)

_txt_fg_default=${colors_fg[white]}
echo $_txt_fg_default

black() { printf "${colors_fg[$FUNCNAME]}$1$_txt_fg_default"; }
red() { printf "${colors_fg[$FUNCNAME]}$1$_txt_fg_default"; }
green() { printf "${colors_fg[$FUNCNAME]}$1$_txt_fg_default"; }
yellow() { printf "${colors_fg[$FUNCNAME]}$1$_txt_fg_default"; }
blue() { printf "${colors_fg[$FUNCNAME]}$1$_txt_fg_default"; }
purple() { printf "${colors_fg[$FUNCNAME]}$1$_txt_fg_default"; }
cyan() { printf "${colors_fg[$FUNCNAME]}$1$_txt_fg_default"; }
white() { printf "${colors_fg[$FUNCNAME]}$1$_txt_fg_default"; }

if [[ -d $pub_php_ini_defaults ]]; then
	printf "Retrieving PHP defaults %s " $(blue '...')
	if [[ -d $php_ini_defaults_path ]]; then
		cp $php_ini_defaults_path/php.ini-* $pub_php_ini_defaults/
	else
		cp $php_ini_defaults_path2/php.ini-* $pub_php_ini_defaults/
	fi
	echo $(yellow 'copied')
fi

if [[ -n $PHP_WORK_DIRS ]]; then
	printf "PHP workspaces %s %s\n" $(blue '............') $(yellow 'creating')
	IFS=';'
	for dir in $PHP_WORK_DIRS; do
		if [[ -d $dir ]]; then
			printf $(green '  _ ')
		else
			mkdir -p $dir # &> /dev/null
			printf $(blue '  + ')
		fi
		chown -R www-data:www-data $dir
		echo $dir
	done

fi

exec php-fpm

# prompt_quit() {
# 	local res prompt=${1:-"Proceed?"}
# 	read -n1 -p "$prompt [yN]" res
# 	if [[ ! ($res == 'y' || $res == 'Y') ]]; then
# 		exit 1
# 	fi
# }

# if [ ! -d $context_mount ]; then
# 	echo "This container requires a context mount for proper operation"
# 	printf 'Please mount a volume to: %s\n' $(purple $context_mount)
# 	echo
# 	exit 1
# fi
