Gem::Specification.new do |s|
  s.name = %q{qadmin}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Quint"]
  s.date = %q{2009-01-08}
  s.description = %q{An [almost] one command solution for adding admin interfaces/resources to a Rails app.}
  s.email = ["aaron@quirkey.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "init.rb", "lib/qadmin.rb", "lib/qadmin/controller.rb", "lib/qadmin/helper.rb", "lib/qadmin/views/edit.html.erb", "lib/qadmin/views/index.html.erb", "lib/qadmin/views/new.html.erb", "lib/qadmin/views/show.html.erb", "rails/init.rb", "rails_generators/qadmin/USAGE", "rails_generators/qadmin/qadmin_generator.rb", "rails_generators/qadmin/templates/_form.html.erb", "rails_generators/qadmin/templates/controller.rb", "rails_generators/qadmin/templates/functional_test.rb", "rails_generators/qadmin/templates/images/icon_destroy.png", "rails_generators/qadmin/templates/images/icon_down.gif", "rails_generators/qadmin/templates/images/icon_edit.png", "rails_generators/qadmin/templates/images/icon_export.png", "rails_generators/qadmin/templates/images/icon_find.png", "rails_generators/qadmin/templates/images/icon_import.png", "rails_generators/qadmin/templates/images/icon_list.png", "rails_generators/qadmin/templates/images/icon_new.png", "rails_generators/qadmin/templates/images/icon_next.gif", "rails_generators/qadmin/templates/images/icon_prev.gif", "rails_generators/qadmin/templates/images/icon_show.png", "rails_generators/qadmin/templates/images/icon_sort.png", "rails_generators/qadmin/templates/images/icon_up.gif", "rails_generators/qadmin/templates/images/indicator_medium.gif", "rails_generators/qadmin/templates/layout.html.erb", "rails_generators/qadmin/templates/shoulda_functional_test.rb", "rails_generators/qadmin/templates/style.css", "script/console", "script/destroy", "script/generate", "script/txt2html", "test/test_generator_helper.rb", "test/test_helper.rb", "test/test_qadmin_controller.rb", "test/test_qadmin_generator.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/quirkey/qadmin}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{quirkey}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{An [almost] one command solution for adding admin interfaces/resources to a Rails app.}
  s.test_files = ["test/test_generator_helper.rb", "test/test_helper.rb", "test/test_qadmin_controller.rb", "test/test_qadmin_generator.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.2.0"])
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.2.0"])
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.2.0"])
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end