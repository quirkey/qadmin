module Qadmin
  module Controller

    module Macros      
      
      def qadmin(options = {})
        self.cattr_accessor :qadmin_configuration
        self.qadmin_configuration = Qadmin::Configuration::Resource.new({:controller_klass => self}.merge(options))
        self.delegate :model_name, :model_klass, :model_collection_name, :model_instance_name, :model_human_name, :to => lambda { self.class.qadmin_configuration }
        yield(self.qadmin_configuration) if block_given?
        include Qadmin::Templates
        include Qadmin::Overlay
        self.append_view_path(File.join(File.dirname(__FILE__), 'views'))
        define_admin_actions(qadmin_configuration.available_actions, options)
      end
      
      private
      
      def define_admin_actions(actions, options = {})
        action_template_path = File.join(File.dirname(__FILE__), 'actions')
        raw_action_code = actions.collect {|a| File.read(File.join(action_template_path, "#{a}.erb")) }.join("\n")
        action_code = ERB.new(raw_action_code).result(binding)
        helper_methods = %{
          delegate :model_name, :model_klass, :model_collection_name, :model_instance_name, :model_human_name, :to => :qadmin_configuration
          helper_method :qadmin_configuration, :model_name, :model_instance_name, :model_collection_name, :model_human_name, :available_actions
        }
        additional_methods = %{
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
        }
        action_code = helper_methods << action_code << additional_methods
        self.class_eval(action_code)
      end
      
      def config
        self.qadmin_configuration
      end
    end

  end
end