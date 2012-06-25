=================
Ant Build Commons
=================

ABC (Ant Build Commons) aims to provide standard build tasks for web based
projects. It started by supporting various different PHP related tools, but by
now also support JavaScript and CSS related tools. This involves tools for
verification, testing, static analysis, packaging, deployment and more.

ABC by default follows the Maven__ directory layout and the standard build
chain. ABC is designed to be pluggable and extensible at any point. Every build
extension can be en- and disabled. There are a lot of different extension
points to hook your tasks into.

This documentation will cover common use-cases, where you would want to use
ABC. Additionally it intends to document all extensions and their configuration
options.

__ https://maven.apache.org/

Use cases
=========

An oveview of common use cases for ABC and their common configurations:

- `PHP library`__
- `PHP application`__
- `JavaScript frontend application`__

__ usecase/php_library.html
__ usecase/php_app.html
__ usecase/webapp.html

Standard Build Chain
====================

.. image:: _static/build-chain.png
   :alt:   Standard Build Chain
   :align: right

The standard build lifecycle or chain consists of defined set of steps, which
originate from the `Ant Maven`__ project. Not all steps might be relevant to
your project, but every step has its meaning and extensions can hook into each
of those steps. Usually one extension will hook into one single step, where it
makes the most sense.

__ https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html#Lifecycle_Reference

clean
-----

This steps is supposed to clean up. It usually clears out the build directory,
so that nothing from the last run remains.

Hooks: ``-clean:before~hook``, ``-clean:after~hook``

validate
--------

Validates the project configuration.

Hooks: ``-validate:before~hook``, ``-validate:main~hook``, ``-validate:after~hook``

initialize
----------

Initializes the project configuration.

Hooks: ``-initialize:before~hook``, ``-initialize:after~hook``

compile
-------

Compiles the project source code. For PHP this means, that a lint check will be
run on the source files. For other languages this might be more complex.

Hooks: ``-compile:before~hook``, ``-compile:main~hook``, ``-compile:after~hook``

test
----

Runs the project test suite. Should mostly run only the unit tests of a
project. The integration tests are supposed to run in the ``integration-test``
step against the packaged source.

Hooks: ``-test:main~hook``, ``-test:before~hook``, ``-test:after~hook``

bundle
------

This build steps provides all different kinds of bundling operations, before it
is packaged. This may include javascript compile and/or     minifying, css
minification, image optimization, changelog/releasenote generation and such.

Hooks: ``-bundle:before~hook``, ``-bundle:main~hook``, ``-bundle:after~hook``

package
-------

This is ant file contains targets for different package/distributio formats
used to deliver php application.

Hooks: ``-package:before~hook``, ``-package:main~hook``, ``-package:after~hook``

integration-test
----------------

This ant build file contains targets that are used to perform integration tests
against the project's source code.

Hooks: ``-integration-test:before~hook``, ``-integration-test:after~hook``

verify
------

This is ant file contains targets for different static analysis and quality
checks used for the project source.

These targets are typically run in parallel because the varify analysis can
consume quite some time and it makes sense to use all avialable cores for that.

Hooks: ``-verify:before~hook``, ``-verify:main~parallel~hook``,
``-verify:main~hook``, ``-verify:after~hook``

install
-------

This build file contains targets related to local installation of the current
project.

Hooks: ``-install:before~hook``, ``-install:after~hook``

deploy
------

This build file contains all those targets that are related to the project's
deploy process.

Hooks: ``-deploy:before~hook``, ``-deploy:main~hook``, ``-deploy:after~hook``

Configuration
=============

There is a set of base configuration options you mght want to configure in your
``build.properties`` file.

Project properties
------------------

::

    project.uri       = example.com
    project.dir       = ${basedir}
    project.name      = ${ant.project.name}
    project.version   = 0.0.0
    project.stability = alpha

This set of options describe the very basic general options of your project,
like name, version and the project URL. As you can see by default the name and
base directory will be used from you ``build.xml`` file.

::

    project.root = ${basedir}/src

This option is especially important for packaging and bundling of the project.
All sources below this path will be packaged.

Common properties
-----------------

::

    commons.env = development

The vurrent environment of your project. You might want to reuse this properpty
in your application to determine the current debug-level.

::

    commons.basedir = ${basedir}/..

The directory where the ``build`` directory will be created. By default it is
one level above your ``build.xml`` file (or whatever ``basedor`` you configured
in there). You might want to set it to ``commons.basedir = ${basedir}``.

::

    commons.builddir.name  = build
    commons.distdir.name   = dist
    commons.logsdir.name   = logs
    commons.bundledir.name = bundle
    commons.tempdir.name   = tmp

Names of the directories in the build directory, which are created and used
during the build process.

::

    commons.executable.php = php
    commons.executable.git = git
    commons.executable.make = make
    commons.executable.node = node
    commons.executable.rhino = rhino

Build commons requires some executables to execute various programs during the
build process. The paths to those executables can be overwritten, if they are
named differently ony your system.

::

    commons.srcdir  = ${project.root}/main
    commons.testdir = ${project.root}/test
    commons.sitedir = ${project.root}/site

    # Base directories with PHP source and test files
    commons.srcdir.php  = ${commons.srcdir}/php
    commons.testdir.php = ${commons.testdir}/php

    # Base directory for htdocs/site of the project.
    commons.srcdir.htdocs = ${commons.srcdir}/htdocs

    # Base directories with JavaScript source and test files
    commons.srcdir.js    = ${commons.srcdir}/js
    commons.testdir.js   = ${commons.testdir}/js
    commons.vendordir.js = vendor

    # Base directories with resource files
    commons.srcdir.resource  = ${commons.srcdir}/resources
    commons.testdir.resource = ${commons.testdir}/resources
    commons.sitedir.resource = ${commons.sitedir}/resources

If your project does not follow the Maven directory layout you can change the
paths where the source files are located using this set of configuration
options.

::

    commons.metadata.dir       = ${basedir}/.abc
    commons.metadata.cache.dir = ${commons.metadata.dir}

ABC itself wants to cache some files to make the build process faster. By
default those files are stored in the folder ``.abc``. You can change this
using the two options above.

Extensions
----------

There is a bunch of available extensions, and each can have its own extension
points and configuration parameters:

.. include:: extensions.rst


..
   Local Variables:
   mode: rst
   fill-column: 79
   End:
   vim: et syn=rst tw=79
