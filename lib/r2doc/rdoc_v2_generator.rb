
require 'ftools'

require 'rdoc/rdoc'
require 'rdoc/generator/html'

require 'erb'

require 'r2doc/context_extensions'
require 'r2doc/template'
require 'r2doc/template_util'
require 'r2doc/generator'
require 'r2doc/erb_template_engine'

RDoc::Generator::Context.class_eval do
  include R2Doc::ContextExtensions
end

RDoc::Generator::Class.class_eval do
  include R2Doc::ClassExtensions
end

RDoc::Generator::Method.class_eval do
  include R2Doc::MethodExtensions
end


module R2Doc
  # Accessor for the AllReferences class
  def self.all_references
    RDoc::Generator::AllReferences
  end    
end

module RDoc
  
  class ClassModule
    # Retain support for old-style is_module? call
    def is_module?
      module?
    end
  end
  
  module Generator
  
    class Context #:nodoc:
      protected
      def format_path=(new_path)
        @formatter = ::RDoc::Markup::ToHtmlCrossref.new(new_path, self, @options.show_hash)
      end
    end
    
    class Method #:nodoc:
      def create_source_code_file(code_body)
      end
    end
  
    # R2Doc generator for RDoc v2
    class R2DOC < HTML
    
      RDoc.add_generator self
    
      include ERB::Util
      include R2Doc::TemplateUtil
      include R2Doc::Generator
    
      # Factory method
      def R2DOC.for(options)
        R2DOC.new(options)
      end
  
      # Constructor
      def initialize(*args)
        super
        build_static_file_list
      end
      
      # Perform version-specific initialization
      def generate_prep
        @template_cache = Cache.instance
      end
    
      # Return the name of the template
      def template_name
        @options.template || 'r2doc'
      end
    
      # Return the list of top level objects for this RDoc version
      def get_toplevels
        TopLevel
      end
    
      # Create a new file object for this RDoc version
      def create_file_context(context, options)
        File.new(@template_cache, context, options, FILE_DIR)
      end
    
      # Create a new class object for this RDoc version
      def create_class_context(context, file, options)
        Class.new(@template_cache, context, file, CLASS_DIR, options)
      end
    
      # Return a list of all defined methods
      def complete_method_list
        Method.all_methods
      end
    
    end
    
  end

end
