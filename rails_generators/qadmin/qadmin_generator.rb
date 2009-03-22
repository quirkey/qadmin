class QadminGenerator < Rails::Generator::NamedBase
  attr_reader   :controller_name,
  :controller_class_path,
  :controller_file_path,
  :controller_class_nesting,
  :controller_class_nesting_depth,
  :controller_class_name,
  :controller_singular_name,
  :controller_plural_name
  alias_method  :controller_file_name,  :controller_singular_name
  alias_method  :controller_table_name, :controller_plural_name

  attr_accessor :after_scaffold

  def initialize(runtime_args, runtime_options = {})
    super

    @controller_name = @args.shift || @name.pluralize

    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_singular_name, @controller_plural_name = inflect_names(base_name)

    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
    extract_options
  end

  def manifest
    record do |m|
      klass # checks for class definition
      # Check for class naming collisions.
      m.class_collisions(controller_class_path, "#{controller_class_name}Controller")

      # Controller, helper, views, and test directories.
      if !after_scaffold
        m.directory(File.join('app','controllers', controller_class_path))
        m.directory(File.join('app', 'helpers', controller_class_path))
        m.directory(File.join('public','images','admin'))
      end

      m.directory(File.join('app', 'views', controller_class_path, controller_file_name))
      m.directory(File.join('test', 'functional', controller_class_path))

      #copy form over too
      m.template("_form.html.erb",File.join('app','views', controller_class_path, controller_file_name, "_form.html.erb"))
      m.template("_instance.html.erb", File.join('app','views', controller_class_path, controller_file_name, "_#{file_name}.html.erb"))

      if !after_scaffold
        # Layout and stylesheet.
        m.template('layout.html.erb', File.join('app','views','layouts', "admin.html.erb"))
        m.template('style.css', 'public/stylesheets/admin.css')

        m.template('controller.rb', File.join('app','controllers', controller_class_path, "#{controller_file_name}_controller.rb"))
      end
      
      m.template('functional_test.rb', File.join('test','functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))

      if !after_scaffold
        m.route_resources controller_file_name

        # Copy Icons
        Dir[File.join(File.dirname(__FILE__),'templates','images/*')].each do |image|
          m.file File.join('images',File.basename(image)), File.join('public','images','admin',File.basename(image))
        end
      end
      
    end
  end

  protected
  # Override with your own usage banner.
  def banner
    "Usage: #{$0} qadmin ModelName"
  end

  def scaffold_views
    %w[ index show new edit ]
  end

  def model_name
    class_name.demodulize
  end

  def klass
    begin
      require "#{file_name}" unless defined?(model_name.constantize)
    rescue
      raise "You must define the class #{model_name} before running qscaffold"
    end
    model_name.constantize
  end

  def attributes
    klass.content_columns
  end

  def ignore_attributes
    %w{created_at updated_at}.push klass.protected_attributes
  end

  def add_options!(opts)
    opts.on('--after-scaffold', "For use after generating a scaffold, generates the _form and the functional test") {|o| options[:after_scaffold] = o }
  end

  def extract_options
    self.after_scaffold = options[:after_scaffold]
  end
end