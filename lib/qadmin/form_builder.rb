module Qadmin
  class FormBuilder < ::ActionView::Helpers::FormBuilder

    %w{text_field password_field text_area check_box select}.each do |field|
      module_eval <<-EOT
        def labeled_#{field}(method, *args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          label_text = options.delete(:label) || method.to_s.humanize
          args << options
          %{<p>
              \#{label(method, label_text)}
              \#{#{field}(method, *args)}
            </p>
          }.html_safe
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
        if object.send(method).is_a?(ActiveRecord::Base)
          html << hidden_field(method, :value => object.send(method).id)
        end
      end
      html << %{
        #{file_field(method, options)}
      </p>}
      html.html_safe
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

    def image_upload_field(method, options = {})
      html = %{<p class="image-upload-field">}
      label_text = options.delete(:label) || method.to_s.humanize
      html << label(method, label_text)
      if object.send("#{method}?")
        html << %{
          <em>View existing #{label_text}:</em>
          <a href="#{object.send(method).url}" target="_blank">#{object.send("#{method}_file_name")}</a>
          <br />
        }
        if object.send(method).is_a?(ActiveRecord::Base)
          html << hidden_field(method, :value => object.send(method).id)
        end
      end
      name = "#{object.class.base_class.to_s.underscore}"
      html << %{
        <span class="image-upload-droptarget">
        <input id="#{method}_md5" type="hidden" name="#{name}[#{method}_md5]" value="" />
        <input id="#{method}_method" type="hidden" name="#{name}[#{method}_method]" value="" />
        <input id="#{name}_#{method}" name="#{method}" class="image-upload" type="submit" value="Choose File" />
        <span id="#{method}_title">No File Chosen</span>
        </span>
      </p>}
      html.html_safe
    end
  end
end
