
require 'ftools'

require 'rdoc/options'
require 'rdoc/markup/simple_markup'
require 'rdoc/markup/simple_markup/to_html'
require 'rdoc/generators/html_generator'

require 'erb'

require 'r2doc/context_extensions'
require 'r2doc/template'
require 'r2doc/template_util'
require 'r2doc/generator'
require 'r2doc/erb_template_engine'

Generators::ContextUser.class_eval do
  include R2Doc::ContextExtensions
end

Generators::HtmlClass.class_eval do
  include R2Doc::ClassExtensions
end

Generators::HtmlMethod.class_eval do
  include R2Doc::MethodExtensions
end

module R2Doc
  # Accessor for the AllReferences class
  def self.all_references
    Generators::AllReferences
  end    
end

module Generators
  
  class ContextUser #:nodoc:
    protected
    def format_path=(new_path)
      @html_formatter = HyperlinkHtml.new(new_path, self)
    end
  end
    
  class HtmlMethod #:nodoc:
    def create_source_code_file(code_body)
    end
  end
  
  class HTMLGenerator #:nodoc:
    def HTMLGenerator.gen_url(path, target)
      R2Doc::TemplateUtil.gen_url(path, target)
    end
  end
  
  # R2Doc generator for RDoc v1.0.1
  class R2DOCGenerator < HTMLGenerator
    
    include ERB::Util
    include R2Doc::TemplateUtil
    include R2Doc::Generator
    
    # Factory method
    def R2DOCGenerator.for(options)
      R2DOCGenerator.new(options)
    end
  
    # Constructor
    def initialize(*args)
      super
      build_static_file_list
    end
    
    # Perform version-specific initialization
    def generate_prep
    end
    
    # Return the name of the template
    def template_name
      @options.template || 'r2doc'
    end
    
    # Return the list of top level objects for this RDoc version
    def get_toplevels
      RDoc::TopLevel
    end
    
    # Create a new file object for this RDoc version
    def create_file_context(context, options)
      HtmlFile.new(context, options, FILE_DIR)
    end
    
    # Create a new class object for this RDoc version
    def create_class_context(context, file, options)
      HtmlClass.new(context, file, CLASS_DIR, options)
    end
    
    # Return a list of all defined methods
    def complete_method_list
      HtmlMethod.all_methods
    end
    
  end

end
