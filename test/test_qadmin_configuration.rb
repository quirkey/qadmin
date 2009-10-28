require File.dirname(__FILE__) + '/test_helper.rb'

class TestQadminConfiguration < Test::Unit::TestCase

  context "Configuring a Resource" do
    setup do
      class ItemsController < MockController; end
      @configuration = Qadmin::Configuration::Resource.new(:controller_klass => ItemsController)
    end
    
    context "initializing" do      
      should "extrapolate the model klass names" do
        assert_equal "Item", @configuration.model_name
        assert_equal "Item", @configuration.model_human_name
        assert_equal "items", @configuration.model_collection_name
      end
      
      should "create special config objects for each action" do
        @configuration.available_actions.each do |action|
          assert_equal "Qadmin::Configuration::Actions::#{action.to_s.classify}", @configuration["on_#{action}"].class.to_s
        end
      end
      
    end
    
    context "path_prefix" do
      should "include namespace if set" do
        @configuration.namespace = :admin
        assert_equal 'admin_item', @configuration.path_prefix
        assert_equal 'admin_item', @configuration.on_create.path_prefix
      end
      
      should "not include nil namespace" do
        assert_equal 'item', @configuration.path_prefix
        assert_equal 'item', @configuration.on_create.path_prefix
      end
    end
  end

end