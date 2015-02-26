require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/string/inflections'

module Qadmin
  module Configuration

    class Base < ::HashWithIndifferentAccess

      attr_reader :base,
                  :controller_class,
                  :controller_name,
                  :model_class,
                  :model_name,
                  :model_instance_name,
                  :model_collection_name,
                  :model_human_name,
                  :namespace,
                  :parent,
                  :default_scope

      def with_indifferent_access
        self
      end

      def initialize(options = {})
        super
        @base = options.delete(:base)
        @namespace = false
        @parent = false
        @default_scope = false
        populate_model(options)
      end

      def path_prefix(plural = false)
        name = plural ? @model_collection_name : @model_instance_name
        if @namespace.nil?
          name
        else
          "#{@namespace}_#{name}"
        end
      end

      def polymorphic_array(*args)
        args.compact!
        if @parent && args.length < 2
          args.unshift(@parent)
        end
        args.unshift(@namespace) if @namespace
        args
      end

      def form_instance_for(instance)
        i = instance.class != @model_class ? instance.becomes(@model_class) : instance
        polymorphic_array(i)
      end

      def model_column_names
        @columns ||= @model_class.column_names
      rescue
        []
      end

      def inspect
        "#<#{self.class} #{super}>"
      end

      private

      # Turn a set of options into the full options needed for configuration
      def populate_model(properties)
        @controller_class = properties[:controller_class]
        @controller_name = properties[:controller_name] || @controller_class.to_s.demodulize.gsub(/Controller/,'').underscore
        @model_name = properties[:model_name] || @controller_class.to_s.demodulize.gsub(/Controller/,'').singularize
        @model_instance_name = properties[:model_instance_name] || @model_name.underscore
        @model_collection_name = properties[:model_collection_name] || @model_instance_name.pluralize
        @model_human_name = properties[:model_human_name] || @model_instance_name.humanize
        populate_namespace(properties[:namespace])
        @model_class = @model_name.constantize
        self
      end

      def populate_namespace(namespace)
        if match = @controller_class.to_s.match(/\A(.+)::\w+\z/)
          modules = match[1]
          @namespace = modules.underscore unless modules.nil?
        end
        @namespace ||= namespace
        @namespace = @namespace.to_sym unless @namespace.nil?
      end

    end

    module Actions
      class Action < Qadmin::Configuration::Base
        attr_reader :multipart_forms,
                    :controls,
                    :control_links

        def initialize(options = {})
          super
          @multipart_forms = false
          @controls = []
          @control_links = {}
        end

      end

      class Index < Action
        attr_reader :columns,
                    :column_headers,
                    :column_css,
                    :controls,
                    :row_controls,
                    :attribute_handlers

        def initialize(options = {})
          super
          @columns = model_column_names
          @column_headers = {}
          @column_css = {}
          @controls = [:new]
          @row_controls = [:show, :edit, :destroy]
          @attribute_handlers = {}
        end

      end

      class Show < Action

        def initialize(options = {})
          super
          @controls = [:index, :new, :edit, :destroy]
        end

      end

      class New < Action

        def initialize(options = {})
          super
          @controls = [:index]
        end

      end

      class Edit < Action

        def initialize(options = {})
          super
          @controls = [:index, :new, :show, :destroy]
        end

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

      attr_accessor :available_actions
      attr_reader :ports,
                  :multipart_forms,
                  :control_links

      def initialize(options = {})
        super
        @available_actions = options[:available_actions] || ACTIONS.dup
        @ports = false
        @multipart_forms = false
        @control_links = {}
        @actions = {}
        populate_model(options)
      end

      def method_missing(method, *args, &block)
        if match = method.to_s.match(/\Aon\_(\w+)/)
          action = match[1]
          if @available_actions.include?(action.to_sym) && (value = @actions[action]).nil?
            klass = "Qadmin::Configuration::Actions::#{action.to_s.classify}".constantize
            value = klass.new(:controller_class => @controller_class)
            @actions[action] = value
          end
          yield(value) if block_given?
          value
        else
          super
        end
      end

    end

  end
end
