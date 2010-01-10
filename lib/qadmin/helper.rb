module Qadmin
  module Helper

    def control_links(more_links={})
      {
        :index      => lambda { link_to(image_tag('qadmin/icon_list.png') + " Back to List", general_link_attributes.merge(:action => 'index')) },
        :new        => lambda { link_to(image_tag('qadmin/icon_new.png') + " New", general_link_attributes.merge(:action => 'new')) },
        :edit       => lambda { link_to(image_tag('qadmin/icon_edit.png') + " Edit", general_link_attributes.merge({:action => 'edit', :id => obj.id})) },
        :show       => lambda { link_to(image_tag('qadmin/icon_show.png') + " View", general_link_attributes.merge({:action => 'show', :id => obj.id})) },
        :destroy    => lambda { link_to(image_tag('qadmin/icon_destroy.png') + " Delete", general_link_attributes.merge({:action => 'destroy', :id => obj.id}), :confirm => 'Are you sure?', :method => :delete) },
        :ports      => lambda { link_to(image_tag('qadmin/icon_export.png') + " Import/Export", general_link_attributes.merge(:action => 'ports')) },
        :export     => lambda { link_to(image_tag('qadmin/icon_export.png') + " Export", general_link_attributes.merge(:action => 'export')) },
        :preview    => lambda { link_to(image_tag('qadmin/icon_preview.png') + " Preview", general_link_attributes.merge({:action => 'preview', :id => obj.id})) },
        :sort       => lambda { link_to(image_tag('qadmin/icon_sort.png') + " Sort", general_link_attributes.merge({:action => 'sort'})) }
      }.merge(more_links)
    end

    def admin_controls(name, options = {}, &block)
      return if respond_to?(:overlay?) && overlay?
      controller     = params[:controller] || options[:controller] || name.to_s.tableize
      assumed_object = self.instance_variable_get "@#{name}"
      logger.debug "= admin_controls: name : #{name}, assumed_object: #{assumed_object.inspect}"
      obj            = options[:object] || assumed_object || nil
      parent         = options[:parent] || false

      parent_link_attributes = parent ? {parent.class.to_s.foreign_key => parent.id} : {}
      general_link_attributes = {:controller => controller}.merge(parent_link_attributes)

      control_sets = {
        :index => [:new],
        :new   => [:index],
        :edit  => [:index,:new,:show,:destroy],
        :show  => [:index,:new,:edit,:destroy]
      }

      control_set = (options[:controls] || []).dup
      control_set.unshift(control_sets[options[:for]]) if options[:for]
      control_set << :ports if options[:ports]
      controls = [control_set].flatten.collect {|control| control_links(options[:control_links])[control] }.compact

      html = ""
      html << %{<ul class="admin_controls">}
      controls.each do |control|
        control_html = control.respond_to?(:call) ? control.call : control
        html << li(control_html)
      end
      if block_given?
        html << capture(&block)
        html << %{</ul>}
        concat(html)
      else
        html << %{</ul>}
        html
      end
    end

    def sortable_column_header(attribute_name, text = nil, options = {})
      link_text = text || self.qadmin_configuration.on_index.column_headers[attribute_name] || attribute_name.to_s.humanize
      return link_text unless qadmin_configuration.model_klass.can_query?
      query_parser = model_restful_query_parser(options)
      if qadmin_configuration.model_klass.respond_to?(:reflections) and
        association = qadmin_configuration.model_klass.reflections[attribute_name.to_sym]
        attribute_name = association.association_foreign_key
      end
      query_param = options[:query_param] || :query
      logger.debug 'params:' +  self.params[query_param].inspect
      logger.debug 'parser:' + query_parser.inspect
      attribute_name = "#{qadmin_configuration.model_klass.table_name}.#{attribute_name}"
      sorting_this = query_parser.sort(attribute_name)
      logger.debug "sorting #{attribute_name}:" + sorting_this.inspect
      link_text << " #{image_tag("qadmin/icon_#{sorting_this.direction.downcase}.gif")}" if sorting_this
      query_parser.clear_default_sort!
      query_parser.set_sort(attribute_name, sorting_this ? sorting_this.next_direction : 'desc')
      link_to link_text, self.params.dup.merge(query_param => query_parser.to_query_hash, :anchor => (options[:id] || self.qadmin_configuration.model_collection_name)), :class => 'sortable_column_header'
    end

    def model_restful_query_parser(options = {})
      query_param = options[:query_param] || :query
      qadmin_configuration.model_klass.restful_query_parser(params[query_param], options)
    end

    def row_control_links(more_links={})
      {
        :destroy    => lambda { link_to(image_tag("qadmin/icon_destroy.png"), general_link_attributes.merge({:action => 'destroy', :id => obj.id}), :confirm 'Are you sure?', :method => :delete)}},
        :edit       => lambda { link_to(image_tag('qadmin/icon_edit.png'),    general_link_attributes.merge({:action => 'edit',    :id => obj.id})) },
        :show       => lambda { link_to(image_tag('qadmin/icon_show.png'),    general_link_attributes.merge({:action => 'show',    :id => obj.id})) },
      }.merge(more_links)
    end

    def admin_table(collection, options = {})
      config = self.qadmin_configuration.on_index
      controller  = prams[:controller]   || options[:controller] || config.controller_name
      attributes  = options[:attributes] || config.columns

      row_control_sets = {
        :index => [:show,:edit,:destroy]
      }

      row_control_set = options[:row_controls] || config.row_controls
      row_control_set.unshift(row_control_sets[options[:for]]) if options[:for]
      row_controls = [row_control_set].flatten.collect{|c| row_control_links(options[:row_control_links])[row_control] }.compact

      parent_link_attributes = parent ? {parent.class.to_s.foreign_key => parent.id} : {}
      general_link_attributes = {:controller => controller}.merge(parent_link_attributes)

      attribute_handlers = HashWithIndifferentAccess.new({
        :string  =>  lambda {|h, v, i, c|
          auto_link(h(v))
        },
        :boolean =>  lambda {|h, v, i, c| yes?(v) },
        :false_class => lambda {|h, v, i, c| 'No' },
        :true_class => lambda {|h, v, i, c| 'Yes' },
        :text    =>  lambda {|h, v, i, c|
          h.truncate(v, :length => 30, :omission => "... #{h.link_to('More', h.send("#{c.model_instance_name}_path", i))}")
         },
        :reflection => lambda {|h, v, i, c| h.link_to(v.to_s, v) },
        :hash => lambda {|h, v, i, c| v.inspect },
        :array => lambda {|h, v, i, c| v.inspect }
      })
      attribute_handlers.merge!(options[:attribute_handlers] || config.attribute_handlers)
      logger.debug "attribute_handlers #{attribute_handlers.inspect}"
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
      html <<	'<thead><tr>'
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
        html << %{<tr id="#{dom_id(instance)}" #{alt_rows}>}
        attributes.each_with_index do |attribute, i|
          raw_value = instance.send(attribute)
          handler   = attribute_handlers[model_column_types[attribute] || raw_value.class.to_s.demodulize.underscore]
          value = if handler
            handler.call(self, raw_value, instance, config)
          else
            if i == 0
              link_to(raw_value, send("#{qadmin_configuration.path_prefix}_path", instance))
            else
              h(raw_value)
            end
          end
          css = (config.column_css[attribute] ? config.column_css[attribute] : (i == 0 ? 'first_col' : ''))
          html << %{<td class="#{css}">#{value}</td>}
        end
        row_control_links.each do |row_control|
          row_control_html = row_control.respond_to?(:call) ? row_control.call : action
          html << td(row_control_html)
        end
        html << '</tr>'
      end
      html << '</tbody></table>'
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
    	html <<	%{</ul>
    		<div class="clear"></div>
    	</div>}
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
      html
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
      request = @controller.request
      request.request_uri =~ url_string
    end

    def fieldset(legend = nil, options = {}, &block)
      concat(content_tag(:fieldset, options) do
        html = ''
        html << content_tag(:legend, legend) if legend
        html << capture(&block)
        html
      end)
    end

    def labeled_show_column(object, method, options = {})
      html = %{<p>}
      html << label(object, method, options[:label] || nil)
      show_value = options.has_key?(:value) ? options[:value] : object.send(method)
      show_value = '<em>blank</em>' if show_value.blank?
      html << %{<span class="show_value">#{show_value}</span>}
      html << %{</p>}
      html
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