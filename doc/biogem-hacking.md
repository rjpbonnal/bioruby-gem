# Hacking biogem

Biogem is a Ruby code generator for bioinformatics. It generates a plugin, in the
form of a gem, which is published automatically on both github and rubygems.org.

In this document we discuss the design of the biogem code generator, and ways to
hack it.

## Introduction

Biogem builds on [Jeweler](https://github.com/technicalpickles/jeweler).

Jeweller comes with a library for managing and releasing RubyGem projects, and
a scaffold generator for starting new RubyGem projects. Using typical Ruby
overrides Biogem subverts Jeweler for our bioinformatics needs.

## Invoking the code generator

In the file ./bin/biogem rake, jeweler and bundler support are loaded and
Bio::Gem::Generator::Application invoked, which generates the new directory and
files. Thereafter biogem changes directory and runs some rake commands.

## Inside Bio::Gem::Generator::Application

First Jeweler::Generator.run is run, so the basic scaffolding exists for Rake,
tests etc. Nothing special so far. Where it gets interesting is that biogem
overrides Jeweler classes in [./lib/bio-gem/mod/jeweler.rb](https://github.com/helios/bioruby-gem/blob/master/lib/bio-gem/mod/jeweler.rb). At runtime
Jeweler::Generator.new is replaced with our own version, which calls the
original first, but continues to plug in information. It is important to 
check out this file, as many overrides are defined here. Also have a look at
the *create_files* function. That is where directories and files are generated from 
templates.

## Options

The application generator is programmed from biogem command line options. These
options are listed in [jeweler/options.rb](https://github.com/helios/bioruby-gem/blob/master/lib/bio-gem/mod/jeweler/options.rb).

## Templates

Biogem templates are listed in [./lib/bio-gem/templates](https://github.com/helios/bioruby-gem/tree/master/lib/bio-gem/templates). These templates use erb to tune content within.

Templates are by in the jeweler.rb override (described above). For example the Rakefile is 
generated with

        output_template_in_target 'Rakefile'

it is all fairly straightforward. 

## Check out the jeweler source code

From the above you can see how we reprogram Jeweller for our needs. To find new ways
of generating code, we strongly suggest to also check out the [jeweller source code](https://github.com/technicalpickles/jeweler/tree/master/lib). The Jeweller code base is well thought out, and stable.

## DRY

This document should help you preventing repeating yourself. Code generation can be very useful. When
you have something bioinformatics, add it to biogem. When it is more generic, add it to Jeweller. That 
will make a lot of people happy.





