module Qadmin
  module Configuration
    
    class Base < ::HashWithIndifferentAccess
      
      def with_indifferent_access
        self
      end
      
      def self.hash_accessor(name, options = {})
        options[:default] ||= nil 
        coerce = options[:coerce] ? ".#{options[:coerce]}" : ""
        module_eval <<-EOT
          def #{name}
            (self[:#{name}] ? self[:#{name}]#{coerce} : self[:#{name}]) || #{options[:default].inspect}
          end

          def #{name}=(value)
            self[:#{name}] = value
          end

          def #{name}?
            !!self[:#{name}]
          end
        EOT
      end
      
      hash_accessor :controller_klass
      hash_accessor :model_name
      hash_accessor :model_instance_name
      hash_accessor :model_collection_name
      hash_accessor :model_human_name
      hash_accessor :default_scope, :default => false
      
      def initialize(options = {})
        super
        extract_model_from_options(options)
      end

      def model_klass
        self.model_name.constantize
      end

      protected
      def extract_model_from_options(options = {})
        self.controller_klass      = options[:controller_klass]
        self.model_name            = options[:model_name] || controller_klass.to_s.demodulize.gsub(/Controller/,'').singularize
        self.model_instance_name   = options[:model_instance_name] || model_name.underscore
        self.model_collection_name = options[:model_collection_name] || model_instance_name.pluralize    
        self.model_human_name      = options[:model_human_name] || model_instance_name.humanize
      end

      def model_column_names
        model_klass.column_names
      rescue
        []
      end
    end

    module Actions
      class Action < Qadmin::Configuration::Base
        hash_accessor :multipart_forms, :default => false
        hash_accessor :controls, :default => []
        
      end
      
      class Index < Action
        hash_accessor :columns, :default => []
        hash_accessor :column_headers, :default => {}
        hash_accessor :column_css, :default => {}
        
        def initialize(options = {})
          super
          self.columns ||= model_column_names
        end
      end

      class Show < Action

      end

      class New < Action

      end

      class Edit < Action

      end

      class Create < Action

      end

      class Update < Action

      end

      class Destroy < Action

      end
      
    end

    class Resource < Base
      
      ACTIONS = [:index, :show, :new, :create, :edit, :update, :destroy].freeze
      
      hash_accessor :available_actions, :default => ACTIONS
      hash_accessor :ports, :default => false
      
      hash_accessor :multipart_forms, :default => false
      hash_accessor :controls, :default => []
      
      hash_accessor :on_index
      hash_accessor :on_show
      hash_accessor :on_new
      hash_accessor :on_create
      hash_accessor :on_edit
      hash_accessor :on_update
      hash_accessor :on_destroy
      
      def initialize(options = {})
        super
        ACTIONS.each do |action|
          self["on_#{action}"] = "Qadmin::Configuration::Actions::#{action.to_s.classify}".constantize.new(self.dup)
        end
      end
      
    end

  end
end