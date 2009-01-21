require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  
  context "<%= controller_class_name %>" do
    setup do
      @<%= file_name %> = <%= table_name %>(:aaron)
      @<%= file_name =>_params = {
<%= attributes.collect { |a| ":#{a.name} => #{a.default}" }.join(",\n\t") %>
      }
    end

    context "html" do
      context "GET index" do
        setup do
          get :index
        end

        should_respond_with :success

        should "load paginated collection of <%= table_name =>" do
          assert assigns(:<%= table_name =>)
          assert assigns(:<%= table_name =>).respond_to?(:next_page)
        end

        should "display <%= file_name =>" do
          assert_select "#<%= file_name =>_#{@<%= file_name =>.id}"
        end
      end

      context "GET show" do
        setup do
          get :show, :id => @<%= file_name =>.id
        end

        should_respond_with :success
        should_assign_to :<%= file_name =>

        should "load <%= file_name =>" do
          assert_equal @<%= file_name =>, assigns(:<%= file_name =>)
        end

        should "display <%= file_name =>" do
          assert_select "#<%= file_name =>_#{@<%= file_name =>.id}"
        end
      end

      context "GET new" do
        setup do
          get :new
        end

        should_respond_with :success
        should_assign_to :<%= file_name =>

        should "display form" do
          assert_select 'form'
        end
      end

      context "POST create with valid <%= file_name =>" do
        setup do
          post :create, :<%= file_name => => @<%= file_name =>_params
        end

        should_change '<%= model_name =>.count', :by => 1
        should_redirect_to "<%= file_name =>_path(@<%= file_name =>)"
        should_assign_to :<%= file_name =>
      end

      context "GET edit" do
        setup do
          get :edit, :id => @<%= file_name =>.id
        end

        should_respond_with :success
        should_assign_to :<%= file_name =>

        should "load <%= file_name =>" do
          assert_equal @<%= file_name =>, assigns(:<%= file_name =>)
        end

        should "display form" do
          assert_select 'form'
        end
      end

      context "PUT update" do
        setup do
          put :update, :id => @<%= file_name =>.id, :<%= file_name => => @<%= file_name =>_params
        end

        should_not_change '<%= model_name =>.count'
        should_redirect_to "<%= file_name =>_path(@<%= file_name =>)"
        should_assign_to :<%= file_name =>

        should "load <%= file_name =>" do
          assert_equal @<%= file_name =>, assigns(:<%= file_name =>)
        end
      end

      context "DELETE destroy" do
        setup do
          delete :destroy, :id => @<%= file_name =>.id
        end

        should_change '<%= model_name =>.count', :by => -1
        should_redirect_to "<%= table_name =>_path"
        should_assign_to :<%= file_name =>
      end
    end
  end
  
end
