module R2Doc

  # Utility functions available for use in templates
  module TemplateUtil
    # Convert a target url to one that is relative to a given
    # path.  This method is updated to account for paths to files
    # in the root directory.
    def TemplateUtil.gen_url(path, target)
      from          = File.dirname(path)
      to, to_file   = File.split(target)
      
      from = from.split("/")
      to   = to.split("/")
      
      from.shift if from.first == '.'
      to.shift if to.first == '.'
      
      while from.size > 0 and to.size > 0 and from[0] == to[0]
        from.shift
        to.shift
      end
      
      from.fill("..")
      from.concat(to)
      from << to_file
      File.join(*from)
    end

    # Runs a partial template and return the contents.  This is similar
    # to, but much lighter weight than the notion of partials in Rails.
    # Example usage:
    #   render_partial :foo             # renders the partial in '_foo.html.erb'
    #   render_partial :foo, {:bar=>1}  # renders the partial and sets local variable bar to 1
    def render_partial(partial, locals = nil)
      local_assign_code = locals.nil? ? '' : locals.keys.collect{|k| "#{k} = locals[:#{k}];"}.join
      template = "#{template_name}/_#{partial.to_s}"
      proc_code = <<-end_src
        Proc.new {
          #{local_assign_code}
          R2Doc::TemplateManager.load_template('#{template}').result(binding)
        }
      end_src
      p = eval proc_code
      p.call
    end
    
    # A much simplified and altered version of the link_to method in
    # ActionView::Helpers::UrlHelper, creates a link of the given
    # +content+ to the given +url+.  If +url+ is a string it is assumed
    # to be relative to the top of the documentation directory.  If +url+
    # is a ContextUser object, its path is used.  The final URL is
    # adjusted to match the path of the current file being output.  If
    # +html_options+ are provided, they become attributes of the returned
    # tag.
    def link_to(content, url, html_options = nil)
      url = url.path if url.respond_to?(:path)
      attrs = html_options.nil? ? {} : html_options
      attrs[:href] = R2Doc::TemplateUtil.gen_url(@current_path, url)
      content_tag 'a', content, attrs
    end
    
    # Return the relative path to +url+ for the current file.  Assumes
    # that +url+  is a ContextUser or path relative to the top of the
    # documentation directory.
    def path_to(url)
      url = url.path if url.respond_to?(:path)
      R2Doc::TemplateUtil.gen_url(@current_path, url)
    end
    
    # Return an html tag with content an attributed defined by the provided hash
    def content_tag(tagname, content, html_options = {})
      attr_string = html_options.collect{|k,v| " #{h(k.to_s)}=\"#{h(v)}\""}.join('')
      "<#{tagname}#{attr_string}>#{content}</#{tagname}>"
    end
    
    # Returns an even or odd class name for striping rows using a zero-based index
    def stripe_class(index, class_prefix = '')
      "#{class_prefix}#{index % 2 == 0 ? 'odd' : 'even'}"
    end
  end
  
end
