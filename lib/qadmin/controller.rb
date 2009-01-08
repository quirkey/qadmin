module Qadmin
  module Controller

    module Macros

      def qadmin(options = {})

        include Actions
      end

    end

    module Actions

      def self.included(controller_klass)
        model_name = controller_klass.to_s.demodulize.gsub(/Controller/,'')
        controller_klass.class_eval <<-EOT
        def index

        end

        def show

        end

        def new

        end

        def create

        end

        def edit

        end

        def update

        end

        def destroy

        end

        protected
        def model_name
          @model_name ||= '#{model_name}'
        end

        def model_instance_name

        end

        EOT
      end
    end      

    # # GET /<%= controller_file_path %>
    # # GET /<%= controller_file_path %>.xml
    # def index
    #   # <%= model_name %>.with_sort(current_sort) do
    #   @<%= model_name.tableize %> = <%= model_name %>.paginate(:page => (params[:page] || 1))
    #   # end
    # 
    #   respond_to do |format|
    #     format.html # index.html.erb
    #     format.xml  { render :xml => @<%= table_name %> }
    #   end
    # end
    # 
    # # GET /<%= controller_file_path %>/1
    # # GET /<%= controller_file_path %>/1.xml
    # def show
    #   @<%= file_name %> = <%= model_name %>.find(params[:id])
    # 
    #   respond_to do |format|
    #     format.html # show.html.erb
    #     format.xml  { render :xml => @<%= file_name %> }
    #   end
    # end
    # 
    # # GET /<%= controller_file_path %>/new
    # # GET /<%= controller_file_path %>/new.xml
    # def new
    #   @<%= file_name %> = <%= model_name %>.new
    # 
    #   respond_to do |format|
    #     format.html # new.html.erb
    #     format.xml  { render :xml => @<%= file_name %> }
    #   end
    # end
    # 
    # # GET /<%= controller_file_path %>/1/edit
    # def edit
    #   @<%= file_name %> = <%= model_name %>.find(params[:id])
    # end
    # 
    # # POST /<%= controller_file_path %>
    # # POST /<%= controller_file_path %>.xml
    # def create
    #   @<%= file_name %> = <%= model_name %>.new(params[:<%= file_name %>])
    # 
    #   respond_to do |format|
    #     if @<%= file_name %>.save
    #       flash[:message] = '<%= model_name %> was successfully created.'
    #       format.html { redirect_to(<%= table_name.singularize %>_path(@<%= file_name %>)) }
    #       format.xml  { render :xml => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
    #     else
    #       format.html { render :action => "new" }
    #       format.xml  { render :xml => @<%= file_name %>.errors }
    #     end
    #   end
    # end
    # 
    # # PUT /<%= controller_file_path %>/1
    # # PUT /<%= controller_file_path %>/1.xml
    # def update
    #   @<%= file_name %> = <%= model_name %>.find(params[:id])
    # 
    #   respond_to do |format|
    #     if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
    #       flash[:message] = '<%= model_name %> was successfully updated.'
    #       format.html { redirect_to(<%= table_name.singularize %>_path(@<%= file_name %>)) }
    #       format.xml  { head :ok }
    #     else
    #       format.html { render :action => "edit" }
    #       format.xml  { render :xml => @<%= file_name %>.errors }
    #     end
    #   end
    # end
    # 
    # # DELETE /<%= controller_file_path %>/1
    # # DELETE /<%= controller_file_path %>/1.xml
    # def destroy
    #   @<%= file_name %> = <%= model_name %>.find(params[:id])
    #   @<%= file_name %>.destroy
    #   flash[:message] = "<%= model_name %> #{@<%= file_name %>} was deleted"
    #   respond_to do |format|
    #     format.html { redirect_to(<%= table_name %>_path) }
    #     format.xml  { head :ok }
    #   end
    # end

  end
end