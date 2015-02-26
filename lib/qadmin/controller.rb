module Qadmin
  module Controller
    ACTION_TEMPLATE_PATH = File.join(File.dirname(__FILE__), 'actions').freeze

    def self.admin_action_template(action_name)
      if @qadmin_template && @qadmin_template[action_name]
        @qadmin_template[action_name]
      else
        @qadmin_template ||= {}
        @qadmin_template[action_name] ||= File.read(File.join(ACTION_TEMPLATE_PATH, "#{action_name}.erb"))
      end
    end

    module Macros

      def qadmin(options = {})
        self.cattr_accessor :qadmin_configuration
        self.qadmin_configuration = Qadmin::Configuration::Resource.new({:controller_klass => self}.merge(options))
        self.delegate(:model_name, :model_klass, :model_collection_name, :model_instance_name, :model_human_name, :to => :qadmin_configuration)
        yield(self.qadmin_configuration) if block_given?
        include Qadmin::Controller::Helpers
        include Qadmin::Templates
        include Qadmin::Overlay
        self.append_view_path(File.join(File.dirname(__FILE__), 'views'))
        define_admin_actions(qadmin_configuration.available_actions, options)
      end

      private

      def define_admin_actions(actions, options = {})
        action_code = actions.collect {|a| Qadmin::Controller.admin_action_template(a) }.join("\n")
        config = self.qadmin_configuration
        helper_methods = %{
          delegate :model_name, :model_klass, :model_collection_name, :model_instance_name, :model_human_name, :to => :qadmin_configuration
          helper_method :qadmin_configuration, :model_name, :model_instance_name, :model_collection_name, :model_human_name, :available_actions, :parent_instance
        }
        additional_methods = %{
          def #{config.model_instance_name}_params
            if params.respond_to?(:permit)
              params.require(:#{config.model_instance_name}).permit!
            else
              params[:#{config.model_instance_name}]
            end
          end

          def add_form
            @origin_div = params[:from]
            @num = params[:num]
            @content_type = params[:content_type] || model_instance_name
            obj = @origin_div.to_s.singularize
            respond_to do |format|
              format.js {
                render :update do |page|
                  page.insert_html :bottom, @origin_div, :partial => "content_forms/\#{obj}_form", :locals => {obj => nil, :index => @num, :content_type => @content_type}
                end
              }
            end
          end

          private
          def parent_instance
            instance_variable_get("@\#{qadmin_configuration.parent}")
          end
        }
        action_code = helper_methods << action_code << additional_methods
        rendered = Erubis::Eruby.new(action_code).result(binding())
        self.class_eval(rendered, __FILE__, 57)
      end

    end

    module Helpers

      def qadmin_configuration
        self.class.qadmin_configuration
      end

    end

  end
end
