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
    
    def paperclip_file_field(method, options = {})
      html = %{<p>}
      label_text = options.delete(:label) || method.to_s.humanize
      html << label(method, label_text)
      if object.send("#{method}?")
        html << %{
          <em>View existing #{label_text}:</em>
          <a href="#{object.send(method).url}" target="_blank">#{object.send("#{method}_file_name")}</a>
          <br />
        }
      end
      html << %{
        #{file_field(method, options)}
      </p>}
      html
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