# Please require your code below, respecting the naming conventions in the
# bioruby directory tree.
#
# For example, say you have a plugin named bio-sequence, the only uncommented
# line in this file would be 
#
#   require 'bio/sequence/my_awesome_sequence_plugin_thingy'
#
# next create the ruby file 'lib/bio/sequence/my_awesome_sequence_thingy.rb'
# and put your plugin's code there, using appropriate name spacing. We suggest
#
#   module Bio
#     module MyAwesomeSequenceThingy
#       (...)
#     end
#   end
#
# In this file only require other files. Avoid other source code.

<% if options[:biogem_db] %>
require '<%= File.join("bio",sub_module.downcase,"connect") %>'
  <% unless options[:biogem_engine] %>
require '<%= File.join("bio",sub_module.downcase,"example") %>'
  <% end %>
<% end %>
