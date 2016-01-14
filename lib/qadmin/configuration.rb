module Qadmin
  module Configuration

    class Base < ::HashWithIndifferentAccess

      attr_accessor :base

      def with_indifferent_access
        self
      end

      def self.hash_accessor(name, options = {})
        options[:default] ||= nil
        coerce = options[:coerce] ? ".#{options[:coerce]}" : ""
        module_eval <<-EOT
          def #{name}
            value = (self[:#{name}] ? self[:#{name}]#{coerce} : self[:#{name}]) ||
                      (base && base.respond_to?(:#{name}) ? base.send(:#{name}) : #{options[:default].inspect})
            yield value if block_given?
            value
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
      hash_accessor :controller_name
      hash_accessor :model_name
      hash_accessor :model_instance_name
      hash_accessor :model_collection_name
      hash_accessor :model_human_name
      hash_accessor :namespace, :default => false
      hash_accessor :parent, :default => false
      hash_accessor :default_scope, :default => false

      def initialize(options = {})
        super
        @base = options.delete(:base)
        extract_model_from_options(options)
      end

      def model_klass
        self.model_name.constantize
      end

      def path_prefix(plural = false)
        name = plural ? model_collection_name : model_instance_name
        if namespace
          "#{namespace}_#{name}"
        else
          name
        end
      end

      def form_instance_for(instance)
        if parent
          [parent, instance]
        elsif namespace
          [namespace, instance]
        else
          instance
        end
      end

      def model_column_names
        model_klass.column_names
      rescue
        []
      end

      def inspect
        "#<#{self.class} #{super}>"
      end

      protected
      def extract_model_from_options(options = {})
        self.controller_klass      = options[:controller_klass]
        self.controller_name       = options[:controller_name] || controller_klass.to_s.demodulize.gsub(/Controller/,'').underscore
        self.model_name            = options[:model_name] || controller_klass.to_s.demodulize.gsub(/Controller/,'').singularize
        self.model_instance_name   = options[:model_instance_name] || model_name.underscore
        self.model_collection_name = options[:model_collection_name] || model_instance_name.pluralize
        self.model_human_name      = options[:model_human_name] || model_instance_name.humanize

        possible_namespace = controller_klass.to_s.underscore.split('/')[0]
        self.namespace = options[:namespace] || (possible_namespace =~ /controller/) ? nil : possible_namespace.to_sym
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
        hash_accessor :row_controls, :default => [:show, :edit, :destroy]
        hash_accessor :attribute_handlers, :default => {}

        def initialize(options = {})
          super
          self.columns = model_column_names
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

      hash_accessor :available_actions, :default => ACTIONS.dup
      hash_accessor :ports, :default => false

      hash_accessor :multipart_forms, :default => false
      hash_accessor :controls, :default => []

      ACTIONS.each do |action|
        hash_accessor "on_#{action}"

        module_eval <<-EOV
          def on_#{action}
            value = self["on_#{action}"] ||= "Qadmin::Configuration::Actions::#{action.to_s.classify}".constantize.new(self.dup.merge(:base => self))
            yield value if block_given?
            value
          end
        EOV
      end

    end

  end
end
