# Hacking biogem

Biogem is a Ruby code generator for bioinformatics. It generates a plugin, in
the form of a gem, which is published automatically on both github and
rubygems.org.

In this document we discuss ways to modify Biogem, so you can generate your own
code, and avoid repetitious work. The design of the biogem code generator is based on
templates, and there are accessible ways to hack it, or even add your own templates.

This document is divided into two sections. In the first section we will create
a directory, generate a file through a template, and add a test through a
helper. In the second section we will modify some undesired behaviour in biogem
through meta-programming.

## Check out the source


To change biogem, checkout the source tree to your local machine. E.g.

```sh
      git clone https://github.com/helios/bioruby-gem.git
      cd bioruby-gem
      bundle
```

Make sure you are running a supported version of Ruby (check the README). 
Now you can invoke biogem with

```sh
      bundle exec ./bin/biogem foo
```

which will create the bioruby-foo plugin for testing. Every time you rerun biogem, make
sure to remove the bioruby-foo directory first

```sh
      rm -rf bioruby-foo ; bundle exec ./bin/biogem foo
```

## Invoking the Biogem code generator

In the file ./bin/biogem rake, jeweler and bundler support are loaded and
Bio::Gem::Generator::Application invoked, which generates the new directory and
files. After generating code biogem changes directory and runs some rake
commands in the newly generated plugin.

## Add an CLI option to Biogem

In the first step we want to add a switch to the biogem command line. For our 
purpose we will add --with-ffi, a switch which will create a template for a foreign
function interface. Switches are defined in [options.rb](https://github.com/helios/bioruby-gem/blob/master/lib/bio-gem/mod/jeweler/options.rb). We add
a switch with

```ruby
          o.on('--with-ffi', 'generate a foreign function interface (FFI)') do
            self[:biogem_ffi] = true
          end
```

This switch will be available as *options[:biogem_ffi]* further on.

## Create a directory

In the method *create_files* in Biogem [jeweler.rb](https://github.com/helios/bioruby-gem/blob/master/lib/bio-gem/mod/jeweler.rb) directories and files get
created. For example the plugin library file is generated with

```ruby
        # Fill lib/bio-plugin.rb with some default comments
        output_template_in_target_generic 'lib', File.join(lib_dir, lib_filename)
```

which also creates the directory. We explicitly add a directory to store C 
source files and headers with

```ruby
        create_ffi_structure if options[:biogem_ffi]
```

and

```ruby
        def create_ffi_structure
          # create ./ext/src and ./ext/include for the .c and .h files
          mkdir_in_target(ext_dir)
          mkdir_in_target(File.join(ext_dir,"src"))
          # create ./lib/ffi for the Ruby ffi
          mkdir_in_target(File.join(lib_dir,"ffi"))
        end
```

## Generate file from template

Templates are stored in lib/bio-gem/templates. We create a template for
our C extension named [ext.c](https://github.com/helios/bioruby-gem/tree/master/lib/bio-gem/templates/ffi/ext.c), e.g. the C function

```ruby
        int add_one(int number) {
          return number + 1;
        }
```

which gets copied into the plugins ./ext/src directory with 

```ruby
        output_template_in_target_generic File.join('ffi','ext.c'), File.join(src_dir, "ext.c" )
```

Likewise, an include file ext.h gets copied, a Makefile, and the Ruby ffi file, which defines the bindings to ext.c.

(to be continued)

## Modify a generated file with a helper

Generate tests by adding a helper

(to be continued)

## Adapt the Rakefile

The Rakefile needs to be adapted to compile the C file(s).

(to be continued)

# Hacking jeweler for Biogem 

The following section discusses surgical changes to biogem.

''Warning, the rest of this document is about Ruby meta-programming. It is not for the faint of 
heart.''

Biogem builds on [Jeweler](https://github.com/technicalpickles/jeweler).

jeweler comes with a library for managing and releasing RubyGem projects, and
a scaffold generator for starting new RubyGem projects. Using typical Ruby
overrides of jeweler methods, also known as meta-programming, Biogem subverts
Jeweler for our bioinformatics needs (see jeweler::Generator.new example below).

## Invoking the Biogem code generator

In the file ./bin/biogem rake, jeweler and bundler support are loaded and
Bio::Gem::Generator::Application invoked, which generates the new directory and
files. Thereafter biogem changes directory and runs some rake commands.

## Inside Bio::Gem::Generator::Application

First Jeweler::Generator.run is run, so the basic scaffolding exists for Rake,
tests etc. Nothing special so far. Where it gets interesting is that biogem
overrides Jeweler classes in [./lib/bio-gem/mod/jeweler.rb](https://github.com/helios/bioruby-gem/blob/master/lib/bio-gem/mod/jeweler.rb). In this file, at runtime,
Jeweler::Generator.new is replaced with our own version, which calls the
original first, but continues to plug in information. Any time jeweler::Generator.new is called,
our edition is called. Even from within jeweler!

It is important to check out this file, as many overrides are defined here.
Also have a look at the *create_files* function. That is where directories and
files are generated from templates.

## Biogem options

The application generator is programmed from biogem command line options. These
options are listed in [jeweler/options.rb](https://github.com/helios/bioruby-gem/blob/master/lib/bio-gem/mod/jeweler/options.rb).

## Biogem templates

Biogem templates are listed in [./lib/bio-gem/templates](https://github.com/helios/bioruby-gem/tree/master/lib/bio-gem/templates). These templates use erb to tune content within.

Templates are by in the jeweler.rb override (described above). For example the Rakefile is 
generated with

```ruby
        output_template_in_target 'Rakefile'
```

it is all fairly straightforward. 

## Check out the jeweler source code

From the above you can see how we reprogram jeweler for our needs. To find new
ways of generating code, we strongly suggest to also check out the [jeweler
source code](https://github.com/technicalpickles/jeweler/tree/master/lib). The
jeweler code base is well thought out, and stable.

## Changing jeweler behaviour

Just as an example we are going to override code generated by Jeweler. Jeweler generates
a dependency for rcov, a Ruby code coverage analyzer. We are going to remove this dependency, 
without touching the Jeweler code base.

In the Jeweler source code tree rcov is used in two files:

```ruby
        grep -r rcov *
        jeweler/generator.rb:      development_dependencies << ["rcov", ">= 0"]
        jeweler/templates/other_tasks.erb:RSpec::Core::RakeTask.new(:rcov) do |spec|
        jeweler/templates/other_tasks.erb:  spec.rcov = true
        jeweler/templates/other_tasks.erb:Micronaut::RakeTask.new(:rcov) do |examples|
        jeweler/templates/other_tasks.erb:  examples.rcov_opts = '-Ilib -I<%= test_dir %>'
        jeweler/templates/other_tasks.erb:  examples.rcov = true
        jeweler/templates/other_tasks.erb:require 'rcov/rcovtask'
        jeweler/templates/other_tasks.erb:  <%= test_task %>.rcov_opts << '--exclude "gems/*"'
```

The first step is to remove the rcov entry from development_dependencies. This can be
done by adding a line in Biogems lib/bio-gem/mod/jeweler.rb. Change it to 

```ruby
        class Jeweler
          class Generator 
            alias original_initialize initialize
            def initialize(options = {})
              original_initialize(options)
              development_dependencies << ["bio", ">= 1.4.2"]
              development_dependencies.delete_if { |k,v| k == "rcov" }
              (...) 
```

You can see here that BioRuby support is always added. The next step is to change 
the behaviour of jeweler/templates/other_tasks.erb. The code to generate the
Rakefile lists is 

```ruby
        <% case testing_framework %>
        <% when :rspec %>
          (...)
        <% when :micronaut %>
          (...)
        <% else %>
        require 'rcov/rcovtask'
        Rcov::RcovTask.new do |<%= test_task %>|
          (...)
        end
        <% end %>
```

and, annoyingly, shows that rcov is always added by default (in the final
'else'). We should communicate with the author of Jeweler to fix this. However, we
also have the option to override the Rakefile generator. The jeweler Rakefile
template has the form

```ruby
        require 'rubygems'
        <%= render_template 'bundler_setup.erb' %>
        require 'rake'
        <%= render_template 'jeweler_tasks.erb' %>
        <%= render_template 'other_tasks.erb' %>
```

The two important functions in jeweler.rb are:

```ruby
    def render_template(source)
      template_contents = File.read(File.join(template_dir, source))
      template          = ERB.new(template_contents, nil, '<>')
      # squish extraneous whitespace from some of the conditionals
      template.result(binding).gsub(/\n\n\n+/, "\n\n")
    end

    def output_template_in_target(source, destination = source)
      final_destination = File.join(target_dir, destination)
      template_result   = render_template(source)
      File.open(final_destination, 'w') {|file| file.write(template_result)}
      $stdout.puts "\tcreate\t#{destination}"
    end
```

these find the templates and render them through ERB. 

Naturally, Biogem has needed some overriding behaviour.  In this case Biogems jeweler.rb
has

```ruby
    def output_template_in_target_generic_update(source, destination = source, template_dir = template_dir_biogem)
      final_destination = File.join(target_dir, destination)
      template_result   = render_template_generic(source, template_dir)
      File.open(final_destination, 'a') {|file| file.write(template_result)}
      $stdout.puts "\tcreate\t#{destination}"
    end    
```

and, in the case of the --with-db option, the Rakefile already gets modified by Biogem

```ruby
    output_template_in_target_generic 'rakefile', 'Rakefile', template_dir_biogem
```

So, what would be the best route here, to change biogem behaviour? We have to rewrite
the Rakefile template to remove the rcov lines. We can 
change the *render_template* to allow rewriting the template. Unfortunately there is no
existing hook for that in jeweler. So, let us inject a hook named *after_render_template*
to a *render_template* override. First we open the Jeweler::Generator class and move the method to biogem jeweler.rb, renaming the original method to original_render_template:

```ruby
        class Jeweler
          class Generator 
            alias original_render_template render_template
            def render_template(source)
              buf = original_render_template(source)
              # call hook (returns edited buf)
              after_render_template(source,buf)
            end

            # new hook for removing stuff
            def after_render_template(source,buf)
              if source == 'other_tasks.erb'
                # remove rcov related lines
                buf.gsub!(/require 'rcov/rcovtask'/,'')
                (...)
              end
            end
```

you probably get the gist (the stuff you can do with Ruby meta-programming!).
The solution chosen overrides original jeweler behaviour without touching
jeweler itself. Naturally, if it can be handled in jeweler, it is strongly
preferred.  With our solution a small change in jeweler may now break biogem
(in software engineering terms: the fix is brittle).

In fact, the jeweler author has responded that the default behaviour for rcov will change now. I.e.
our fix will go upstream.

Still, for stuff that will not go into jeweler, this is a way of changing
behaviour.

## DRY (Do not repeat yourself)

This document should help you preventing repeating yourself. Code generation
can be very useful. When you have something that is useful to yourself, or
others, and is bioinformatics related, add it to biogem.  When it is more
generic, add it to jeweler. You may make a lot of people happy.

## More on meta-programming

Thanks to Ruby meta-programming we do not have to change jeweler. With another
computer language, we would have cloned jeweler and modified the source code
for our purposes. This would imply a fork of the code base - and the projects
would have diverged irrevocably. As it stands, we can build on the existing
jeweler project. Some 'brittleness' may get introduced, as explained above, but in
general we should normally be able to continue adapting our code base to that
of jeweler.

The Pragmatic programmers book on [Ruby metaprogramming](http://www.amazon.com/Metaprogramming-Ruby-Program-Like-Pros/dp/1934356476/ref=cm_cr_pr_product_top) is recommended reading.

Copyright (C) 2012 Pjotr Prins <pjotr.prins@thebird.nl>
