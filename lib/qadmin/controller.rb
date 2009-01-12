module Qadmin
  module Controller

    module Macros
      
      
      def qadmin(options = {})
        extend ::Qadmin::Options
        self.cattr_accessor :model_name, :model_instance_name, :model_collection_name, :model_human_name, :available_actions
        self.available_actions     = [:index, :show, :new, :create, :edit, :update, :destroy]
        self.available_actions     = [options[:only]].flatten    if options[:only]
        self.available_actions    -= [options[:exclude]].flatten if options[:exclude]
        self.extract_model_from_options(options)
        self.append_view_path(File.join(File.dirname(__FILE__), 'views'))
        include Qadmin::Templates
        include Qadmin::Overlay
        define_admin_actions(available_actions, options)
      end
      
      private
      
      def define_admin_actions(actions, options = {})
        action_method_code = {
          :index => %{
          def index
            @model_collection = @#{model_collection_name} = #{model_name}.paginate(:page => (params[:page] || 1))
            respond_to do |format|
              format.html { render_template_for_section }
              format.xml
            end
          end
          },
          :show => %{
          def show
            @model_instance = @#{model_instance_name} = #{model_name}.find(params[:id])
            respond_to do |format|
              format.html
              format.xml
            end
          end
          },
          :new => %{
          def new
            @model_instance = @#{model_instance_name} = #{model_name}.new
            respond_to do |format|
              format.html # new.html.erb
              format.xml  { render :xml => @#{model_instance_name} }
            end
          end
          },
          :create => %{
          def create
            @model_instance = @#{model_instance_name} = #{model_name}.new(params[:#{model_instance_name}])
            respond_to do |format|
              if @#{model_instance_name}.save
                flash[:message] = '#{model_human_name} was successfully created.'
                format.html { redirect_to(#{model_instance_name}_path(@#{model_instance_name})) }
                format.xml  { render :xml => @#{model_instance_name}, :status => :created, :location => @#{model_instance_name} }
              else
                format.html { render :action => "new" }
                format.xml  { render :xml => @#{model_instance_name}.errors }
              end
            end
          end
          },
          :edit => %{
          def edit
            @model_instance = @#{model_instance_name} = #{model_name}.find(params[:id])
          end
          },
          :update => %{
          def update
            @model_instance = @#{model_instance_name} = #{model_name}.find(params[:id])

            respond_to do |format|
              if @#{model_instance_name}.update_attributes(params[:#{model_instance_name}])
                flash[:message] = '#{model_human_name} was successfully updated.'
                format.html { redirect_to(#{model_instance_name}_path(@#{model_instance_name})) }
                format.xml  { head :ok }
              else
                format.html { render :action => "edit" }
                format.xml  { render :xml => @#{model_instance_name}.errors }
              end
            end
          end
          },
          :destroy => %{
          def destroy
            @model_instance =  @#{model_instance_name} = #{model_name}.find(params[:id])
            @#{model_instance_name}.destroy
            flash[:message] = "#{model_human_name} \#{@#{model_instance_name}} was deleted"
            respond_to do |format|
              format.html { redirect_to(#{model_collection_name}_path) }
              format.xml  { head :ok }
            end
          end
          }
        }
        action_code = actions.collect {|a| action_method_code[a.to_sym] }.join("\n")
        helper_methods = %{
          helper_method :model_name, :model_instance_name, :model_collection_name, :model_human_name, :model_klass, :available_actions
        }
        action_code = helper_methods << action_code
        self.class_eval(action_code)
      end
    end

  end
end