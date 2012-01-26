# Biogem helpers for templates

module Biogem
  module Path

    def path(*items)
      File.join(*items).gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
    end

    def exists_dir?(dir)
      Dir.exists?(path(target_dir,dir))
    end

    def short_name
      original_project_name.sub(/^bio-/,'')
    end


    def lib_dir
      'lib'
    end

    def lib_filename
      "#{project_name}.rb"
    end

    def lib_plugin_dir
      path(lib_dir, project_name)
    end

    def lib_plugin_filename
      short_name + ".rb"
    end

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

    def ext_dir
      'ext'
    end

    def bin_name
      "#{original_project_name}"
    end
  end

  module Naming
    def engine_dirs
      %w{app app/controllers app/views app/helpers config app/views/foos}
    end

    def engine_name
      "#{project_name}-engine"
    end

    def engine_filename
      "#{engine_name}.rb"
    end

    def engine_module_name
      project_name.split('-').map{|module_sub_name| module_sub_name.capitalize}.join      
    end

    def engine_name_prefix
      project_name.split('-').gsub(/-/,'_')<<'_'
    end

    def engine_namespace
      "/#{options[:biogem_engine]}"
    end
    
    def sub_module
      project_name.split('-')[1..-1].map{|x| x.capitalize}.join
    end
    
    def lib_sub_module
      path(lib_dir,"bio",sub_module.downcase)
    end
  end

  module Github
  end
end
