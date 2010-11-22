class Jeweler
  class Generator 
      alias original_initialize initialize
      def initialize(options = {})
        original_initialize(options)
        development_dependencies  << ["bio", ">= 1.4.1"]
      end
            
      def lib_filename
         "bio-#{project_name}.rb"
      end
      
      def target_dir
        "bioruby-#{project_name}"
      end
      
      def require_name
        "bio-#{self.project_name}"
      end
  end
end