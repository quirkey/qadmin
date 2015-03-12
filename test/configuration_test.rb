require "helper"

class Qadmin::ConfigurationTest < Minitest::Test

  context "Configuration" do

    context "Resource" do

      setup do
        @configuration = Qadmin::Configuration::Resource.new(:controller_klass => BasicModelsController)
      end

      context "#initialize" do

        should "extrapolate the model klass names" do
          assert_nil @configuration.namespace
          assert_equal "BasicModel", @configuration.model_name
          assert_equal "Basic model", @configuration.model_human_name
          assert_equal "basic_models", @configuration.model_collection_name
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

      context "#properties" do

        should "return hash of configuration properties" do
          hash = @configuration.properties
          keys = %w{controller_klass controller_name model_name model_instance_name model_collection_name model_human_name namespace}
          assert_equal keys.sort, hash.keys.sort
        end

      end

      context "#model_column_names" do

        should "delegate model column names" do
          refute_nil @configuration.model_column_names
          refute_empty @configuration.model_column_names
          assert_equal BasicModel.column_names, @configuration.model_column_names
        end

      end

      context "#path_prefix" do

        should "include namespace if set" do
          @configuration.namespace = :admin
          assert_equal 'admin_basic_model', @configuration.path_prefix
          assert_equal 'admin_basic_model', @configuration.on_create.path_prefix
        end

        should "not include nil namespace" do
          assert_equal 'basic_model', @configuration.path_prefix
          assert_equal 'basic_model', @configuration.on_create.path_prefix
        end

      end
    end
  end
end
