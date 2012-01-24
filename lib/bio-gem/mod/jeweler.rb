#Overdrive Jeweler's classes for properly configure a BioRuby Development Environment/Layout.

require 'bio-gem/mod/jeweler/options'
require 'bio-gem/mod/jeweler/github_mixin'

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end

class Jeweler
  class Generator 

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
      prj_name = original_project_name=~/^bio-/ ? original_project_name : "bio-#{original_project_name}" 
      prj_name
    end

    alias original_render_template render_template
    def render_template(source)
      buf = original_render_template(source)
      # call hook (returns edited buf)
      after_render_template(source,buf)
    end

    # new hook for removing stuff
    def after_render_template(source,buf)
      if source == 'other_tasks.erb'
        $stdout.puts "\tRemoving rcov lines"
        # remove rcov related lines from jeweler Rakefile
        remove = "require 'rcov/rcovtask'"
        if buf =~ /#{remove}/
          # $stdout.puts buf,'---'
          buf1 = buf.split(/\n/)
          i = buf1.index(remove)
          buf = (buf1[0..i-1] + buf1[i+7..-1]).join("\n")
        end
      end
      buf
    end

    def lib_dir
      'lib'
    end

    def lib_filename
      "#{project_name}.rb"
    end

    def target_dir
      project_name.gsub('bio','bioruby')
    end      
    alias github_repo_name target_dir

    def require_name
      project_name
    end

    def test_data_dir
      'test/data'
    end

    def db_dir
      'db'
    end

    def bin_dir
      'bin'
    end

    def ext_dir
      'ext'
    end

    def bin_name
      "bio#{original_project_name}"
    end

    def engine_dirs
      %w{app app/controllers app/views app/helpers config app/views/foos}
    end

    def engine_name
      "#{project_name}-engine"
    end

    def engine_filename
      "#{engine_name}.rb"
    end

    def engine_module_name
      project_name.split('-').map{|module_sub_name| module_sub_name.capitalize}.join      
    end

    def engine_name_prefix
      project_name.split('-').gsub(/-/,'_')<<'_'
    end

    def engine_namespace
      "/#{options[:biogem_engine]}"
    end
    
    def sub_module
      project_name.split('-')[1..-1].map{|x| x.capitalize}.join
    end
    
    def lib_sub_module
      File.join(lib_dir,"bio",sub_module.downcase)
    end
    
    def exists_dir?(dir)
      Dir.exists?(File.join(target_dir,dir))
    end

    def render_template_generic(source, template_dir = template_dir_biogem)
      template_contents = File.read(File.join(template_dir, source))
      template          = ERB.new(template_contents, nil, '<>')

      # squish extraneous whitespace from some of the conditionals
      template.result(binding).gsub(/\n\n\n+/, "\n\n")
    end

    def output_template_in_target_generic(source, destination = source, template_dir = template_dir_biogem, write_type='w')
      final_destination = File.join(target_dir, destination)
      template_result   = render_template_generic(source, template_dir)

      File.open(final_destination, write_type) {|file| file.write(template_result)}
      status = case write_type
      when 'w' then 'create'
      when 'a' then 'update'
      end
      $stdout.puts "\t#{status}\t#{destination}"
    end

    def output_template_in_target_generic_update(source, destination = source, template_dir = template_dir_biogem)
      final_destination = File.join(target_dir, destination)
      template_result   = render_template_generic(source, template_dir)

      File.open(final_destination, 'a') {|file| file.write(template_result)}

      $stdout.puts "\tcreate\t#{destination}"
    end    

    def template_dir_biogem
      File.join(File.dirname(__FILE__),'..', 'templates')
    end

    def create_ffi_structure
      # create ./ext/src and ./ext/include for the .c and .h files
      mkdir_in_target(ext_dir)
      src_dir = File.join(ext_dir,'src')
      mkdir_in_target(src_dir)
      # create ./lib/ffi for the Ruby ffi
      mkdir_in_target(File.join(lib_dir,"ffi"))
      # copy C files
      output_template_in_target_generic File.join('ffi','ext.c'), File.join(src_dir, "ext.c" )
      output_template_in_target_generic File.join('ffi','ext.h'), File.join(src_dir, "ext.h" )
    end

    def create_db_structure
      migrate_dir = File.join(db_dir, "migrate")
      mkdir_in_target(db_dir)
      mkdir_in_target(migrate_dir)
      mkdir_in_target("config") unless exists_dir?("config")
      mkdir_in_target("lib/bio")
      mkdir_in_target(lib_sub_module)
      output_template_in_target_generic 'database', File.join("config", "database.yml")
      output_template_in_target_generic 'migration', File.join(migrate_dir, "001_create_example.rb" )
      output_template_in_target_generic 'seeds', File.join(db_dir, "seeds.rb")
      output_template_in_target_generic 'rakefile', 'Rakefile', template_dir_biogem, 'a' #need to spec all the option to enable the append option
      #TODO I'd like to have a parameter from command like with defines the Namespace of the created bio-gem to automatically costruct directory structure
      output_template_in_target_generic 'db_connection', File.join(lib_sub_module,"connect.rb")
      output_template_in_target_generic 'db_model', File.join(lib_sub_module,"example.rb")
    end

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
          mkdir_in_target bin_dir
          output_template_in_target_generic 'bin', File.join(bin_dir, bin_name)
          # TODO: set the file as executable
          File.chmod 0655, File.join(target_dir, bin_dir, bin_name)
        end

        # create lib/bio-plugin.rb with some default comments
        output_template_in_target_generic 'lib/bioruby-plugin.rb', File.join(lib_dir, lib_filename)

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

    def create_and_push_repo
      begin 
        Net::HTTP.post_form URI.parse('http://github.com/api/v2/yaml/repos/create'),
        'login' => github_username,
        'token' => github_token,
        'description' => summary,
        'name' => github_repo_name
        # BY DEFAULT THE REPO IS CREATED
        # DO NOT PUSH THE REPO BECAUSE USER MUST ADD INFO TO CONFIGURATION FILES
        # TODO do a HEAD request to see when it's ready?
        #@repo.push('origin')
      rescue  SocketError => se
        puts_template_message("Seems you are not connected to Internet, can't create a remote repository. Do not forget to create it by hand, from GitHub, and sync it with this project.")
      end
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
