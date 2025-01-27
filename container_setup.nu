let pub_php_ini_defaults = '/mnt/php_ini'

let steps = {
	dumpPHPINI:'Retrieving PHP defaults'
}

# emit php settings on demand
if ($pub_php_ini_defaults | path exists) {
	cp /usr/local/etc/php/php.ini-* $pub_php_ini_defaults
}

