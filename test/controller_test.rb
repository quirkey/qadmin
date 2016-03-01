require "helper"

class Qadmin::ControllerTest < Minitest::Test

  CRUD_ACTIONS = [:index, :show, :new, :create, :edit, :update, :destroy]

  context "QadminController" do
    context "Macros" do
      context "#qadmin" do

        context "with no options" do

          class ::BasicModelsController < MockController
            qadmin
          end

          setup do
            @controller = ::BasicModelsController.new
          end

          should "define all CRUD actions" do
            assert_defines_actions(@controller, CRUD_ACTIONS)
          end

          should "set qadmin configuration" do
            assert @controller.send(:qadmin_configuration).is_a?(Qadmin::Configuration::Resource)
          end

          should "set model_name from controller name" do
            assert_equal 'BasicModel', @controller.send(:model_name)
          end

          should "set model_instance_name to underscored version" do
            assert_equal 'basic_model', @controller.send(:model_instance_name)
          end

          should "set human_name to model.humanize" do
            assert_equal 'Basic model', @controller.send(:model_human_name)
          end
        end

        context "with hashed options" do

          context "with two instances in different controllers" do

            class ::ComplexModelsController < MockController
              qadmin do |config|
                config.available_actions = [:index, :create, :edit, :update, :destroy]
              end
            end

            class ::ItemsController < MockController
              qadmin :model_name => 'Item', :available_actions => [:index, :show]
            end

            setup do
              @exclude_controller = ::ComplexModelsController.new
              @only_controller = ::ItemsController.new
            end

            should "not include actions for :exclude" do
              assert_does_not_define_actions(@exclude_controller, [:show, :new])
              assert_defines_actions(@exclude_controller, [:index, :create, :edit, :update, :destroy])
            end

            should "include actions for :only" do
              assert_does_not_define_actions(@only_controller, [:create, :edit, :update, :destroy])
              assert_defines_actions(@only_controller, [:index, :show])
            end

            should "set model name independently" do
              assert_equal 'Item', @only_controller.send(:model_name)
              assert_equal 'ComplexModel', @exclude_controller.send(:model_name)
            end
          end
        end
      end
    end
  end

  def assert_defines_actions(controller, actions)
    actions.each do |action|
      assert controller.respond_to?(action), "Should define ##{action}"
    end
  end

  def assert_does_not_define_actions(controller, actions)
    actions.each do |action|
      refute controller.respond_to?(action), "Should not define ##{action}"
    end
  end

end
