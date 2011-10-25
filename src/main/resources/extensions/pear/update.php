#!/usr/bin/env php
<?php

class AntBuildCommonsExtensionPearPackageUpdate
{
    /**
     * Names of directories that contain data
     *
     * @var array
     */
    private $dataDirectories = array( 'resources' );
    
    /**
     * List of known script/executable extensions.
     *
     * @var array
     */
    private $scriptExtensions = array( 'bat', 'com', 'sh', 'php', 'exe' );
    
    /**
     * Array containing the default file task replace actions.
     *
     * @var array
     */
    private $fileTasks = array(
        array( 'from' => '@package_version@', 'to' => 'version',  'type' => 'package-info' ),
        array( 'from' => '@data_dir@',        'to' => 'data_dir', 'type' => 'pear-config' ),
        array( 'from' => '@php_bin@',         'to' => 'php_bin',  'type' => 'pear-config' ),
        array( 'from' => '@bin_dir@',         'to' => 'bin_dir',  'type' => 'pear-config' ),
        array( 'from' => '/usr/bin/env php',  'to' => 'php_bin',  'type' => 'pear-config' ),
    );

    /**
     * The package manifest file.
     * 
     * @var string
     */
    private $file;

    /**
     * Root directory with source files for the PEAR archive.
     *
     * @var string
     */
    private $directory;
    
    /**
     * The package manifest instance.
     *
     * @var DOMDocument
     */
    private $manifest;

    /**
     * Constructs a new pear package.xml updater instance.
     *
     * @param string $directory
     */
    public function __construct( $directory )
    {
        if ( is_file( $directory ) )
        {
            $this->file      = $directory;
            $this->directory = dirname( $directory );
        }
        else
        {
            $this->file      = $directory . '/package.xml';
            $this->directory = $directory;
        }
    }
    
    public function run()
    {
        $manifest = $this->loadPackageManifest();
        $manifest = $this->cleanContents( $manifest );
        $manifest = $this->updateContents( $manifest );
       
        $manifest->save( $this->getPackageManifestUri() );
    }
    
    private function getPackageManifestUri()
    {
        if ( false === file_exists( $this->file ) )
        {
            throw new ErrorException( 'Cannot locate "package.xml" in "' . $this->directory . '".' );
        }
        return $this->file;
    }
    
    private function loadPackageManifest()
    {
        if ( $this->manifest )
        {
            return $this->manifest;
        }

        $this->manifest                     = new DOMDocument( '1.0' );
        $this->manifest->formatOutput       = true;
        $this->manifest->preserveWhiteSpace = false;
        $this->manifest->load( $this->getPackageManifestUri() );
        
        return $this->manifest;
    }
    
    private function cleanContents( DOMDocument $manifest )
    {
        foreach ( $manifest->getElementsByTagName( 'contents' ) as $element )
        {
            for ( $i = $element->childNodes->length - 1; $i >= 0; --$i )
            {
                $childNode = $element->childNodes->item( $i );

                $element->removeChild( $childNode );
            }
        }
        
        return $manifest;
    }
    
    private function updateContents( DOMDocument $manifest )
    {
        foreach ( $manifest->getElementsByTagName( 'contents' ) as $element )
        {
            $dir = $element->ownerDocument->createElement( 'dir' );
            $dir->setAttribute( 'name', '/' );
            
            $element->appendChild( $dir );
        
            foreach ( new DirectoryIterator( $this->directory ) as $file )
            {
                if ( $file->isDot() || 'package.xml' === $file->getFilename() )
                {
                    continue;
                }
                else if ( $file->isDir() )
                {
                    if ( in_array( $file->getFilename(), $this->dataDirectories ) )
                    {
                        $this->updateContentDir( $dir, $file, 'data' );
                    }
                    else
                    {
                        $this->updateContentDir( $dir, $file, 'php' );
                    }
                }
                else
                {
                    $ext = pathinfo( $file->getFilename(), PATHINFO_EXTENSION );
                    if ( in_array( $ext, $this->scriptExtensions ) )
                    {
                        $this->updateContentFile( $dir, $file, 'script' );
                    }
                    else
                    {
                        $this->updateContentFile( $dir, $file, 'doc' );
                    }
                }
            }
        }
        return $manifest;
    }
    
    public function updateContentDir( DOMElement $parent, SplFileInfo $directory, $role )
    {
        $dir = $parent->ownerDocument->createElement( 'dir' );
        $dir->setAttribute( 'name', $directory->getFilename() );
        
        $parent->appendChild( $dir );
    
        foreach ( new DirectoryIterator( $directory->getRealpath() ) as $file )
        {
            if ( $file->isDot() )
            {
                continue;
            }
            else if ( $file->isDir() )
            {
                $this->updateContentDir( $dir, $file, $role );
            }
            else
            {
                $this->updateContentFile( $dir, $file, $role );
            }
        }
        return $parent;
    }
    
    private function updateContentFile( DOMElement $parent, SplFileInfo $file, $role )
    {
        $elem = $parent->ownerDocument->createElement( 'file' );
        $elem->setAttribute( 'name', $file->getFilename() );
        $elem->setAttribute( 'role', $role );
        
        $parent->appendChild( $elem );
        
        return $this->updateContentFileTasks( $elem );
    }
    
    private function updateContentFileTasks( DOMElement $file )
    {
        foreach ( $this->fileTasks as $fileTask )
        {
            $task = $file->ownerDocument->createElement( 'tasks:replace' );
            $task->setAttribute( 'from', $fileTask['from'] );
            $task->setAttribute( 'to',   $fileTask['to'] );
            $task->setAttribute( 'type', $fileTask['type'] );
            
            $file->appendChild( $task );
        }
        
        return $file;
    }

    public static function main( array $args )
    {
        $updater = new AntBuildCommonsExtensionPearPackageUpdate( $args[0] );
        $updater->run();
    }
}

AntBuildCommonsExtensionPearPackageUpdate::main( array_slice( $argv, 1 ) );
