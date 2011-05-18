#!/usr/bin/env php -d phar.readonly=0
<?php

if ( count( $argv ) < 4 )
{
    echo 'Usage: create.phar.php <project> <output-file> <input-dir> [<bootstrap>]', PHP_EOL;
    exit( 1 );
}

$project = $argv[1] . '.phar';
$output  = $argv[2];
$input   = realpath( $argv[3] );

if ( isset( $argv[4] ) && trim( $argv[4] ) !== '' )
{
    $stub = file_get_contents( $argv[4] );
}
else
{
    $stub = '<?php Phar::mapPhar("${archive.alias}"); __HALT_COMPILER(); ?>';
}

$phar = new Phar( $output, 0, $project );
$phar->buildFromDirectory( $input );
$phar->setStub( str_replace( '${archive.alias}', $project, $stub ) );
