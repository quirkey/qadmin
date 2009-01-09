require File.dirname(__FILE__) + '<%= '/..' * controller_class_nesting_depth %>/../test_helper'
require '<%= controller_file_path %>_controller'

# Re-raise errors caught by the controller.
class <%= controller_class_name %>Controller; def rescue_action(e) raise e end; end

class <%= controller_class_name %>ControllerTest < Test::Unit::TestCase
  fixtures :<%= model_name.tableize %>#, :users

  def setup
    @controller = <%= controller_class_name %>Controller.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    #login_as(:aaron)
    @<%= file_name %> = <%= model_name.tableize %>(!!FIXTURENAME)
  end

  # def test_should_require_login
  #   logout
  #   get :index
  #   assert_redirected_to_login
  # end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:<%= model_name.tableize %>)
  end

  def test_should_get_new
    get :new
    assert_response :success
    assert_select 'form'
  end
  
  def test_should_create_<%= file_name %>
    assert_difference '<%= model_name %>.count' do
      post :create, :<%= file_name %> => <%= file_name %>_params
      assert_redirected_to <%= table_name.singularize %>_path(assigns(:<%= file_name %>))
    end
  end

  def test_should_show_<%= file_name %>
    get :show, :id => @<%= file_name %>.id
    assert_response :success
    assert assigns(:<%= file_name %>)
  end

  def test_should_get_edit
    get :edit, :id =>  @<%= file_name %>.id
    assert_response :success
    assert assigns(:<%= file_name %>)
    assert_select 'form'
  end
  
  def test_should_update_<%= file_name %>
    assert_no_difference '<%= model_name %>.count' do
      put :update, :id => @<%= file_name %>.id, :<%= file_name %> => <%= file_name %>_params
      assert_redirected_to <%= table_name.singularize %>_path(assigns(:<%= file_name %>))
    end
  end
  
  def test_should_destroy_<%= file_name %>
    assert_difference '<%= model_name %>.count', -1 do
      delete :destroy, :id => @<%= file_name %>.id
      assert_redirected_to <%= table_name %>_path
    end
  end
  
  
  protected
  def <%= file_name %>_params(options = {})
    {
      <%= attributes.collect { |a| ":#{a.name} => #{a.default}" }.join(', ') %>
    }.update(options)
  end
end
