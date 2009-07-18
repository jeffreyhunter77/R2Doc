module R2Doc

  # Thrown when a template file cannot be found
  class TemplateMissingError < StandardError
    # name of the missing template
    attr_reader :template
    
    def initialize(template)
      super "Could not find template \"#{template}\""
      @template = template
    end
  end
  
  # The TemplateManager class handles loading and parsing of templates.
  # The actual details of reading the file and creating a parsed template
  # object is handled by a template engine class.  TemplateManager's
  # responsibilities are to record registration of template directories
  # and engines, to locate the correct template source file, and then
  # dispatch to the right engine.
  #
  # A template engine class need only supply a very limited interface.
  # It must supply a class method named +load+ which accepts a file name
  # as a single argument.  The +load+ method is expected to return an
  # instance representing that template.  The returned instance must
  # supply a +result+ method wich accepts a binding as its single
  # argument.  The +result+ method is expected to return the rendered
  # template as a string.  A single template instance may have its
  # +result+ method invoked multiple times with different bindings.
  class TemplateManager
    # The collection of template engines by extension
    @@template_engines = {}
    # The list of template directories
    @@template_directories = [File.join(File.expand_path(File.dirname(__FILE__)), 'template')]
    # Cache for loaded templates
    @@templates = {}
    
    # Register a template engine for an extension
    def self.register_engine(extension, klass)
      @@template_engines[extension.to_sym] = klass
    end
    
    # Add a template directory to search
    def self.add_template_directory(dir)
      @@template_directories.push dir
    end
    
    # Return the list of template directories
    def self.template_directories
      @@template_directories
    end
    
    # Return the list of registered extensions
    def self.registered_extensions
      @@template_engines.keys
    end
    
    # Load a template and return its instance
    def self.load_template(name)
      return @@templates[name.to_sym] if @@templates.has_key?(name.to_sym)
      
      # find the file
      filename = self.find_template_file(name) or raise TemplateMissingError.new(name)
      fileext = self.file_extension(filename)
      @@templates[name.to_sym] = @@template_engines[fileext.to_sym].load(filename)
    end
    
    # Determine the extension for a filename (not including the leading dot)
    def self.file_extension(name)
      m = /\.([^.]+)$/.match(name)
      m.nil? ? nil : m[1]
    end
    
    # Determine if a given extension is a registered extension
    def self.is_registered_extension?(ext)
      @@template_engines.has_key?(ext.nil? ? nil : ext.to_sym)
    end
    
    protected
    
    # Determine the filename for a template
    def self.find_template_file(name)
      @@template_directories.each do |d|
        @@template_engines.each_key do |ext|
          ['html', 'js'].each do |type|
            test = File.join(File.expand_path(d), "#{name.to_s}.#{type}.#{ext.to_s}")
            return test if File.exists?(test)
          end
        end
      end
      nil
    end
    
  end
  
end
