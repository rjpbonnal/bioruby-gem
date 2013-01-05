<% if options[:wrapper] %>require 'systemu'
<% end %>

module <%= constant_name %>
<% if options[:wrapper] %>
  class Wrapper
    def run
      command = "some_application arguments"
      status, stdout, stderr = systemu command, 0 => 'dummy stdin'
      if status.exitstatus != 0
         $stderr.puts "Failed to run wrapping command correctly, as non-zero exit status "+
           "#{status.exitstatus} detected. Command run was `#{command}'"
      else
        # All good. Now to something useful with the stdout..
      end
    end
  end
<% end %>
end
