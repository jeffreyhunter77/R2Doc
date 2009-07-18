module R2Doc
  # Custom generator
  module Generator
    # generate the docs
    def generate(toplevels)
      @toplevels  = toplevels
      @files      = []
      @classes    = []
      @hyperlinks = {}
      @topmodules = []
      @topclasses = []
      
      generate_prep # hook for version-specific initalization
    
      build_indices
      generate_html
      copy_static_files
    end
  
    protected

    # load the template files
    def load_html_template
      ['class', 'file', 'rdoc'].each do |name|
        R2Doc::TemplateManager.load_template("#{template_name}/#{name}")
      end
    end
    
    # build indices of our objects
    def build_indices
      @toplevels.each do |toplevel|
        @files << create_file_context(toplevel, @options)
      end

      get_toplevels.all_classes_and_modules.each do |cls|
        build_class_list(cls, @files[0])
      end
      
      @classes.each do |c|
        if c.parent.nil?
          if c.context.is_module?
            @topmodules << c
          else
            @topclasses << c
          end
        end
      end
      @topmodules.sort!
      @topclasses.sort!
    end

    # Build a class list from a top-level class
    def build_class_list(from, html_file)
      @classes << create_class_context(from, html_file, @options)
      from.each_classmodule do |mod|
        build_class_list(mod, html_file)
      end
    end
    
    # Outputs the html
    def generate_html
      @classes.each {|klass| render klass.path, :class, binding }
      @files.each   {|file| render file.path, :file, binding }
      render 'rdoc.js', :rdoc
      generate_index
    end
    
    # Generate an index file
    def generate_index
      # determine what to put in the index
      ref = (@options.main_page && R2Doc.all_references[@options.main_page]) ?
        R2Doc.all_references[@options.main_page] : nil
      ref = ref.nil? ? @files.find{|f| f.document_self} : ref
      
      # create the index
      file = ref
      render 'index.html', :index, binding
    end
    
    # Run a template and output the contents
    def render(filename, template, b = nil)
      @current_path = filename
      File.makedirs(File.dirname(filename))
      t = R2Doc::TemplateManager.load_template("#{template_name}/#{template.to_s}")
      b = b.nil? ? binding : b
      
      File.open(filename, 'w') {|f| f.write t.result(b)}
    end
    
    
    # build the static file list
    def build_static_file_list
      @static_files = {}
      R2Doc::TemplateManager.template_directories.collect {|d|
        "#{File.expand_path(d)}/#{template_name}"}.find_all{|d|
          File.directory?(d)
       }.each{|d| add_to_static_file_list d}
    end
    
    # recursively add a directory's contents to the static file list
    def add_to_static_file_list(dir, relpath = '')
      Dir.entries(File.join(dir, relpath)).each do |entry|
        unless entry.match(/^\..?$/) || R2Doc::TemplateManager.is_registered_extension?(R2Doc::TemplateManager.file_extension(entry))
          partial = relpath.empty? ? entry : File.join(relpath, entry)
          full = File.join(dir, partial)
          if File.directory?(full)
            add_to_static_file_list dir, partial
          else
            @static_files[full] = partial
          end
        end
      end
    end
    
    # copy any static files needed by the template
    def copy_static_files
      @static_files.each{|full,partial|
        File.makedirs(File.dirname(partial))
        File.copy(full, partial)
      }
    end
  end
end
