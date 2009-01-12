module Qadmin
  module Options
    
    def extract_model_from_options(options = {})
      self.model_name            = options[:model_name] || self.to_s.demodulize.gsub(/Controller/,'').singularize
      self.model_instance_name   = options[:model_instance_name] || model_name.underscore
      self.model_collection_name = options[:model_collection_name] || model_instance_name.pluralize    
      self.model_human_name      = options[:model_human_name] || model_instance_name.humanize
    end
    
    def model_klass
      self.model_name.constantize
    end
  end
end