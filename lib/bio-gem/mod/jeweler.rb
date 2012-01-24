#Override Jeweler's classes for properly configure a BioRuby Development Environment/Layout.
# This module should only include methods that are overridden in Jeweler (by
# breaking open the Jeweler::Generator class

require 'bio-gem/mod/jeweler/options'
require 'bio-gem/mod/jeweler/github_mixin'
require 'bio-gem/mod/biogem'

class Jeweler
  class Generator 

    include Biogem::Naming
    include Biogem::Path
    include Biogem::Render
    include Biogem::Github

    alias original_initialize initialize
    def initialize(options = {})
      original_initialize(options)
      development_dependencies << ["bio", ">= 1.4.2"]
      development_dependencies.delete_if { |k,v| k == "rcov" }
      if options[:biogem_db]
        development_dependencies << ["activerecord", ">= 3.0.7"]
        development_dependencies << ["activesupport", ">= 3.0.7"]
        development_dependencies << ["sqlite3", ">= 1.3.3"]
      end
    end

    alias original_project_name project_name  
    def project_name
      name = original_project_name
      return 'bio-'+name if name !~ /^bio-/
      name
    end

    alias original_render_template render_template
    def render_template(source)
      buf = original_render_template(source)
      # call hook (returns edited buf)
      after_render_template(source,buf)
    end

    def target_dir
      project_name.sub('bio','bioruby')
    end      
    alias github_repo_name target_dir  # this a Biogem alias

    alias original_create_files create_files
    # this is the default directory for storing library datasets
    # creates a data directory for every needs.
    #the options are defined in mod/jeweler/options.rb
    def create_files
      if options[:biogem_meta]

        unless File.exists?(target_dir) || File.directory?(target_dir)
          FileUtils.mkdir target_dir
        else
          raise FileInTheWay, "The directory #{target_dir} already exists, aborting. Maybe move it out of the way before continuing?"
        end

        output_template_in_target '.gitignore'
        output_template_in_target 'Rakefile'
        output_template_in_target 'Gemfile'  if should_use_bundler
        output_template_in_target 'LICENSE.txt'
        output_template_in_target 'README.rdoc'
        output_template_in_target '.document'
      else
        original_create_files

        if options[:biogem_test_data]
          mkdir_in_target("test") unless File.exists? "#{target_dir}/test"
          mkdir_in_target test_data_dir  
        end
        create_ffi_structure if options[:biogem_ffi]
        create_db_structure if options[:biogem_db]
        if options[:biogem_bin] 
          # create the 'binary' in ./bin
          mkdir_in_target bin_dir
          output_template_in_target_generic File.join('bin','bio-plugin'), File.join(bin_dir, bin_name)
          # TODO: set the file as executable
          File.chmod 0655, File.join(target_dir, bin_dir, bin_name)
        end

        # create lib/bio-plugin.rb with some default comments
        output_template_in_target_generic File.join('lib','bioruby-plugin.rb'), File.join(lib_dir, lib_filename)

        # creates the strutures and files needed to have a ready to go Rails' engine
        if namespace=options[:biogem_engine]
          engine_dirs.each do |dir|
            mkdir_in_target(dir) unless exists_dir?(dir)
          end
          output_template_in_target_generic 'engine', File.join('lib', engine_filename )
          output_template_in_target_generic_update 'library', File.join('lib', lib_filename)
          output_template_in_target_generic 'routes', File.join('config', "routes.rb" )
          output_template_in_target_generic 'foos_controller', File.join('app',"controllers", "foos_controller.rb" )
          output_template_in_target_generic 'foos_view_index', File.join('app',"views","foos", "index.html.erb" )
          output_template_in_target_generic 'foos_view_show', File.join('app',"views","foos", "show.html.erb" )
          output_template_in_target_generic 'foos_view_example', File.join('app',"views","foos", "example.html.erb" )
          output_template_in_target_generic 'foos_view_new', File.join('app',"views","foos", "new.html.erb" )
        end
      end #not_bio_gem_meta
    end

    def puts_template_message(message, length=70, padding=4)
      puts "*"*(length+padding*2+2)
      puts "*"+" "*(length+padding*2)+"*"
      message=message.join("\n") if message.kind_of? Array
      message.scan(/.{1,70}/).map do |sub_message|
        puts "*"+" "*padding+sub_message+" "*(length-sub_message.size+padding)+"*"
      end
      puts "*"+" "*(length+padding*2)+"*"
      puts "*"*(length+padding*2+2)
    end
  end #Generator
end #Jeweler
