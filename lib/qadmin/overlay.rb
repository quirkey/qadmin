module Qadmin
  module Overlay

    def self.included(other)
      other.module_eval do
        helper_method :overlay?
        
        include ControllerMethods
      end
    end

    module ControllerMethods
      protected
      def layout_or_overlay(options = {})
        @_overlay = false
        fallback_layout = options[:default] || 'admin'
        if (options[:only] && !Array(options[:only]).include?(action_name)) || (options[:except] && Array(options[:except]).include?(action_name))
          return fallback_layout
        end
        if params[:_overlay]
          @_overlay = true
          false 
        else
          fallback_layout
        end
      end

      # 
      def overlay?
        @_overlay && @_overlay == true
      end
    end
  end
end