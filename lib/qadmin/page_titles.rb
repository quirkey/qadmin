module Qadmin
  module PageTitles

    def self.included(other)
      other.module_eval do
        include ControllerMethods
        extend MacroMethods
        helper_method :get_page_title, :set_page_title
      end
    end
    
    module MacroMethods
      def page_title(add_title)
        before_filter do |controller|
          controller.set_page_title(add_title)
        end
      end
    end

    module ControllerMethods

      def get_page_title(delimeter = ' : ')
        @page_title ||= []
        @page_title.join(delimeter)
      end
      

      def set_page_title(add_this)
        get_page_title
        @page_title << "#{add_this}"
      end
    end 
  end
end