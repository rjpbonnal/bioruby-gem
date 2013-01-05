class Jeweler
  class Generator
    class Options < Hash
      attr_reader :opts, :orig_args

      def initialize(args)
        super()

        @orig_args = args.clone
        self[:testing_framework]       = :shoulda
        self[:documentation_framework] = :rdoc
        self[:use_bundler]             = true
        self[:create_repo]             = self[:create_repo] || true

        git_config =  if Pathname.new("~/.gitconfig").expand_path.exist?
          Git.global_config
        else
          {}
        end
        self[:user_name]       = ENV['GIT_AUTHOR_NAME']  || ENV['GIT_COMMITTER_NAME']  || git_config['user.name']
        self[:user_email]      = ENV['GIT_AUTHOR_EMAIL'] || ENV['GIT_COMMITTER_EMAIL'] || git_config['user.email']
        self[:github_username] = git_config['github.user']
        self[:github_token]    = git_config['github.token']

        require 'optparse'
        @opts = OptionParser.new do |o|
          o.banner = "Usage: #{File.basename($0)} [options] reponame\ne.g. #{File.basename($0)} the-perfect-gem"

          o.on('--directory [DIRECTORY]', 'specify the directory to generate into') do |directory|
            self[:directory] = directory
          end
          
          o.separator ""
          
          o.separator "These options are for BioGem"
          
          #TODO: Scrivere le altre opzioni
          
          #Note this option has the priority over all the other options.
          o.on("--meta", 'create a meta package, just the Rakefile, Gemfile, Licence, Readme. This options takes the precedence over every other option.') do
            self[:biogem_meta] = true
          end
          
          o.on("--with-bin", 'create the bin directory and an executable template script called bioreponame') do
            self[:biogem_bin] = true
          end

          o.on('--with-ffi', 'generate a C extension with foreign function interface (FFI)') do
            self[:biogem_ffi] = true
          end

          o.on('--with-db', 'create the database directory for a db application-library.') do
            self[:biogem_db] = true
          end

          o.on('--with-test-data','create the data directory inside the test directory if the user need to set up a test with its own dataset') do
            self[:biogem_test_data] = true
          end
          
          o.on('--with-engine [NAMESPACE]', 'create a Rails engine with the namespace given in input. Set default database creation') do |namespace|
            self[:biogem_engine] = namespace
            self[:biogem_db] = true
          end
          
          o.on('--with-wrapper', 'setup the biogem to be a wrapper around a command line application') do
            self[:wrapper] = true
          end
          
          o.separator ""
          
          o.separator "These options are for Jeweler"

          o.on('--rspec', 'generate rspec code examples') do
            self[:testing_framework] = :rspec
          end

          o.on('--shoulda', 'generate shoulda tests') do
            self[:testing_framework] = :shoulda
          end

          o.on('--testunit', 'generate test/unit tests') do
            self[:testing_framework] = :testunit
          end

          o.on('--bacon', 'generate bacon specifications') do
            self[:testing_framework] = :bacon
          end

          o.on('--testspec', 'generate test/spec tests') do
            self[:testing_framework] = :testspec
          end

          o.on('--minitest', 'generate minitest tests') do
            self[:testing_framework] = :minitest
          end

          o.on('--micronaut', 'generate micronaut examples') do
            self[:testing_framework] = :micronaut
          end

          o.on('--riot', 'generate riot tests') do
            self[:testing_framework] = :riot
          end

          o.on('--shindo', 'generate shindo tests') do
            self[:testing_framework] = :shindo
          end

          o.separator ""

          o.on('--[no-]bundler', 'use bundler for managing dependencies') do |v|
            self[:use_bundler] = v
          end

          o.on('--cucumber', 'generate cucumber stories in addition to the other tests') do
            self[:use_cucumber] = true
          end

          o.separator ""

          o.on('--reek', 'generate rake task for reek') do
            self[:use_reek] = true
          end

          o.on('--roodi', 'generate rake task for roodi') do
            self[:use_roodi] = true
          end

          o.separator ""

          o.on('--summary [SUMMARY]', 'specify the summary of the project') do |summary|
            self[:summary] = summary
          end

          o.on('--description [DESCRIPTION]', 'specify a description of the project') do |description|
            self[:description] = description
          end

          o.separator ""

          o.on('--user-name [USER_NAME]', "the user's name, ie that is credited in the LICENSE") do |user_name|
            self[:user_name] = user_name
          end

          o.on('--user-email [USER_EMAIL]', "the user's email, ie that is credited in the Gem specification") do |user_email|
            self[:user_email] = user_email
          end

          o.separator ""

          o.on('--github-username [GITHUB_USERNAME]', "name of the user on GitHub to set the project up under") do |github_username|
            self[:github_username] = github_username
          end

          o.on('--github-token [GITHUB_TOKEN]', "GitHub token to use for interacting with the GitHub API") do |github_token|
            self[:github_token] = github_token
          end

          o.on('--git-remote [GIT_REMOTE]', 'URI to set the git origin remote to') do |git_remote|
            self[:git_remote] = git_remote
          end

          o.on('--homepage [HOMEPAGE]', "the homepage for your project (defaults to the GitHub repo)") do |homepage|
            self[:homepage] = homepage
          end

          o.on('--no-create-repo', 'don\'t create the repository on GitHub') do
            self[:create_repo] = false
          end


          o.separator ""

          o.on('--yard', 'use yard for documentation') do
            self[:documentation_framework] = :yard
          end

          o.on('--rdoc', 'use rdoc for documentation') do
            self[:documentation_framework] = :rdoc
          end

          o.on_tail('-h', '--help', 'display this help and exit') do
            self[:show_help] = true
          end
        end

        begin
          @opts.parse!(args)
          self[:project_name] = args.shift
        rescue OptionParser::InvalidOption => e
          self[:invalid_argument] = e.message
        end
      end

      def merge(other)
        self.class.new(@orig_args + other.orig_args)
      end

    end #Options
  end #Generator
end #Jeweler
