module Qadmin
  class FormBuilder < ::ActionView::Helpers::FormBuilder
    
    def labeled_text_field(method, options = {})
      label_text = options.delete(:label) || method.to_s.humanize
      %{<p>
          <label>#{label_text}</label>
          #{text_field(method, options)}
        </p>
      }
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