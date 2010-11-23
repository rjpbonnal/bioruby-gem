#Overwrite Jeweler classes for properly configure a BioRuby Development Environment/Layout.

class Jeweler
  class Generator 
    module  GithubMixin
      #class Jeweler::Generator::GithubMixin
      def homepage
        @homepage ||= "http://github.com/#{github_username}/#{github_repo_name}"
      end
      
      #class Jeweler::Generator::GithubMixin      
      def git_remote
        @git_remote ||= "git@github.com:#{github_username}/#{github_repo_name}.git"
      end
    end
    
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
      
      def data_dir
        'data'
      end
      
      alias original_create_files create_files
      # this is the defaul directory for storing library datasets
      # creates a data directory for every needs.
      def create_files
        original_create_files
        mkdir_in_target data_dir
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
      
      
  end
end

