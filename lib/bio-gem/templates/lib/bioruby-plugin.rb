# Please require your code below, respecting the naming conventions in the
# bioruby directory tree.
#
# For example, say you have a plugin named bio-plugin, the only uncommented
# line in this file would be 
#
#   require 'bio/bio-plugin/plugin'
#
# In this file only require other files. Avoid other source code.

require '<%= path(project_name,lib_plugin_filename) %>'

<% if options[:biogem_db] %>
require '<%= File.join("bio",sub_module.downcase,"connect") %>'
  <% unless options[:biogem_engine] %>
require '<%= File.join("bio",sub_module.downcase,"example") %>'
  <% end %>
<% end %>
