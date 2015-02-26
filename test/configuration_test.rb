require "helper"

class Qadmin::ConfigurationTest < Minitest::Test

  context "Configuring a Resource" do
    setup do
      @configuration = Qadmin::Configuration::Resource.new(:controller_klass => ThingsController)
    end

    context "initializing" do
      should "extrapolate the model klass names" do
        assert_nil @configuration.namespace
        assert_equal "Thing", @configuration.model_name
        assert_equal "Thing", @configuration.model_human_name
        assert_equal "things", @configuration.model_collection_name
      end

      should "create special config objects for each action" do
        @configuration.available_actions.each do |action|
          assert_equal "Qadmin::Configuration::Actions::#{action.to_s.classify}", @configuration.send("on_#{action}").class.to_s
        end
      end

      should "extract the namespace from a namespaced controller" do
        @configuration = Qadmin::Configuration::Resource.new(:controller_klass => Admin::ItemsController)
        assert_equal :admin, @configuration.namespace
        assert_equal "Item", @configuration.model_name
        assert_equal "Item", @configuration.model_human_name
        assert_equal "items", @configuration.model_collection_name
      end

    end

    context "path_prefix" do
      should "include namespace if set" do
        @configuration.namespace = :admin
        assert_equal 'admin_thing', @configuration.path_prefix
        assert_equal 'admin_thing', @configuration.on_create.path_prefix
      end

      should "not include nil namespace" do
        assert_equal 'thing', @configuration.path_prefix
        assert_equal 'thing', @configuration.on_create.path_prefix
      end
    end
  end

end
