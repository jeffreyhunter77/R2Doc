# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{R2Doc}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeffrey Hunter and Mission Critical Labs, Inc."]
  s.date = %q{2009-07-17}
  s.default_executable = %q{r2doc}
  s.description = %q{R2Doc is an improved generator for RDoc. It provides an improved output template for documentation (including search and frameless navigation), but also aims to be more extensible so that template authoring is an easier task with a wider set of options.}
  s.email = %q{r2doc@missioncriticallabs.com}
  s.executables = ["r2doc"]
  s.extra_rdoc_files = ["bin/r2doc", "CHANGELOG", "lib/r2doc/context_extensions.rb", "lib/r2doc/erb_template_engine.rb", "lib/r2doc/generator.rb", "lib/r2doc/rdoc_v2_generator.rb", "lib/r2doc/template/r2doc/_aliases.html.erb", "lib/r2doc/template/r2doc/_attributes.html.erb", "lib/r2doc/template/r2doc/_classes_and_modules.html.erb", "lib/r2doc/template/r2doc/_constants.html.erb", "lib/r2doc/template/r2doc/_method_detail.html.erb", "lib/r2doc/template/r2doc/_method_details.html.erb", "lib/r2doc/template/r2doc/_method_listing.html.erb", "lib/r2doc/template/r2doc/_method_listing_row.html.erb", "lib/r2doc/template/r2doc/_nav.html.erb", "lib/r2doc/template/r2doc/_nav_item.html.erb", "lib/r2doc/template/r2doc/class.html.erb", "lib/r2doc/template/r2doc/file.html.erb", "lib/r2doc/template/r2doc/images/blue-arrow-right.png", "lib/r2doc/template/r2doc/images/blue-arrow-up.png", "lib/r2doc/template/r2doc/images/blue-box.png", "lib/r2doc/template/r2doc/images/blue-plus.png", "lib/r2doc/template/r2doc/images/close-button.png", "lib/r2doc/template/r2doc/images/green-arrow-right.png", "lib/r2doc/template/r2doc/images/green-arrow-up.png", "lib/r2doc/template/r2doc/images/nav-back.png", "lib/r2doc/template/r2doc/images/nav-bottom.png", "lib/r2doc/template/r2doc/images/nav-top.png", "lib/r2doc/template/r2doc/images/orange-hash.png", "lib/r2doc/template/r2doc/images/red-dash.png", "lib/r2doc/template/r2doc/images/search-back.png", "lib/r2doc/template/r2doc/images/top-back.png", "lib/r2doc/template/r2doc/images/top-left.png", "lib/r2doc/template/r2doc/images/top-right.png", "lib/r2doc/template/r2doc/index.html.erb", "lib/r2doc/template/r2doc/jquery.js", "lib/r2doc/template/r2doc/prototype.js", "lib/r2doc/template/r2doc/r2doc.css", "lib/r2doc/template/r2doc/rdoc-utils.js", "lib/r2doc/template/r2doc/rdoc.js.erb", "lib/r2doc/template.rb", "lib/r2doc/template_util.rb", "lib/r2doc.rb", "lib/rdoc/discover.rb", "lib/rdoc/generators/r2doc_generator.rb", "LICENSE", "README", "README.rdoc"]
  s.files = ["bin/r2doc", "CHANGELOG", "lib/r2doc/context_extensions.rb", "lib/r2doc/erb_template_engine.rb", "lib/r2doc/generator.rb", "lib/r2doc/rdoc_v2_generator.rb", "lib/r2doc/template/r2doc/_aliases.html.erb", "lib/r2doc/template/r2doc/_attributes.html.erb", "lib/r2doc/template/r2doc/_classes_and_modules.html.erb", "lib/r2doc/template/r2doc/_constants.html.erb", "lib/r2doc/template/r2doc/_method_detail.html.erb", "lib/r2doc/template/r2doc/_method_details.html.erb", "lib/r2doc/template/r2doc/_method_listing.html.erb", "lib/r2doc/template/r2doc/_method_listing_row.html.erb", "lib/r2doc/template/r2doc/_nav.html.erb", "lib/r2doc/template/r2doc/_nav_item.html.erb", "lib/r2doc/template/r2doc/class.html.erb", "lib/r2doc/template/r2doc/file.html.erb", "lib/r2doc/template/r2doc/images/blue-arrow-right.png", "lib/r2doc/template/r2doc/images/blue-arrow-up.png", "lib/r2doc/template/r2doc/images/blue-box.png", "lib/r2doc/template/r2doc/images/blue-plus.png", "lib/r2doc/template/r2doc/images/close-button.png", "lib/r2doc/template/r2doc/images/green-arrow-right.png", "lib/r2doc/template/r2doc/images/green-arrow-up.png", "lib/r2doc/template/r2doc/images/nav-back.png", "lib/r2doc/template/r2doc/images/nav-bottom.png", "lib/r2doc/template/r2doc/images/nav-top.png", "lib/r2doc/template/r2doc/images/orange-hash.png", "lib/r2doc/template/r2doc/images/red-dash.png", "lib/r2doc/template/r2doc/images/search-back.png", "lib/r2doc/template/r2doc/images/top-back.png", "lib/r2doc/template/r2doc/images/top-left.png", "lib/r2doc/template/r2doc/images/top-right.png", "lib/r2doc/template/r2doc/index.html.erb", "lib/r2doc/template/r2doc/jquery.js", "lib/r2doc/template/r2doc/prototype.js", "lib/r2doc/template/r2doc/r2doc.css", "lib/r2doc/template/r2doc/rdoc-utils.js", "lib/r2doc/template/r2doc/rdoc.js.erb", "lib/r2doc/template.rb", "lib/r2doc/template_util.rb", "lib/r2doc.rb", "lib/rdoc/discover.rb", "lib/rdoc/generators/r2doc_generator.rb", "LICENSE", "Manifest", "Rakefile", "README", "README.rdoc", "R2Doc.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://r2doc.org}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "R2Doc", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{r2doc}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{An extensible RDoc generator using ERB}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
