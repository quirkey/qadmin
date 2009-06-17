module Qadmin  
  module Helper    

    def admin_controls(name, options = {}, &block)
      return if respond_to?(:overlay?) && overlay?
      controller     = options[:controller] || name.to_s.tableize
      assumed_object = self.instance_variable_get "@#{name}"
      obj            = options[:object] || assumed_object || nil
      parent         = options[:parent] || false

      parent_link_attributes = parent ? {parent.class.to_s.foreign_key => parent.id} : {}
      general_link_attributes = {:controller => controller}.merge(parent_link_attributes)

      control_links = {
        :index      => link_to(image_tag('admin/icon_list.png') + " Back to List", general_link_attributes.merge(:action => 'index')),
        :new        => link_to(image_tag('admin/icon_new.png') + " New", general_link_attributes.merge(:action => 'new')),
        :edit       => link_to(image_tag('admin/icon_edit.png') + " Edit", general_link_attributes.merge(:action => 'edit', :id => obj)),
        :show       => link_to(image_tag('admin/icon_show.png') + " View", general_link_attributes.merge(:action => 'show', :id => obj)),
        :destroy    => link_to(image_tag('admin/icon_destroy.png') + " Delete", general_link_attributes.merge(:action => 'destroy', :id => obj), :confirm => 'Are you sure?', :method => :delete),
        :ports      => link_to(image_tag('admin/icon_export.png') + " Import/Export", general_link_attributes.merge(:action => 'ports')),
        :export     => link_to(image_tag('admin/icon_export.png') + " Export", general_link_attributes.merge(:action => 'export')),
        :preview    => link_to(image_tag('admin/icon_find.png') + " Preview", general_link_attributes.merge(:action => 'preview', :id => obj))
      }

      control_sets = {
        :index => [:new],
        :new   => [:index],
        :edit  => [:index,:new,:show,:destroy],
        :show  => [:index,:new,:edit,:destroy]
      }
      
      control_set = (options[:controls] || []).dup
      control_set.unshift(control_sets[options[:for]]) if options[:for]
      control_set << :ports if options[:ports]
      controls = [control_set].flatten.collect {|c| control_links[c] }.compact

      html = ""
      html << %{<ul class="admin_controls">}
      controls.each {|control| html << li(control) }
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
      link_text = text || self.qadmin_configuration.column_headers[attribute_name] || attribute_name.to_s.humanize
      return link_text unless qadmin_configuration.model_klass.can_query?
      query_parser = model_restful_query_parser(options)
      query_param = options[:query_param] || :query
      logger.warn 'params:' +  self.params[query_param].inspect
      logger.warn 'parser:' + query_parser.inspect
      sorting_this = query_parser.sort(attribute_name)
      logger.warn "sorting #{attribute_name}:" + sorting_this.inspect
      link_text << " #{image_tag("admin/icon_#{sorting_this.direction.downcase}.gif")}" if sorting_this
      query_parser.clear_default_sort!
      query_parser.set_sort(attribute_name, sorting_this ? sorting_this.next_direction : 'desc')
      link_to link_text, self.params.dup.merge(query_param => query_parser.to_query_hash, :anchor => (options[:id] || self.qadmin_configuration.model_collection_name)), :class => 'sortable_column_header'
    end
    
    def model_restful_query_parser(options = {})
      query_param = options[:query_param] || :query
      qadmin_configuration.model_klass.restful_query_parser(params[query_param], options)
    end
        
    def admin_table(collection, options = {})
      html = "<table id=\"#{options[:id] || self.qadmin_configuration.model_collection_name}\">"
      html <<	'<tr>'
      attributes = options[:attributes] || self.qadmin_configuration.display_columns
      model_column_types = HashWithIndifferentAccess.new
      attributes.each do |attribute_name|
        if column = self.qadmin_configuration.model_klass.columns.detect {|c| c.name == attribute_name.to_s }
          column = column.type
        elsif !column && reflection = self.qadmin_configuration.model_klass.reflections[attribute_name]
          column = :reflection
        end
        model_column_types[attribute_name] = column if column
      end
      attributes.each_with_index do |attribute, i|
        html << (i == 0 ? '<th class="first_col">' : '<th>')
        html << sortable_column_header(attribute)
        html << '</th>'
      end
      html << %{
        <th>View</th>
        <th>Edit</th>
        <th>Delete</th>
        </tr>
      }
      collection.each do |instance|
        html << %{<tr id="#{dom_id(instance)}" #{alt_rows}>}
        attributes.each_with_index do |attribute, i|
          raw_value = instance.send(attribute)
          value = case model_column_types[attribute]
          when :boolean
            yes?(raw_value)
          when :text
            truncate(raw_value, :length => 30, :omission => ". . . #{link_to('More', send("#{model_instance_name}_path", instance))}")
          when :reflection # association
            link_to(raw_value.to_s, raw_value)
          else
            h(raw_value)
          end
          if i == 0
            html << %{<td class="first_col">#{link_to(value, send("#{model_instance_name}_path", instance))}</td>}
          else
            html << %{<td>#{value}</td>}
          end
        end
        html << %{<td>#{link_to(image_tag('admin/icon_show.png'), send("#{model_instance_name}_path", instance))}</td>}
        html << %{<td>#{link_to(image_tag('admin/icon_edit.png'), send("edit_#{model_instance_name}_path", instance))}</td>}
        html << %{<td>#{link_to(image_tag('admin/icon_destroy.png'), send("#{model_instance_name}_path", instance), :confirm => 'Are you sure?', :method => :delete)}</td>}
        html << '</tr>'
      end
      html << '</table>'
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
        html << yield(name,controller)
      end
      html
    end
    
    def fieldset(legend = nil, options = {}, &block)
      concat(content_tag(:fieldset, options) do
        html = ''
        html << content_tag(:legend, legend) if legend
        html << capture(&block)
        html
      end)
    end
  end
end