<?=str_repeat( "=", strlen( $name ) );?>

<?=ucfirst( $name )?>

<?=str_repeat( "=", strlen( $name ) );?>


@TODO: Add basic module description

<?php if ( count( $properties ) ):?>
Configuration
=============

The following configuration options are available for this extension:

<?php foreach ( $properties as $propertyName => $value ): ?>
``<?=$propertyName?>``
<?=str_repeat( "-", strlen( $propertyName ) + 4 );?>


Default value: ``<?=$value ?: "null"?>``

@TODO: Add description

<?php endforeach; ?>
<?php endif; ?>

<?php if ( count( $extensions ) ):?>
Extension Points
================

This ABC extension has the following extension points:

<?php foreach ( $extensions as $hookName ): ?>
``<?=$hookName?>``
<?=str_repeat( "-", strlen( $hookName ) + 4 );?>


@TODO: Add description

<?php endforeach; ?>
<?php endif; ?>


..
   Local Variables:
   mode: rst
   fill-column: 79
   End: 
   vim: et syn=rst tw=79
