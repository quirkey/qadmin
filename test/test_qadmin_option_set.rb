require File.dirname(__FILE__) + '/test_helper.rb'

class TestQadminOptionSet < Test::Unit::TestCase

  context "OptionSet" do
    context "initializing" do
      context "with an array" do
        setup do
          @option_set = Qadmin::OptionSet.new([:index, :show, :delete])
        end
        
        should "set array as default" do
          assert_equal [:index, :show, :delete], @option_set.default
        end
        
        should "return array as current" do
          assert_equal [:index, :show, :delete], @option_set.current
        end
      end
      
      context "with only options" do
        setup do
          @option_set = Qadmin::OptionSet.new(:default => [:index, :show, :delete], :exclude => :delete)
        end
        
        should "set default with options" do
          assert_equal [:index, :show, :delete], @option_set.default
        end
        
        should "set exclude with options" do
          assert_equal [:delete], @option_set.exclude
        end
      end
      
      context "with an array and options" do
        setup do
          @option_set = Qadmin::OptionSet.new([:index, :show, :delete], :only => :delete)
        end
        
        should "set default as array" do
          assert_equal [:index, :show, :delete], @option_set.default
        end
        
        should "set only with options" do
          assert_equal [:delete], @option_set.only
        end
      end
    end
    
    context "an Option Set" do
      context "with exclude set" do
        setup do
          @option_set = Qadmin::OptionSet.new(:default => [:index, :show, :delete], :exclude => :delete)
        end
        
        should "return current without excludes" do
          assert_equal [:index, :show], @option_set.current
        end
        
        should "itterate over current" do
          @option_set.each do |option|
            assert [:index, :show].include?(option)
          end
        end
      end
      
      context "with only set" do
        setup do
          @option_set = Qadmin::OptionSet.new(:default => [:index, :show, :delete], :only => [:show, :delete])
        end
        
        should "return only as current" do
          assert_equal [:show, :delete], @option_set.current
        end
        
        should "itterate over only" do
          @option_set.each do |option|
            assert [:show, :delete].include?(option)
          end

        end        
      end
    end
  end

end