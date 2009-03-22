# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{qadmin}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Quint"]
  s.date = %q{2009-03-22}
  s.description = %q{An [almost] one command solution for adding admin interfaces/resources to a Rails app.}
  s.email = ["aaron@quirkey.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "LICENSE", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "init.rb", "lib/qadmin.rb", "lib/qadmin/assets/form_builder.rb", "lib/qadmin/configuration.rb", "lib/qadmin/controller.rb", "lib/qadmin/form_builder.rb", "lib/qadmin/helper.rb", "lib/qadmin/option_set.rb", "lib/qadmin/overlay.rb", "lib/qadmin/page_titles.rb", "lib/qadmin/templates.rb", "lib/qadmin/views/content_forms/_attachments_form.erb", "lib/qadmin/views/content_forms/_photos_form.erb", "lib/qadmin/views/content_forms/_videos_form.erb", "lib/qadmin/views/default/edit.erb", "lib/qadmin/views/default/index.erb", "lib/qadmin/views/default/new.erb", "lib/qadmin/views/default/show.erb", "rails/init.rb", "rails_generators/qadmin/USAGE", "rails_generators/qadmin/qadmin_generator.rb", "rails_generators/qadmin/templates/_form.html.erb", "rails_generators/qadmin/templates/_instance.html.erb", "rails_generators/qadmin/templates/controller.rb", "rails_generators/qadmin/templates/functional_test.rb", "rails_generators/qadmin/templates/images/icon_asc.gif", "rails_generators/qadmin/templates/images/icon_desc.gif", "rails_generators/qadmin/templates/images/icon_destroy.png", "rails_generators/qadmin/templates/images/icon_edit.png", "rails_generators/qadmin/templates/images/icon_export.png", "rails_generators/qadmin/templates/images/icon_find.png", "rails_generators/qadmin/templates/images/icon_import.png", "rails_generators/qadmin/templates/images/icon_list.png", "rails_generators/qadmin/templates/images/icon_new.png", "rails_generators/qadmin/templates/images/icon_next.gif", "rails_generators/qadmin/templates/images/icon_prev.gif", "rails_generators/qadmin/templates/images/icon_show.png", "rails_generators/qadmin/templates/images/icon_sort.png", "rails_generators/qadmin/templates/images/indicator_medium.gif", "rails_generators/qadmin/templates/layout.html.erb", "rails_generators/qadmin/templates/style.css", "test/test_generator_helper.rb", "test/test_helper.rb", "test/test_qadmin_controller.rb", "test/test_qadmin_generator.rb", "test/test_qadmin_option_set.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/quirkey/qadmin}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{quirkey}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{An [almost] one command solution for adding admin interfaces/resources to a Rails app.}
  s.test_files = ["test/test_generator_helper.rb", "test/test_helper.rb", "test/test_qadmin_controller.rb", "test/test_qadmin_generator.rb", "test/test_qadmin_option_set.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.2"])
      s.add_runtime_dependency(%q<restful_query>, [">= 0.2.0"])
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<Shoulda>, [">= 1.2.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.3.2"])
      s.add_dependency(%q<restful_query>, [">= 0.2.0"])
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<Shoulda>, [">= 1.2.0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.3.2"])
    s.add_dependency(%q<restful_query>, [">= 0.2.0"])
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<Shoulda>, [">= 1.2.0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
