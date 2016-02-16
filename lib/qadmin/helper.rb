module Qadmin
  module Helper

    CONTROL_LINKS = {
      :index      => lambda {|params, obj| link_to(image_tag('qadmin/icon_list.png') + " Back to List", params.merge(:action => 'index')) },
      :new        => lambda {|params, obj| link_to(image_tag('qadmin/icon_new.png') + " New", params.merge(:action => 'new')) },
      :edit       => lambda {|params, obj| link_to(image_tag('qadmin/icon_edit.png') + " Edit", params.merge({:action => 'edit', :id => obj.id})) },
      :show       => lambda {|params, obj| link_to(image_tag('qadmin/icon_show.png') + " View", params.merge({:action => 'show', :id => obj.id})) },
      :destroy    => lambda {|params, obj| link_to(image_tag('qadmin/icon_destroy.png') + " Delete", params.merge({:action => 'destroy', :id => obj.id}), :data => {:confirm => 'Are you sure?'}, :method => :delete) },
      :ports      => lambda {|params, obj| link_to(image_tag('qadmin/icon_export.png') + " Import/Export", params.merge(:action => 'ports')) },
      :export     => lambda {|params, obj| link_to(image_tag('qadmin/icon_export.png') + " Export", params.merge(:action => 'export')) },
      :sort       => lambda {|params, obj| link_to(image_tag('qadmin/icon_sort.png') + " Sort", params.merge({:action => 'sort'})) }
    }.freeze

    def control_links(custom_links = {})
      merged_links = CONTROL_LINKS.merge(custom_links)
      HashWithIndifferentAccess.new(merged_links)
    end

    def admin_controls(name, options = {}, &block)
      return if respond_to?(:overlay?) && overlay?
      assumed_object = self.instance_variable_get "@#{name}"
      controller     = params[:controller] || options[:controller] || name.to_s.tableize
      obj            = options[:object] || assumed_object || nil

      if options[:for]
        action_config = self.qadmin_configuration.send("on_#{options[:for]}")
        options[:controls] ||= action_config.controls
        options[:control_links] ||= action_config.control_links
        options[:parent] ||= (action_config.parent ? instance_variable_get("@#{action_config.parent}") : nil)
        options[:ports] ||= action_config.base.ports
      end

      parent         = options[:parent] || false
      parent_link_params = parent ? {parent.class.to_s.foreign_key => parent.id} : {}
      general_link_params = {:controller => controller}.merge(parent_link_params)

      control_set = (options[:controls] || []).dup
      links = control_links(options[:control_links])
      controls = [control_set].flatten.map { |control| links[control.to_sym] }.compact

      html = ""
      return html if !controls || controls.empty?
      html << %{<ul class="admin_controls">}
      controls.each do |control|
        control_html = if control.respond_to?(:call)
          control.call(params, obj)
        elsif control.is_a?(Hash)
          icon = if control[:icon]
            # if the icon starts with / or http its a url not a name
            image_tag(control[:icon] =~ /^(\/|http)/ ? control[:icon] : "qadmin/icon_#{control[:icon]}.png")
          else
            ""
          end
          link_params = params.merge(control[:params] || {})
          link_params[(control[:member] == true ? :id : control[:member])] = obj.id if control[:member]
          link_to(icon + " " + control[:text], link_params, control[:link_options])
        else
          control
        end
        html << li(control_html)
      end
      if block_given?
        html << capture(&block)
        html << %{</ul>}
        concat(html.html_safe)
      else
        html << %{</ul>}
        html
      end
      html.html_safe
    end

    def sortable_column_header(attribute_name, text = nil, options = {})
      link_text = text || self.qadmin_configuration.on_index.column_headers[attribute_name] || attribute_name.to_s.humanize
      return link_text unless qadmin_configuration.model_klass.can_query?
      query_parser = model_restful_query_parser(options)
      if qadmin_configuration.model_klass.respond_to?(:reflections) and
        association = qadmin_configuration.model_klass.reflections[attribute_name.to_sym]
        attribute_name = association.association_foreign_key unless association.macro == :composed_of
      end
      query_param = options[:query_param] || :query
      attribute_name = "#{qadmin_configuration.model_klass.table_name}.#{attribute_name}"
      sorting_this = query_parser.sort(attribute_name)
      link_text += " #{image_tag("qadmin/icon_#{sorting_this.direction.downcase}.gif")}" if sorting_this
      query_parser.clear_default_sort!
      query_parser.set_sort(attribute_name, sorting_this ? sorting_this.next_direction : 'desc')
      link_to link_text.html_safe, self.params.dup.merge(query_param => query_parser.to_query_hash, :anchor => (options[:id] || self.qadmin_configuration.model_collection_name)), :class => 'sortable_column_header'
    end

    def model_restful_query_parser(options = {})
      query_param = options[:query_param] || :query
      qadmin_configuration.model_klass.restful_query_parser(params[query_param], options)
    end

    def row_control_links(more_links = {})
      {
        :destroy    => lambda { |params, obj| link_to(image_tag("qadmin/icon_destroy.png"), params.merge({:action => 'destroy', :id => obj.id}), :data => {:confirm => 'Are you sure?'}, :method => :delete)},
        :edit       => lambda { |params, obj| link_to(image_tag('qadmin/icon_edit.png'), params.merge({:action => 'edit',    :id => obj.id})) },
        :show       => lambda { |params, obj| link_to(image_tag('qadmin/icon_show.png'), params.merge({:action => 'show',    :id => obj.id})) },
      }.merge(more_links || {})
    end

    def admin_table(collection, options = {})
      config = self.qadmin_configuration.on_index || {}

      controller  = options[:controller] || params[:controller] || config.controller_name
      attributes  = options[:attributes] || options[:columns] || config.columns
      parent      = options[:parent] || false

      parent_link_params = parent ? {parent.class.to_s.foreign_key => parent.id} : {}
      general_link_params = {:controller => controller}.merge(parent_link_params)

      row_control_sets = {
        :index => [:show,:edit,:destroy]
      }

      row_control_set = (options[:row_controls] || config.row_controls).dup
      row_control_set.unshift(row_control_sets[options[:for]]) if row_control_set.empty? && options[:for]
      row_control_set = [row_control_set].flatten
      row_controls = row_control_set.collect{|c| row_control_links(options[:row_control_links])[c] }.compact

      logger.debug "row_controls: #{row_controls.inspect}"

      attribute_handlers = HashWithIndifferentAccess.new({
        :string  =>  lambda {|h, v, i, c|
          auto_link(h(v))
        },
        :boolean =>  lambda {|h, v, i, c| yes?(v) },
        :false_class => lambda {|h, v, i, c| 'No' },
        :true_class => lambda {|h, v, i, c| 'Yes' },
        :text    =>  lambda {|h, v, i, c|
          h.truncate(v, :length => 30, :omission => "... #{h.link_to('More', h.send("#{qadmin_configuration.path_prefix}_path", i))}")
         },
        :reflection => lambda {|h, v, i, c| h.link_to(v.to_s, v) },
        :hash => lambda {|h, v, i, c| v.inspect },
        :array => lambda {|h, v, i, c| v.inspect },
        :datetime => lambda {|h, v, i, c| v.in_time_zone("Eastern Time (US & Canada)") }
      })
      attribute_handlers.merge!(options[:attribute_handlers] || config.attribute_handlers)

      model_column_types = HashWithIndifferentAccess.new

      attributes.each do |attribute_name|
        if column = config.model_klass.columns.detect {|c| c.name.to_s == attribute_name.to_s }
          if serialized_klass = config.model_klass.serialized_attributes[attribute_name]
            column = serialized_klass.to_s.downcase.to_sym
          else
            column = column.type
          end
        elsif !column && reflection = config.model_klass.reflections[attribute_name] && respond_to?("#{attribute_name}_path")
          column = :reflection
        end
        model_column_types[attribute_name] = column if column
      end

      html = "<table id=\"#{options[:id] || config.model_collection_name}\">"
      html <<  '<thead><tr>'
      attributes.each_with_index do |attribute, i|
        css = (config.column_css[attribute] ? config.column_css[attribute] : (i == 0 ? 'first_col' : ''))
        html << %{<th class="#{css}">}
        html << sortable_column_header(attribute)
        html << '</th>'
      end
      row_control_set.each do |action|
        html << %{<th>#{action.to_s.humanize}</th>}
      end
      html << '</tr></thead><tbody>'
      collection.each do |instance|
        next if !instance
        html << %{<tr id="#{dom_id(instance)}" #{alt_rows}>}
        attributes.each_with_index do |attribute, i|
          begin
            raw_value = instance.send(attribute)
            handler   = attribute_handlers[attribute]
            handler   ||= attribute_handlers[model_column_types[attribute] || raw_value.class.to_s.demodulize.underscore]
            value = if handler
              handler.call(self, raw_value, instance, config)
            else
              if i == 0
                link_to(raw_value, send("#{qadmin_configuration.path_prefix}_path", instance))
              else
                h(raw_value)
              end
            end
          rescue => e
            logger.warn e
            value = ""
          end
          css = (config.column_css[attribute] ? config.column_css[attribute] : (i == 0 ? 'first_col' : ''))
          html << %{<td class="#{css}">#{value}</td>}
        end
        row_controls.each do |row_control|
          row_control_html = row_control.respond_to?(:call) ? row_control.call(general_link_params, instance) : row_control
          html << td(row_control_html)
        end
        html << '</tr>'
      end
      html << '</tbody></table>'
      html.html_safe
    end

    def admin_pagination(collection)
      render(partial_for_section('pagination'), :collection => collection).html_safe
    end

    def alt_rows
      %{class="#{cycle('alt', '')}"}
    end

    def yes?(boolean)
      boolean ? 'Yes' : 'No'
    end

    def li(content, *args)
      content_tag :li, content, args
    end

    def td(content, *args)
      content_tag :td, content, args
    end

    def simple_admin_menu(*controllers)
      html = %{<div id="menu">
        <ul>}
        simple_menu(*controllers) do |name,controller|
          li(link_to(name, :controller => controller))
        end
      html <<  %{</ul>
        <div class="clear"></div>
      </div>}
      html.html_safe
    end

    def simple_menu(*controllers, &block)
      return unless controllers
      html = ""
      controllers.each do |controller_pair|
        if controller_pair.is_a? Array
          name, controller = controller_pair[0], controller_pair[1]
        else
          name, controller = controller_pair, controller_pair
        end
        html << yield(name.to_s,controller)
      end
      html.html_safe
    end

    def like_current_page?(options)
      case options
      when Hash
        url_string = Regexp.new(CGI.escapeHTML(url_for(options)))
      when String
        url_string = Regexp.new(options)
      when Regexp
        url_string = options
      end
      request = controller.request
      request.url =~ url_string
    end

    def fieldset(legend = nil, options = {}, &block)
      html = ''
      html << content_tag(:legend, legend) if legend
      html << capture(&block)
      concat content_tag(:fieldset, html, options)
    end

    def labeled_show_column(object, method, options = {})
      html = %{<p>}
      html << label(object, method, options[:label] || nil)
      raw_value = options.has_key?(:value) ? options[:value] : object.send(method)
      show_value = if raw_value.blank? && raw_value != false
        '<em>blank</em>'
      elsif raw_value.is_a?(Array) || raw_value.is_a?(Hash)
        h(raw_value.inspect)
      elsif with_value = options.delete(:with_value) and with_value.is_a?(Proc)
        h(with_value.call(raw_value))
      elsif raw_value.is_a?(ActiveRecord::Base)
        link = if options[:path_helper]
          send options[:path_helper], raw_value
        else
          [options[:namespace], raw_value].compact
        end
        link_to(h(raw_value.to_s), link)
      else
        raw_value
      end
      html << %{<span class="show_value">#{show_value}</span>}
      html << %{</p>}
      html.html_safe
    end

    def labeled_show_paperclip_attachment(object, method, options = {})
      value = if object.send("#{method}?")
        # has attachment
        if object.send("#{method}_content_type") =~ /image/
          size = number_to_human_size(object.send("#{method}_file_size"))
          image_tag(object.send(method).url, {:title => "Size: #{size}"}.merge(options[:img_options] || {}))
        else
          link_to(object.send("#{method}_file_name"), object.send(method).url)
        end
      else
        nil
      end
      labeled_show_column(object, method, options.merge(:value => value))
    end
  end


end
