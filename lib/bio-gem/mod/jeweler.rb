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
      # RCov is not properly supported in Ruby 1.9.2, so we remove it
      development_dependencies.delete_if { |k,v| k == "rcov" }
      # Jeweler has a bug for bundler
      development_dependencies.delete_if { |k,v| k == "bundler" }
      development_dependencies.delete_if { |k,v| k == "jeweler" }
      development_dependencies << ["jeweler",'~> 1.8.4", :git => "https://github.com/technicalpickles/jeweler.git']
      development_dependencies << ["bundler", ">= 1.0.21"]
      # development_dependencies << ["bio-logger"]
      development_dependencies << ["bio", ">= 1.4.2"]
      # we add rdoc because of an upgrade of rake RDocTask causing errors
      development_dependencies << ["rdoc","~> 3.12"]
      if options[:biogem_db]
        development_dependencies << ["activerecord", ">= 3.0.7"]
        development_dependencies << ["activesupport", ">= 3.0.7"]
        development_dependencies << ["sqlite3", ">= 1.3.3"]
      end
      development_dependencies << ['systemu', '>=2.5.2'] if options[:wrapper]
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
    alias github_repo_name target_dir

    alias original_create_files create_files
    # this is the default directory for storing library datasets
    # creates a data directory for every needs.
    #the options are defined in mod/jeweler/options.rb
    def create_files
      create_plugin_files
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

    def create_and_push_repo
      puts "Please provide your Github password to create the Github repository"
      begin
        login = github_username
        password = ask("Password: ") { |q| q.echo = false }
        github = Github.new(:login => login.strip, :password => password.strip)
        github.repos.create(:name => project_name, :description => summary)
      rescue Github::Error::Unauthorized
        puts "Wrong login/password! Please try again"
        retry
      rescue Github::Error::UnprocessableEntity
        raise GitRepoCreationFailed, "Can't create that repo. Does it already exist?"
      end
      # TODO do a HEAD request to see when it's ready?
      @repo.push('origin')
    end
  end #Generator
end #Jeweler
