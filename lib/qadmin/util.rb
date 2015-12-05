module Qadmin

  module Util

    extend self

    # @param [Class, String] controller
    # @return [String]
    def model_name_from_controller(controller)
      controller.to_s.demodulize.gsub(/Controller/,'').singularize
    end

  end

end
