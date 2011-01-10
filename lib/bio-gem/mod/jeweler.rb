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

    alias original_create_files create_files
    # this is the defaul directory for storing library datasets
    # creates a data directory for every needs.
    #the options are defined in mod/jeweler/options.rb
    def create_files
      original_create_files
      mkdir_in_target test_data_dir if options[:biogem_test_data]
      mkdir_in_target db_dir if options[:biogem_db]
      mkdir_in_target bin_dir if options[:biogem_bin]
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
  end #Generator
end #Jeweler