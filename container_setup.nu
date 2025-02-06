use std

let pub_php_ini_defaults = '/mnt/php_ini'

let steps = {
	dump_PHP_INI:'Retrieving PHP defaults'
	create_PHP_workspaces:'PHP Workspaces'
	setup_shell:'Shell Configuration'
}
let step_label_max_size = $steps
	| transpose name value | get value
	| str length | math max

# display operational step with aligned actions and colors
def announce-step [step_key] {
	let val = $steps | get $step_key
	let	dots = '.'
		| std repeat (
			$step_label_max_size + 3
			- ( $val | str length ) )
		| str join ''
	print -n $'(ansi white)($val) (ansi blue)($dots) '
}

# emit php settings on demand
if ($pub_php_ini_defaults | path exists) {
	announce-step dump_PHP_INI
	cp /usr/local/etc/php/php.ini-* $pub_php_ini_defaults
	print $'(ansi green)copied from context(ansi reset)'
}

if ($env.PHP_WORK_DIRS? | is-not-empty) {
	announce-step create_PHP_workspaces
	print $'(ansi green)creating(ansi reset)'
	$env.PHP_WORK_DIRS | split row ';' | each {|path|
		if ($path | path exists) {
			print $'(ansi green)  _ (ansi reset)($path)'
		} else {
			mkdir $path
			print $'(ansi blue)  + (ansi reset)($path)'
		}
		chown -R www-data:www-data $path
	}
}

if (not ('~/.config/nushell/config.nu' | path exists) ) {
	announce-step setup_shell
	mkdir ~/.config/nushell
	[
		'$env.config.show_banner = false'
		'$env.config.buffer_editor = "nvim"'
	] | save ~/.config/nushell/config.nu

	print $'(ansi green)created(ansi reset)'
}

if ($env.GIVE_SHELL | into bool) {
	print ''
	exec nu
} else {
	exec php-fpm
}
