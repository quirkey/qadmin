module Qadmin
  class FormBuilder < ::ActionView::Helpers::FormBuilder
        
    %w{text_field text_area check_box}.each do |field|
      module_eval <<-EOT
        def labeled_#{field}(method, options = {})
          label_text = options.delete(:label) || method.to_s.humanize
          %{<p>
              \#{label(method, label_text)}
              \#{#{field}(method, options)}
            </p>
          }
        end
      EOT
    end
           
    def text_field_with_hint(method, options = {})
      if object.send(method).blank?
        options[:class] = if options[:class]
          options[:class] << ' hinted'
        else 
          'hinted'
        end
        options[:value] = options.delete(:hint)
      end
      text_field(method, options)
    end
   
  end
end