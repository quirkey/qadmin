module Qadmin
  module Controller

    module Macros
      
      
      def qadmin(options = {})
        self.cattr_accessor :qadmin_configuration
        self.qadmin_configuration = Qadmin::Configuration.new({:controller_klass => self}.merge(options))
        self.delegate :model_name, :model_klass, :model_collection_name, :model_instance_name, :model_human_name, :to => lambda { self.class.qadmin_configuration }
        yield(self.qadmin_configuration) if block_given?
        include Qadmin::Templates
        include Qadmin::Overlay
        self.append_view_path(File.join(File.dirname(__FILE__), 'views'))
        define_admin_actions(qadmin_configuration.available_actions, options)
      end
      
      private
      
      def define_admin_actions(actions, options = {})
        config = self.qadmin_configuration
        action_method_code = {
          :index => %{
          def index
            logger.info 'Qadmin: Default /index'
            scope = qadmin_configuration.model_klass
            scope = scope.send(qadmin_configuration.default_scope) if qadmin_configuration.default_scope
            scope =  scope.restful_query(params[:query]) if #{config.model_name}.can_query?
            @model_collection = @#{config.model_collection_name} = scope.paginate(:page => (params[:page] || 1), :per_page => (params[:per_page] || 25))
            logger.warn 'controller params:' + params.inspect
            respond_to do |format|
              format.html { render_template_for_section('index.html') }
              format.xml
            end
          end
          },
          :show => %{
          def show
            logger.info 'Qadmin: Default /show'
            @model_instance = @#{config.model_instance_name} = #{config.model_name}.find(params[:id])
            respond_to do |format|
              format.html { render_template_for_section('show.html') }
              format.xml
            end
          end
          },
          :new => %{
          def new
            logger.info 'Qadmin: Default /new'
            @model_instance = @#{config.model_instance_name} = #{config.model_name}.new
            respond_to do |format|
              format.html { render_template_for_section('new.html') }
              format.xml  { render :xml => @#{config.model_instance_name} }
            end
          end
          },
          :create => %{
          def create
            logger.info 'Qadmin: Default /create'
            @model_instance = @#{config.model_instance_name} = #{config.model_name}.new(params[:#{config.model_instance_name}])
            respond_to do |format|
              if @#{config.model_instance_name}.save
                flash[:message] = '#{config.model_human_name} was successfully created.'
                format.html { redirect_to(#{config.model_instance_name}_path(@#{config.model_instance_name})) }
                format.xml  { render :xml => @#{config.model_instance_name}, :status => :created, :location => @#{config.model_instance_name} }
              else
                format.html { render_template_for_section('new.html') }
                format.xml  { render :xml => @#{config.model_instance_name}.errors }
              end
            end
          end
          },
          :edit => %{
          def edit
            logger.info 'Qadmin: Default /edit'
            @model_instance = @#{config.model_instance_name} = #{config.model_name}.find(params[:id])
            respond_to do |format|
              format.html { render_template_for_section('edit.html') }
              format.xml  { redirect_to #{config.model_instance_name}_path(@#{config.model_instance_name}) }
            end
          end
          },
          :update => %{
          def update
            logger.info 'Qadmin: Default /update'
            @model_instance = @#{config.model_instance_name} = #{config.model_name}.find(params[:id])

            respond_to do |format|
              if @#{config.model_instance_name}.update_attributes(params[:#{config.model_instance_name}])
                flash[:message] = '#{config.model_human_name} was successfully updated.'
                format.html { redirect_to(#{config.model_instance_name}_path(@#{config.model_instance_name})) }
                format.xml  { head :ok }
              else
                format.html { render_template_for_section('edit.html') }
                format.xml  { render :xml => @#{config.model_instance_name}.errors }
              end
            end
          end
          },
          :destroy => %{
          def destroy
            logger.info 'Qadmin: Default /destroy'
            @model_instance =  @#{config.model_instance_name} = #{config.model_name}.find(params[:id])
            @#{config.model_instance_name}.destroy
            flash[:message] = "#{config.model_human_name} \#{@#{config.model_instance_name}} was deleted"
            respond_to do |format|
              format.html { redirect_to(#{config.model_collection_name}_path) }
              format.xml  { head :ok }
            end
          end
          }
        }
        action_code = actions.collect {|a| action_method_code[a.to_sym] }.join("\n")
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
    end

  end
end