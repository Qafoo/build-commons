===========================
Initial Notes about ABC 2.x
===========================

Software Lifecylce
==================

Mostly the old software lifecycle will be reused:

1. validate
2. initialize
3. compile
4. link (new step -- replaces bundle)
5. test
6. package
7. integration-test
8. verify
9. deploy

``clean`` will be isolated from the rest, to allow a possibility to integrate
pipelining (save/restore-state)

The three execution phases for each step (``before``, ``main`` and ``after``)
remain intact. Maybe ``main`` is renamed (name of the extension?)

Pipelining
==========

- Save the build state after an arbitrary target
- Restore the state at this position at any time to rerun all steps after that
- Maybe allow for providing an arbitrary identifier to be used for saving
  - ``-Dsave.state="foobar"``
  - ``-Drestore.state="foobar"``

CLI-Tool
========

Simple CLI-Tool installable through composer to initialize a new abc
environment, as well as provide scaffolding capabilities to create new
extensions and stuff.

Archictecture Types
===================

There is **one** arch-type per project. An archtype may define a set of used
**profiles**. Profiles may aggregate each other::

    .
    ├── JavaScript
    │   ├── Analysis
    │   │   └── Linter
    │   │       ├── JSHint
    │   │       └── JSLint
    │   └── Testing
    │       └── Karma
    └── PHP
        ├── Analysis
        │   └── Linter
        │       └── phpl
        └── Testing
            ├── PHPUnit
            └── Sahi

Profiles are activated or deactivated on a arch-type level. Arch-types are
defined using property files::

    profile.javascript = enable
    profile.javascript.testing = disable
    profile.javascript.linter = disable
    profile.javascript.linter.jshint = enable

    profile.php.analysis = enable

Profile rules are prioritized by their nesting level. Every rule which is more
specific than another will be prioritized before it:

``profile.javascript.linter.jshint`` will have a higher priority than
``profile.javascript``. The order in which the rules are defined is of no
interest.


Naming Structure
================

Directories, tasknames and profile names are required to match each other.

Directory:
    - ``Extensions/JavaScript/Linter/JSLint/Extension.xml``
    - ``Extensions/JavaScript/Linter/JSLint/Extension.properties``
    - ``Extensions/JavaScript/Linter/JSLint/Configure.xml``

Taskname:
    - ``-abc:javascript:linter:jslint:extension``
    - ``-abc:javascript:linter:jslint:someInternalTask``

Profile:
    - ``profile.javascript.linter.jslint``


Task Aliases
------------

All main extension entrypoints need to have a public alias to their extension name:

``-abc:javascript:linter:jslint:extension`` is aliased to
``javascript:linter:jslint``.

Extensionpoint Dependencies
---------------------------

Every extension entrypoint needs to depend on ``abc:extension``. This task may
then initialize the base environment, if a extension is called directly.


Documentation
=============

Each extension needs to provide some sort of documentation, which may accessed
on a profile level as well:

- List every extension
- List every extension below ``javascript``
- List every extension below ``javascript.linter``
- ...

.. note:: It needs to be determined if an how this can be done properly.

Configure Step
==============

One of the biggest changes made with the 2.x branch is the introduction of
a **configure** step. This step is executed before anything else and bootstraps
a build environment for a certain build configuration into a given directory.

This **configure** step is equivalent to a ``autoconf`` ``./configure`` or
a ``cmake`` ``cmake ./builddir``.

It creates a new environment inside the given directory ready for building the
current project. Switching to the directory and calling ``ant`` there executes
the build process.

Precompiled build.xml
---------------------

During **configure** a *new* ``build.xml`` is created. It contains the abc base
environment, the software lifecycle as well as any currently enabled
**profile**.

This file is the minimal needed version of the buildenvironment to satisfy all
enabled profiles and tasks.

Dependency install/management
-----------------------------

During the **configure** phase all needed dependencies for active **profiles**
are loaded and installed to the build directory. Therefore effectively
preparing everything needed for a build to be run.



..
   Local Variables:
   mode: rst
   fill-column: 79
   End: 
   vim: et syn=rst tw=79
