# Various extensions to the context classes made available to templates

module R2Doc

  # Extensions for the RDoc::Generator::Context / Generators::ContextUser
  # class
  module ContextExtensions
    # Numeric value associated with visibility values for sorting
    VISIBILITY_VALUE = { :public=>0, :protected=>1, :private=>2 }
    
    # Return the parent ContextUser of this object
    def parent
      p = (@context.parent.nil? || (@context == @context.parent)) ? nil : R2Doc.all_references[parent_name]
      # guard against pollution of all_references with methods having conflicting names
      (p.respond_to?(:is_method_context?) && p.is_method_context?) ? nil : p
    end
    
    # Return an array representing the navigational path to this class in
    # the namespace hierarchy.  The first item in the array is the
    # outermost class or module.  The class itself is not included in the
    # array, nor is the root of the namespace.  So, for a class
    # A::B::C::D, the returned array will contain the A module, the B
    # module, and the C module, in that order.  All items in the array are
    # instances of ContextUser
    def name_path_to_parent
      path = []
      p = parent
      while p do
        path.unshift p
        p = p.parent
      end
      path
    end    
    
    # Return the description markup for this context
    def description(temporaryPath = nil)
      oldPath = self.path if (self.respond_to?(:path) && (!temporaryPath.nil?))
      self.format_path = temporaryPath unless temporaryPath.nil?
      d = markup(@context.comment)
      self.format_path = oldPath if (self.respond_to?(:path) && (!temporaryPath.nil?))
      d
    end
    
    # Return a list of Hashes for all constants containing the following keys:
    # [<tt>:name</tt>] The constant name
    # [<tt>:value</tt>] The value of the constant
    # [<tt>:description</tt>] Constant description markup
    def constants
      @context.constants.sort{|a,b| a.name<=>b.name}.collect{|c| {:name=>c.name, :value=>c.value, :description=>markup(c.comment, true)}}
    end
    
    # Returns true if the context contains contants
    def has_constants?
      @context.constants.length > 0
    end
    
    # Return a list of Hashes for all aliases containing the following keys:
    # [<tt>:old_name</tt>] The old name
    # [<tt>:new_name</tt>] The new name
    # [<tt>:description</tt>] Alias description markup
    def aliases
      @context.aliases.sort{|a,b| a.old_name<=>b.old_name}.collect{|al| {:old_name=>al.old_name, :new_name=>al.new_name, :description=>markup(al.comment, true)}}
    end
    
    # Return true if this context contains aliases
    def has_aliases?
      @context.aliases.length > 0
    end
    
    # Return a list of Hashes for all documentable attributes containing the following keys:
    # [<tt>:name</tt>] The attribute name
    # [<tt>:visibility</tt>] <tt>:public</tt>, <tt>:protected</tt>, or <tt>:private</tt>
    # [<tt>:rw</tt>] <tt>'r'</tt> or <tt>'rw'</tt>
    # [<tt>:description</tt>] Attribute description markup
    def attributes
      attrs = sort_members(@context.attributes).find_all{|a| @options.show_all || a.visibility == :public || a.visibility == :protected}
      attrs.collect{|a| {:name=>a.name, :visibility=>a.visibility, :rw=>a.rw, :description=>markup(a.comment, true)}}
    end
    
    # Return true if this context contains attributes
    def has_attributes?
      a = @context.attributes.find{|a| @options.show_all || a.visibility == :public || a.visibility == :protected}
      a ? true : false
    end
    
    # Returns a collection of HtmlMethod objects for all methods in this context
    def all_methods
      collect_methods unless @methods
      @all_methods = sort_members(@methods) unless @all_methods
      @all_methods
    end
    
    # Return a list of Hashes for all documentable class methods containing the following keys:
    # [<tt>:name</tt>] The method name
    # [<tt>:visibility</tt>] <tt>:public:</tt>, <tt>:protected</tt>, or <tt>:private</tt>
    # [<tt>:params</tt>] Method call signature markup (does not include method name)
    # [<tt>:callseq</tt>] Markup documenting alternative ways to call the method (should take precedence over name and params when present)
    # [<tt>:url</tt>] The relative URL to the method from the documentation root (e.g. <tt>'classes/Foo.html#bar'</tt>)
    # [<tt>:anchor</tt>] The name of the anchor for this method (e.g. <tt>'bar'</tt>)
    # [<tt>:description</tt>] Method description markup
    def class_methods
      all_methods().find_all{|m| m.singleton && (@options.show_all || m.visibility == :public || m.visibility == :protected)}.collect{|m| method_hash(m)}
    end
    
    # Returns true if the context contains class (singleton) methods
    def has_class_methods?
      m = all_methods().find{|m| m.singleton && (@options.show_all || m.visibility == :public || m.visibility == :protected)}
      m ? true : false
    end
    
    # Return a list of Hashes for all documentable instance methods.  See class_methods for Hash key information.
    def instance_methods
      all_methods().find_all{|m| (!m.singleton) && (@options.show_all || m.visibility == :public || m.visibility == :protected)}.collect{|m| method_hash(m)}
    end
    
    # Returns true if the context contains instance (non-singleton) methods
    def has_instance_methods?
      m = all_methods().find{|m| (!m.singleton) && (@options.show_all || m.visibility == :public || m.visibility == :protected)}
      m ? true : false
    end

    # The collection of modules contained within this context
    def modules
      return @modules if @modules
      @modules = @context.modules.sort.find_all{|m| m.document_self}.collect{|m| R2Doc.all_references[m.full_name]}
    end
    
    # The collection of classes contained within this context
    def classes
      return @classes if @classes
      @classes = @context.classes.sort.find_all{|c| c.document_self}.collect{|c| R2Doc.all_references[c.full_name]}
    end
    
    # Returns true if this context contains classes
    def has_classes?
      c = @context.classes.find{|c| c.document_self}
      c ? true : false
    end
    
    # Returns true if this context contains modules
    def has_modules?
      m = @context.modules.find{|m| m.document_self}
      m ? true : false
    end
    
    # Returns true if this context contains classes or modules
    def has_classes_or_modules?
      has_classes? || has_modules?
    end
    
    # Returns true if this context has included modules
    def has_includes?
      @context.includes.length > 0
    end

    # The collection of included modules.  This returns a hash with the folliwing keys for each module:
    # [<tt>:name</tt>] The module name
    # [<tt>:url</tt>] The relative URL to the module from the documentation root
    def includes
      return @includes if @includes
      @includes = []
      @context.includes.each do |i|
        ref = R2Doc.all_references[i.name]
        ref = @context.find_symbol(i.name)
        ref = ref.viewer if ref
        if ref and ref.document_self
          @includes << {:name=>i.name, :url=>ref.path}
        else
          @includes << {:name=>i.name}
        end
      end
      @includes
    end
    
    # Returns true if this object is a method context
    def is_method_context?
      false
    end

    protected
    
    # Sort members by visibility, then name
    def sort_members(members)
      members.sort do |a,b|
        avis = VISIBILITY_VALUE[a.visibility]
        bvis = VISIBILITY_VALUE[b.visibility]
        (avis == bvis) ? a.name <=> b.name : avis <=> bvis
      end
    end
    
    # Assembles a Hash for an HTMLMethod, +m+.  This is used by class_methods and instance_methods.
    def method_hash(m)
      hash = {:name=>m.name, :visibility=>m.visibility, :params=>m.params, :url=>"#{path}\##{m.aref}", :anchor=>m.aref, :description=>m.description.strip}
      hash[:callseq] = m.call_seq.gsub(/->/, '&rarr;') if m.call_seq
      hash
    end
  end


  # Extensions for the RDoc::Generator::Class / Generators::HtmlClass
  # class
  module ClassExtensions
    # Return the HtmlClass for the super class, or the class name if undocumented
    def superclass
      lookup = (parent_name) ? "#{parent_name}::#{context_superclass}" : context_superclass
      s = R2Doc.all_references[lookup] || R2Doc.all_references[context_superclass] || context_superclass
       # in some cases conflicting method names can pollute AllReferences
      s = s.name if (s.respond_to?(:is_method_context?) && s.is_method_context?)
      s == self ? nil : s
    end
    
    # Return the shorter, unqualified name of the class
    def short_name
      @context.name
    end

    protected

    # Returns nil instead of an error if superclass is called for a module
    def context_superclass
      @context.is_module? ? nil : @context.superclass
    end
    
  end
  


  # Extensions for the RDoc::Generator::Method / Generators::HtmlMethod
  # class
  module MethodExtensions
    # Returns true if this object is a method context
    def is_method_context?
      true
    end
  end

end
