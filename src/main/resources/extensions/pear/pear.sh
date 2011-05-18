#!/bin/sh

BUILDDIR=/tmp/~create-pear
PEARDIR=$BUILDDIR/pear
PEARCMD=$PEARDIR/pear/php/pearcmd.php
PECLCMD=$PEARDIR/pear/php/peclcmd.php

rm -rf $BUILDDIR

mkdir -p $PEARDIR
cd $BUILDDIR

pear config-create $PEARDIR $PEARDIR/pear.conf
pear -c $PEARDIR/pear.conf channel-update pear.php.net
pear -c $PEARDIR/pear.conf install --alldeps PEAR

sed "s/(.*'@'.'include_path'.'@'.*)/(false)/" $PEARCMD > $PEARCMD.temp
mv $PEARCMD.temp $PEARCMD

sed "s/(.*'@'.'include_path'.'@'.*)/(false)/" $PECLCMD > $PECLCMD.temp
mv $PECLCMD.temp $PECLCMD

echo '<?php ob_start(); set_include_path("." . PATH_SEPARATOR . __DIR__ . "/php"); include "php/pearcmd.php";' > $PEARDIR/pear/index.php

cd $PEARDIR

php -d phar.readonly=0 \
    `which phar` pack  \
    -f pear.phar       \
    -a pear            \
    -c bz2             \
    -h sha512          \
    -i 'pear\/(index|php\/(Ar|Co|OS|PE|St|Sy|XM|pe))' pear

php -d include_path=/tmp pear.phar
