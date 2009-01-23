module Qadmin
  class OptionSet < Array

    def initialize(*args)
      first = args.shift
      if first.is_a?(Array)
        self.default = first 
        options = args.shift
      else
        options = first
      end
      if options.is_a?(Hash)
        options.each do |option, value|
          self.send("#{option}=", value)
        end
      end
    end
    
    def current
      [self].flatten.dup
    end
    
    [:exclude, :only, :default].each do |meth|
      class_eval <<-EOT
      def #{meth}
        @#{meth} ||= []
      end
      
      def #{meth}=(#{meth})
        @#{meth} = [#{meth}].flatten if #{meth}
        reset_current
      end
      EOT
    end
    alias_method :except, :exclude
    alias_method :except=, :exclude=
    
    protected
    def reset_current
      new_current = if !only.empty?
          only
        else
          default - exclude
        end
      self.replace(new_current)
    end
  end
end