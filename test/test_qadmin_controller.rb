require File.dirname(__FILE__) + '/test_helper.rb'

class TestQadminController < Test::Unit::TestCase

  protected  
  def crud_actions
    [:index, :show, :new, :create, :edit, :update, :destroy]
  end
  public

  context "QadminController" do
    context "Macros" do
      context "#qadmin" do
        
        context "with no options" do
          setup do
            class NoOptionController < MockController
              qadmin
            end
            @controller = NoOptionController.new
          end
          
          should "define all CRUD actions" do
            crud_actions.each do |action|
              assert @controller.respond_to?(action), "Should define ##{action}"
            end
          end
          
          should "set model_name from controller name" do
            assert_equal 'NoOption', @controller.send(:model_name)
          end
        end
        
        context "with hashed options" do
          context "with :exclude" do
            
            should "define CRUD actions" do
              
            end
            
            should "not define actions in exclude" do
              
            end
          end
          
          context "with :only" do
            
            should "define CRUD actions listed in hash" do
              
            end
            
            should "not define crud actions not listed" do
              
            end
          end
          
          context "with :name" do
            
            should "set #name" do
              
            end
          end
        end
        
      end
    end
  end
end
