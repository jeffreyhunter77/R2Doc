module R2Doc
  # R2Doc engine for ERB templates
  class ERBTemplateEngine
    # Load a template
    def self.load(filename)
      ERB.new(File.open(filename) {|f| f.read})
    end
  end
end

R2Doc::TemplateManager.register_engine('erb', R2Doc::ERBTemplateEngine)
