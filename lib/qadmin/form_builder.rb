module Qadmin
  class FormBuilder < ::ActionView::Helpers::FormBuilder
    include Qadmin::Assets::FormBuilder
    
    def content_form(form_name, options = {})
      locals = options.reverse_merge({:content_type => object_name, :content => object, :f => self, :options => options})
      @template.render(:partial => "content_forms/#{form_name}_form", :locals => locals)
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