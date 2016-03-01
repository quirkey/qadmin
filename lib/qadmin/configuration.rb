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

    module HashAccessors

      attr_accessor :hash_accessors

      def hash_accessor(name, options = {})
        @hash_accessors ||= []
        @hash_accessors << name unless @hash_accessors.include?(name)
        options[:default] ||= nil
        coerce = options[:coerce] ? ".#{options[:coerce]}" : ""
        module_eval <<-EOT
          def #{name}
            value = (self[:#{name}] ? self[:#{name}]#{coerce} : self[:#{name}]) ||
                      (base && base.respond_to?(:#{name}) ? base.send(:#{name}) : #{options[:default].inspect})
            yield(value) if block_given?
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

    end

    module Base

      def with_indifferent_access
        self
      end

      def self.included(base)
        base.send(:extend, HashAccessors)
        base.send(:attr_accessor, :base)
        base.send(:hash_accessor, :controller_klass)
        base.send(:hash_accessor, :controller_name)
        base.send(:hash_accessor, :model_name)
        base.send(:hash_accessor, :model_instance_name)
        base.send(:hash_accessor, :model_collection_name)
        base.send(:hash_accessor, :model_human_name)
        base.send(:hash_accessor, :namespace, :default => false)
        base.send(:hash_accessor, :parent, :default => false)
        base.send(:hash_accessor, :default_scope, :default => false)
      end

      def initialize(options = {})
        super
        populate_accessors if self.class.hash_accessors
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

      private

      def populate_accessors
        self.class.hash_accessors.select { |a| a !~ /^on_/ }.each do |accessor|
          send(accessor)
        end
      end

    end

    module Actions
      module Action

        include Qadmin::Configuration::Base

        def self.included(base)
          base.send(:include, Qadmin::Configuration::Base)
          base.send(:extend, HashAccessors)
          base.send(:hash_accessor, :multipart_forms, :default => false)
          base.send(:hash_accessor, :controls, :default => [])
          base.send(:hash_accessor, :control_links, :default => {})
        end

      end

      class Index < ::HashWithIndifferentAccess

        include Action

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

      class Show < ::HashWithIndifferentAccess

        include Action

        hash_accessor :controls, :default => [:index, :new, :edit, :destroy]
      end

      class New < ::HashWithIndifferentAccess

        include Action

        hash_accessor :controls, :default => [:index]
      end

      class Edit < ::HashWithIndifferentAccess

        include Action

        hash_accessor :controls, :default => [:index, :new, :show, :destroy]
      end

      class Create < ::HashWithIndifferentAccess

        include Action

      end

      class Update < ::HashWithIndifferentAccess

        include Action

      end

      class Destroy < ::HashWithIndifferentAccess

        include Action

      end

    end

    class Resource < ::HashWithIndifferentAccess
      include Qadmin::Configuration::Base

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
            key = "on_#{action}"
            if self[key].nil?
              action_class_name = "Qadmin::Configuration::Actions::#{action.to_s.classify}"
              properties = self.clean_self.merge(:base => self)
              self[key] = action_class_name.constantize.new(properties)
            end
            yield(self[key]) if block_given?
            self[key]
          end
        EOV
      end

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
