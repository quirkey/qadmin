module Qadmin
  class FormBuilder < ActionView::Helpers::FormBuilder
    include Qadmin::Assets::FormBuilder
    
    def content_form(form_name, options = {})
      locals = options.reverse_merge({:content_type => object_name, :content => object, :f => self, :options => options})
      @template.render(:partial => "content_forms/#{form_name}_form", :locals => locals)
    end
    
  end
end