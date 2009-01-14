require File.dirname(__FILE__) + '/test_helper.rb'

class TestQadminController < Test::Unit::TestCase

  protected  
  def crud_actions
    [:index, :show, :new, :create, :edit, :update, :destroy]
  end
  
  def assert_defines_actions(*actions)
    [actions].flatten.each do |action|
      assert @controller.respond_to?(action), "Should define ##{action}"
    end
  end
  
  def assert_does_not_define_actions(*actions)
    [actions].flatten.each do |action|
      assert !@controller.respond_to?(action), "Should not define ##{action}"
    end
  end
  public

  context "QadminController" do
    context "Macros" do
      context "#qadmin" do
        
        context "with no options" do
          setup do
            class ::NoOption < ActiveRecord::Base; end
            class NoOptionsController < MockController
              qadmin
            end
            @controller = NoOptionsController.new
          end
          
          should "define all CRUD actions" do
            assert_defines_actions(crud_actions)
          end
          
          should "set qadmin configuration" do
            assert @controller.send(:qadmin_configuration).is_a?(Qadmin::Configuration)
          end
          
          should "set model_name from controller name" do
            assert_equal 'NoOption', @controller.send(:model_name)
          end
          
          should "set model_instance_name to underscored version" do
            assert_equal 'no_option', @controller.send(:model_instance_name)
          end
          
          should "set human_name to model.humanize" do
            assert_equal 'No option', @controller.send(:model_human_name)
          end
        end
        
        context "with hashed options" do
          context "with :exclude" do
            setup do
              class ::Exclude < ActiveRecord::Base; end
              class ExcludeController < MockController
                qadmin :available_actions => {:exclude => [:show, :destroy]}
              end
              @controller = ExcludeController.new
            end
            
            should "define CRUD actions" do
              assert_defines_actions(crud_actions - [:show, :destroy])
            end
            
            should "not define actions in exclude" do
              assert_does_not_define_actions([:show, :destroy])
            end
          end
          
          context "with :only" do
            setup do
              class ::Only < ActiveRecord::Base; end
              class OnlyController < MockController
                qadmin :available_actions => {:only => [:index, :show]}
              end
              @controller = OnlyController.new
            end
            
            should "define CRUD actions" do
              assert_defines_actions(:index, :show)
            end
            
            should "not define actions in exclude" do
              assert_does_not_define_actions(crud_actions - [:index, :show])
            end
          end
          
          context "with :model_name" do
            should "set #model_name" do
              
            end
          end
          
          context "with :human_name" do
            
            should "set the human name" do
              
            end
            
            should "not effect the existing model name" do
              
            end
          end
          
          context "with two instances in different controllers" do
            setup do
              class ::NewExclude < ActiveRecord::Base; end
              class NewExcludeController < MockController
                qadmin do |config|
                  config.available_actions.exclude = [:show, :new]
                end
              end
              @exclude_controller = NewExcludeController.new
              class NewOnlyController < MockController
                qadmin :model_name => 'Item', :available_actions => {:only => [:index, :show]}
              end
              @only_controller = NewOnlyController.new
            end
            
            should "not include actions for :exclude" do
              @controller = @exclude_controller
              assert_does_not_define_actions(:show, :new)
              assert_defines_actions(crud_actions - [:show, :new])
            end
            
            should "include actions for :only" do
              @controller = @only_controller
              assert_does_not_define_actions(crud_actions - [:index, :show])
              assert_defines_actions([:index, :show])
            end
            
            should "set model name independently" do
              assert_equal 'Item', @only_controller.send(:model_name)
              assert_equal 'NewExclude', @exclude_controller.send(:model_name)
            end
          end
        end
        
      end
    end
  end
end
