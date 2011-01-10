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
    end #GithubMixin
  end #Generator
end #Jeweler