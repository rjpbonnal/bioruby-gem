#Overdrive Jeweler's classes for properly configure a BioRuby Development Environment/Layout.

require 'bio-gem/mod/jeweler/options'
require 'bio-gem/mod/jeweler/github_mixin'

class Jeweler
  class Generator 

    alias original_initialize initialize
    def initialize(options = {})
      original_initialize(options)
      development_dependencies  << ["bio", ">= 1.4.1"]
    end

    alias original_project_name project_name  
    def project_name
      "bio-#{original_project_name}"
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

    def bin_name
      "bio#{original_project_name}"
    end
    
    def engine_dirs
      %w{app app/controllers app/views app/helpers config}
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
    
    def render_template_generic(source, template_dir = template_dir_biogem)
      template_contents = File.read(File.join(template_dir, source))
      template          = ERB.new(template_contents, nil, '<>')

      # squish extraneous whitespace from some of the conditionals
      template.result(binding).gsub(/\n\n\n+/, "\n\n")
    end

    def output_template_in_target_generic(source, destination = source, template_dir = template_dir_biogem)
      final_destination = File.join(target_dir, destination)
      template_result   = render_template_generic(source, template_dir)

      File.open(final_destination, 'w') {|file| file.write(template_result)}

      $stdout.puts "\tcreate\t#{destination}"
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

    alias original_create_files create_files
    # this is the default directory for storing library datasets
    # creates a data directory for every needs.
    #the options are defined in mod/jeweler/options.rb
    def create_files
      original_create_files
      
      if options[:biogem_test_data]
        mkdir_in_target("test") unless File.exists? "#{target_dir}/test"
        mkdir_in_target test_data_dir  
      end
      mkdir_in_target(db_dir) if options[:biogem_db]
      if options[:biogem_bin] 
        mkdir_in_target bin_dir
        # rendering my bin template
        output_template_in_target_generic 'bin', File.join(bin_dir, bin_name)
        # TODO: set the file as executable
        File.chmod 0655, File.join(target_dir, bin_dir, bin_name)
      end
      
      # Fill lib/bio-plugin.rb with some default comments
      output_template_in_target_generic 'lib', File.join(lib_dir, lib_filename)

      #creates the strutures and files needed to have a ready to go Rails' engine
      if namespace=options[:biogem_engine]
        engine_dirs.each do |dir|
          mkdir_in_target dir
        end
        output_template_in_target_generic 'engine', File.join('lib', engine_filename )
        output_template_in_target_generic_update 'library', File.join('lib', lib_filename)
        output_template_in_target_generic 'routes', File.join('config', "routes.rb" )
        # TODO: scrivere il caricamento dell'engine nel caso sia in ambiente rails, nel file della libreria principale.
        # example....
        # if (defined?(Rails) && Rails::VERSION::MAJOR == 3)
        #   require 'bio-kb-gex_data-engine'
        # else
        # end
        
        #aprire il lib_filename e appenderci il codice sopra, chiamare un erb    
      end
    end

    def create_and_push_repo
      Net::HTTP.post_form URI.parse('http://github.com/api/v2/yaml/repos/create'),
      'login' => github_username,
      'token' => github_token,
      'description' => summary,
      'name' => github_repo_name
      # TODO do a HEAD request to see when it's ready?
      @repo.push('origin')
    end
    
    
    def puts_template_message(message, length=70, padding=4)
      puts "*"*(length+padding*2+2)
      puts "*"+" "*(length+padding*2)+"*"
      message.scan(/.{1,70}/).map do |sub_message|
        puts "*"+" "*padding+sub_message+" "*(length-sub_message.size+padding)+"*"
      end
      puts "*"+" "*(length+padding*2)+"*"
      puts "*"*(length+padding*2+2)
    end
  end #Generator
end #Jeweler