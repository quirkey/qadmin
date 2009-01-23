module Qadmin
  module Assets
    module FormBuilder
      
      def asset_selector(method, options = {})
  
        id = "#{object_name}_#{method}"
        form_name = "#{object_name}[#{method}]"

        options.reverse_merge!({
          :id => id,
          :form_name => form_name,
          :name => object_name,
          :method => method,
          :object => object,
          :current => object.send(method),
          :label => false,
          :resize_type => object_name.tableize,
          :multiple => true
        })
        @template.render(:partial => 'assets/asset_selector', :locals => options)
      end

      def asset_browser(id, options = {})
        options.reverse_merge!({
          :id => id,
          :label => false,
          :resize_type => ''
        })
        @template.render(:partial => 'shared/file_browser', :locals => options)
      end
      
    end
    
  end
end