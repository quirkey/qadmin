module Qadmin
  module Configuration

    # Turn a set of options into the full options needed for configuration
    def self.extract_model_from_options(options = {})
      output = {}
      output[:controller_klass]      = options[:controller_klass]
      output[:controller_name]       = options[:controller_name] || Util.model_name_from_controller(output[:controller_klass]).pluralize.underscore
      output[:model_name]            = options[:model_class].name unless options[:model_class].nil?
      output[:model_name]            ||= options[:model_name] ||  Util.model_name_from_controller(output[:controller_klass])
      output[:model_instance_name]   = options[:model_instance_name] || output[:model_name].underscore
      output[:model_collection_name] = options[:model_collection_name] || output[:model_instance_name].pluralize
      output[:model_human_name]      = options[:model_human_name] || output[:model_instance_name].humanize

      possible_namespace = output[:controller_klass].to_s.underscore.split('/')[0]
      output[:namespace] = options[:namespace] || (possible_namespace =~ /controller/) ? nil : possible_namespace.to_sym
      output
    end

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
      end

      def model_klass
        @model_klass ||= self.model_name.constantize
      end

      def path_prefix(plural = false)
        name = plural ? model_collection_name : model_instance_name
        if namespace
          "#{namespace}_#{name}"
        else
          name
        end
      end

      def polymorphic_array(*args)
        args.compact!
        if parent && args.length < 2
          args.unshift parent
        end
        if namespace
          args.unshift namespace
        end
        args
      end

      def form_instance_for(instance)
        i = instance.class != model_klass ? instance.becomes(model_klass) : instance
        polymorphic_array(i)
      end

      def model_column_names
        @columns ||= model_klass.respond_to?(:column_names) ? model_klass.column_names : []
      end

      def inspect
        "#<#{self.class} #{super}>"
      end

    end

    module Actions
      class Action < Qadmin::Configuration::Base
        hash_accessor :multipart_forms, :default => false
        hash_accessor :controls, :default => []
        hash_accessor :control_links, :default => {}
      end

      class Index < Action
        hash_accessor :columns, :default => []
        hash_accessor :column_headers, :default => {}
        hash_accessor :column_css, :default => {}
        hash_accessor :controls, :default => [:new]
        hash_accessor :row_controls, :default => [:show, :edit, :destroy]
        hash_accessor :attribute_handlers, :default => {}

        def initialize(options = {})
          super
          @columns = model_column_names
        end

      end

      class Show < Action
        hash_accessor :controls, :default => [:index, :new, :edit, :destroy]
      end

      class New < Action
        hash_accessor :controls, :default => [:index]
      end

      class Edit < Action
        hash_accessor :controls, :default => [:index, :new, :show, :destroy]
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
      hash_accessor :control_links, :default => {}

      def initialize(options = {})
        super
        update(Qadmin::Configuration.extract_model_from_options(options))
      end

      ACTIONS.each do |action|
        hash_accessor "on_#{action}"

        module_eval <<-EOV
          def on_#{action}
            value = self["on_#{action}"] ||= "Qadmin::Configuration::Actions::#{action.to_s.classify}".constantize.new(self.clean_self.merge(:base => self))
            yield value if block_given?
            value
          end
        EOV
      end

      private

      # We need to provide just the "own" properties for the other actions to inherit
      # so that its not a crazy self referential mess
      def clean_self
        c = {}
        self.each {|k, v| c[k] = v if k !~ /^on_/ }
        c
      end
      
    end

  end
end
