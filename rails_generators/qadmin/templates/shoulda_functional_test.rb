require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase

  context "<%= controller_class_name %>" do
    setup do
      @<%= file_name %> = <%= model_name.tableize %>(!!FIXTURENAME)
    end
    context "logged in as an admin" do
      setup do
        login_as_admin
      end  
      should_be_restful do |resource|

        <%= file_name %>_params = {
          <%= attributes.collect { |a| ":#{a.name} => #{a.default}" }.join(",\n\t") %>
        }

        resource.create.params = <%= file_name %>_params
        resource.update.params = <%= file_name %>_params.update({})

        resource.destroy.flash = /deleted/
      end
    end
    context "not logged in" do
      should_be_restful do |resource|
        resource.denied.flash = /logged in/
        resource.denied.actions = [:index, :show, :edit, :new, :create, :update, :destroy]
      end
    end
  end

end
