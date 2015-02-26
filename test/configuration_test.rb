require "helper"

class Qadmin::ConfigurationTest < Minitest::Test

  context "Configuring a Resource" do

    context "root namespace" do

      setup do
        class ::Thing
        end
        @configuration = Qadmin::Configuration::Resource.new(:controller_class => ThingsController)
      end

      should "extrapolate the model info" do
        assert_nil @configuration.namespace
        assert_equal "Thing", @configuration.model_name
        assert_equal "Thing", @configuration.model_human_name
        assert_equal "things", @configuration.model_collection_name
      end

      should "have no namespace" do
        assert_equal 'thing', @configuration.path_prefix
        assert_equal 'thing', @configuration.on_create.path_prefix
      end

      should "create special config objects for each action" do
        @configuration.available_actions.each do |action|
          assert_equal "Qadmin::Configuration::Actions::#{action.to_s.classify}", @configuration.send("on_#{action}").class.to_s
        end
      end

    end

    context "admin namespace" do

      setup do
        module ::Admin
          class Item
          end
        end
        @configuration = Qadmin::Configuration::Resource.new(:controller_class => ::Admin::ItemsController)
      end

      should "populate the model info" do
        assert_equal :admin, @configuration.namespace
        assert_equal "Item", @configuration.model_name
        assert_equal "Item", @configuration.model_human_name
        assert_equal "items", @configuration.model_collection_name
      end

      should "include path prefix" do
        assert_equal 'admin_item', @configuration.path_prefix
        assert_equal 'admin_item', @configuration.on_create.path_prefix
      end

    end

  end

end
