require File.dirname(__FILE__) + '/test_helper.rb'

class TestQadminConfiguration < Test::Unit::TestCase

  context "Configuring a Resource" do
    context "initializing" do
      setup do
        class ItemsController < MockController; end
        @configuration = Qadmin::Configuration::Resource.new(:controller_klass => ItemsController)
      end
      
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
  end

end