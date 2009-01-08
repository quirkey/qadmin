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
  end

  def manifest
    record do |m|
      klass # checks for class definition
      # Check for class naming collisions.
      m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")

      # Controller, helper, views, and test directories.
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory(File.join('app/helpers', controller_class_path))
      m.directory(File.join('app/views', controller_class_path, controller_file_name))
      m.directory(File.join('app/views','shared'))
      m.directory(File.join('test/functional', controller_class_path))
      m.directory(File.join('public','images','admin'))

      for action in scaffold_views
        m.template(
        "view_#{action}.rhtml",
        File.join('app/views', controller_class_path, controller_file_name, "#{action}.html.erb")
        )
      end
      #copy form over too
      m.template("view_form.rhtml",File.join('app/views', controller_class_path, controller_file_name, "_form.html.erb"))

      # Layout and stylesheet.
      m.template('layout.rhtml', File.join('app/views/layouts', "admin.html.erb"))
      m.template('style.css', 'public/stylesheets/admin.css')

      m.template(
      'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      )

      m.template('shoulda_functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      m.template('helper.rb',          File.join('app/helpers', "admin_helper.rb"))

      m.route_resources controller_file_name

      # Copy Icons
      Dir[File.join(File.dirname(__FILE__),'templates','images/*')].each do |image|
        m.file File.join('images',File.basename(image)), File.join('public','images','admin',File.basename(image))
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
      require "#{file_name}"
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
end