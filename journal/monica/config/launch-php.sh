#!/bin/bash

# wait for the database to start
waitfordb() {
    TERM=dumb php -- <<'EOPHP'
<?php
function env(string $name, ?string $default = null): ?string
{
    $val = getenv($name);
    return $val === false ? $default : $val;
}

$stderr = fopen('php://stderr', 'w');

if (! env('DATABASE_URL')) {
    $host = env('DB_HOST', '127.0.0.1');
    $port = (int) env('DB_PORT', '3306');
    $user = env('DB_USERNAME', 'homestead');
    $pass = env('DB_PASSWORD', 'secret');
    $database = env('DB_DATABASE', 'monica');
    $socket = env('DB_UNIX_SOCKET');
} else {
    $url = parse_url(env('DATABASE_URL'));
    $host = $url['host'];
    $port = array_key_exists('port', $url) ? (int) $url['port'] : 0;
    $user = $url['user'];
    $pass = $url['pass'];
    $database = ltrim($url['path'], '/');
    $socket = null;
    if ($url['query'] && strpos($url['query'], 'unix_socket=') !== false) {
        $socket = substr($url['query'], strlen('unix_socket='));
    }
}

$collation = ((bool) env('DB_USE_UTF8MB4', true)) ? ['utf8mb4','utf8mb4_unicode_ci'] : ['utf8','utf8_unicode_ci'];

$maxAttempts = 30;
$mysql = null;
do {
    try {
        $mysql = new mysqli($host, $user, $pass, '', $port, $socket);
        break;
    } catch (\mysqli_sql_exception $e) {
        fwrite($stderr, "\n" . 'Waiting for database to settle...');
        sleep(1);
    }
    --$maxAttempts;
} while ($maxAttempts > 0);

if ($maxAttempts <= 0 || $mysql === null) {
    fwrite($stderr, "\n" . 'Unable to contact your database');
    if ($mysql !== null) {
        fwrite($stderr, "\n" . 'MySQL Connection Error: (' . $mysql->connect_errno . ') ' . $mysql->connect_error . "\n");
        $mysql->close();
    }
    exit(1);
}

fwrite($stderr, "\n" . 'Database ready.');

$createDatabase = $mysql->query('CREATE DATABASE IF NOT EXISTS `' . $mysql->real_escape_string($database) . '` CHARACTER SET ' . $collation[0] . ' COLLATE ' . $collation[1]);
if ($createDatabase === false) {
    fwrite($stderr, "\n" . 'MySQL "CREATE DATABASE" Error: ' . $mysql->error . "\n");
    $mysql->close();
    exit(2);
}

$mysql->close();
EOPHP
}

MONICADIR=/var/www/html
ARTISAN="php ${MONICADIR}/artisan"

# Ensure storage directories are present
STORAGE=${MONICADIR}/storage
mkdir -p ${STORAGE}/logs
mkdir -p ${STORAGE}/app/public
mkdir -p ${STORAGE}/framework/views
mkdir -p ${STORAGE}/framework/cache
mkdir -p ${STORAGE}/framework/sessions
#chown -R www-data:www-data ${STORAGE}
#chmod -R g+rw ${STORAGE}

if [ -z "${APP_KEY:-}" -o "$APP_KEY" = "ChangeMeBy32KeyLengthOrGenerated" ]; then
    ${ARTISAN} key:generate --no-interaction
else
    echo "APP_KEY already set"
fi

# Run migrations
waitfordb
${ARTISAN} monica:update --force -vv

if [ ! -f "${STORAGE}/oauth-public.key" -o ! -f "${STORAGE}/oauth-private.key" ]; then
    echo "Passport keys creation ..."
    ${ARTISAN} passport:keys
    ${ARTISAN} passport:client --personal --no-interaction
    echo "! Please be careful to backup $MONICADIR/storage/oauth-public.key and $MONICADIR/storage/oauth-private.key files !"
fi


exec /usr/local/sbin/php-fpm