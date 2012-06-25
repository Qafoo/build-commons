=====================
Use Case: PHP Library
=====================

Lets take a look at the build configuration of a custom PHP library not
following the standard Maven directory structure. As an example we pick the
`Zeta Components Graph component`__.

__ http://zetacomponents.org/documentation/trunk/Graph/tutorial.html

The source code of the components (including the build setup) is available at:
https://github.com/zetacomponents/Graph

The ``build.properties`` file looks like this::

    project.name = Zeta Components Graph component
    project.version = 1.6.0
    project.stability = stable

    # The commons based directory will be used to calculate several build related
    # paths and directories. Therefore we will keep it separated and independent for
    # each component in the component's basedir.
    commons.basedir = ${basedir}

    # Base directories with PHP source and test files
    commons.srcdir = ${basedir}/src
    commons.srcdir.php = ${basedir}/src
    commons.testdir.php = ${basedir}

    codesniffer.standard = Ezc
    codesniffer.standard.package.name = PHP_CodeSniffer_Standards_EZC
    codesniffer.standard.package.channel = pear.xplib.de

The first three settings define the project name, version and stability level.
These properties are most important during packaging / releases. This is not
yet automated using ABC in this project, but might be in the future.

By the default the build directory resides one directory level above the
``build.xml`` file (respectively the configured basedir). But since components
might have different dependencies this project decided to keep the build
directory in the components directory. Thus the build will create a ``build``
directory in the directory where the ``build.xml`` is.

The next three settings are probably the most important settings. They define
where the project source and the project tests can be found. By default the
Apache Maven directory layout is used, but this is quite uncommon for PHP
projects. In this case we define that the source sits under ``src/`` -- this is
everything we want to release and everything which should go through static
source code analysis, and so on. In this project the ``phpunit.xml`` is in the
project root, so we also set the ``commons.testdir.php`` to the root directory.
Doing this ABC will find the tests and analyze the correct source code.

The last set of configuration options configures PHP_CodeSniffer. Since the
PHP Community did not really agree on a general Coding Style you always will
ahve to configure this extension to make it work. We set the name of the coding
standard, the name of the pear package and the pear channel server name, from
which the package can be installed.

Executing The Build
===================

If we call ``ant`` now, it will use the local ``build.xml`` and the
``build.properties`` we just defined. Always execute ant in the directory where
the ``build.xml`` resides. But what happens now?

If this is the first run, ABC will first install all required tools for the
build locally. This means installing packages like PEAR, PHPUnit, PHPMD,
PDepend, PHPCPD and some more. This might take a bit.

Also in the first run already, and in every consecutive run ant will execute
your default build target, which usually is ``verify``. This way it will verify
your project using tools like, PHPUnit, PHPMD, PDepend, PHPCPD, PHP_Codesniffer
and more. This might look something like this::

    $ ant verify
    Buildfile: /path/to/build.xml

    -clean:clean:
       [delete] Deleting directory /path/to/build

    [... a lot of output ...]

    BUILD SUCCESSFUL
    Total time: 5 seconds

The ``BUILD SUCCESSFUL`` part is the important. Ant itself will produce quite
some output, which is stripped down here. It helps a bit to use the following
alias definition: ``alias ant='ant -logger org.apache.tools.ant.NoBannerLogger'``.

If the build failed you can check ``build/logs`` for all build results. There
are also the build results / artifacts you'd publish in tools like Jenkins.


..
   Local Variables:
   mode: rst
   fill-column: 79
   End:
   vim: et syn=rst tw=79
