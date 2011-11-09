#Overdrive Jeweler's classes for properly configure a BioRuby Development Environment/Layout.

require 'bio-gem/mod/jeweler/options'
require 'bio-gem/mod/jeweler/github_mixin'

class Jeweler
  class Generator 

    alias original_initialize initialize
    def initialize(options = {})
      original_initialize(options)
      development_dependencies << ["bio", ">= 1.4.2"]
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

    def template_dir_biogem
      File.join(File.dirname(__FILE__),'..', 'templates')
    end


    def create_db_structure
      migrate_dir = File.join(db_dir, "migrate")
      mkdir_in_target(db_dir)
      mkdir_in_target(migrate_dir)
      mkdir_in_target("conf")
      output_template_in_target_generic 'database', File.join("conf", "database.yml")
      output_template_in_target_generic 'migration', File.join(migrate_dir, "001_create_example.rb" )
      output_template_in_target_generic 'seeds', File.join(db_dir, "seeds.rb")
      output_template_in_target_generic 'rakefile', 'Rakefile', template_dir_biogem, 'a' #need to spec all the option to enable the append option
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
        create_db_structure if options[:biogem_db]
        if options[:biogem_bin] 
          mkdir_in_target bin_dir
          output_template_in_target_generic 'bin', File.join(bin_dir, bin_name)
          # TODO: set the file as executable
          File.chmod 0655, File.join(target_dir, bin_dir, bin_name)
        end
        
        # Fill lib/bio-plugin.rb with some default comments
        output_template_in_target_generic 'lib', File.join(lib_dir, lib_filename)
      end #not_bio_gem_meta
    end

    def create_and_push_repo
      Net::HTTP.post_form URI.parse('http://github.com/api/v2/yaml/repos/create'),
      'login' => github_username,
      'token' => github_token,
      'description' => summary,
      'name' => github_repo_name
      # BY DEFAULT THE REPO IS CREATED
      # DO NOT PUSH THE REPO BECAUSE USER MUST ADD INFO TO CONFIGURATION FILES
      # TODO do a HEAD request to see when it's ready?
      #@repo.push('origin')
    end
  end #Generator
end #Jeweler