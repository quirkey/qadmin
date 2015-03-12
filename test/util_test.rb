require "helper"

class Qadmin::UtilTest < Minitest::Test

  context "Util" do

    context "#model_name_from_controller" do

      should "return model name" do
        assert_equal "BasicModel", Qadmin::Util.model_name_from_controller(BasicModelsController)
      end

    end

  end

end
