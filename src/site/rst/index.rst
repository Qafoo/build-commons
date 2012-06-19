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

Configuration
=============

There is a set of base configuration options:

- `Base configuration options`__

__ configuration.html

And each extension has its own set of extension options:

.. include:: extensions.rst

Standard Build Chain
====================

.. image:: build_chain.svg

Bla bla…


..
   Local Variables:
   mode: rst
   fill-column: 79
   End: 
   vim: et syn=rst tw=79
