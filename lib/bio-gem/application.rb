
module Bio
  class Gem
    class Generator
      class Application
        class << self
          # Return an hash with :exit=>(0|1) and optionally and :options which is another hash
          # This function has been stolen from Jeweler and mdified with the return hash, the original class returns just 0|1
          # the problem is that I need to identify the name of the project_name from outside to use bundler.
          def run!(*arguments)
            env_opts = if ENV['JEWELER_OPTS']
              Jeweler::Generator::Options.new(ENV['JEWELER_OPTS'].split(' '))
            end
            options = Jeweler::Generator::Options.new(arguments)
            options = options.merge(env_opts) if env_opts

            if options[:invalid_argument]
              $stderr.puts options[:invalid_argument]
              options[:show_help] = true
            end

            if options[:show_help]
              $stderr.puts options.opts
              return {:exit=>1}
            end

            if options[:project_name].nil? || options[:project_name].squeeze.strip == ""
              $stderr.puts options.opts
              return {:exit=>1}
            end

            begin
              generator = Jeweler::Generator.new(options)
              generator.run
              return {:exit=>0, :options=>options}
            rescue Jeweler::NoGitUserName
              $stderr.puts %Q{No user.name found in ~/.gitconfig. Please tell git about yourself (see http://help.github.com/git-email-settings/ for details). For example: git config --global user.name "mad voo"}
              return {:exit=>1}
            rescue Jeweler::NoGitUserEmail
              $stderr.puts %Q{No user.email found in ~/.gitconfig. Please tell git about yourself (see http://help.github.com/git-email-settings/ for details). For example: git config --global user.email mad.vooo@gmail.com}
              return {:exit=>1}
            rescue Jeweler::NoGitHubUser
              $stderr.puts %Q{No github.user found in ~/.gitconfig. Please tell git about your GitHub account (see http://github.com/blog/180-local-github-config for details). For example: git config --global github.user defunkt}
              return {:exit=>1}
            rescue Jeweler::NoGitHubToken
              $stderr.puts %Q{No github.token found in ~/.gitconfig. Please tell git about your GitHub account (see http://github.com/blog/180-local-github-config for details). For example: git config --global github.token 6ef8395fecf207165f1a82178ae1b984}
              return {:exit=>1}
            rescue Jeweler::FileInTheWay
              $stderr.puts "The directory #{options[:project_name]} already exists. Maybe move it out of the way before continuing?"
              return {:exit=>1}
            end
          end #run!
        end #self
      end #Application
    end #Generator
  end #Gem
end #Bio
