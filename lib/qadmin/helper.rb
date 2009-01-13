module Qadmin  
  module Helper    
    include ::Qadmin::Options
    
    def fieldset(legend = nil, options = {}, &block)
      concat(content_tag_for(:fieldset, options) do
        content_tag(:legend, legend) if legend
        capture(&block)
      end)
    end

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
        :ports      => link_to(image_tag('admin/icon_export.png') + " Import/Export", general_link_attributes.merge(:action => 'ports'))
      }

      control_sets = {
        :index => [:new],
        :new   => [:index],
        :edit  => [:index,:new,:show,:destroy],
        :show  => [:index,:new,:edit,:destroy]
      }

      control_set = (options[:for] ? control_sets[options[:for]] : options[:controls])
      control_set << :ports if options[:ports]
      controls = Array(control_set).collect {|c| control_links[c] }.compact

      html = ""
      html << %{<ul class="admin_controls">}
      controls.each {|control| html << li(control) }
      if block_given?
        html << capture(&block)
        html << %{</ul>}
        concat(html,block.binding)
      else
        html << %{</ul>}
        html
      end
    end
    
    def sortable_column_header(attribute_name, text = nil, options = {})
      link_text = text || attribute_name.to_s.humanize
      return link_text unless model_klass.can_query?
      query_parser = model_restful_query_parser(options)
      query_param = options[:query_param] || :query
      logger.warn 'params:' +  self.params[query_param].inspect
      logger.warn 'parser:' + query_parser.inspect
      sorting_this = query_parser.sort(attribute_name)
      logger.warn "sorting #{attribute_name}:" + sorting_this.inspect
      link_text << " #{image_tag("admin/icon_#{sorting_this.direction.downcase}.gif")}" if sorting_this
      query_parser.set_sort(attribute_name, sorting_this ? sorting_this.next_direction : 'desc')
      link_to link_text, self.params.dup.merge(query_param => query_parser.to_query_hash), :class => 'sortable_column_header'
    end
    
    def model_restful_query_parser(options = {})
      query_param = options[:query_param] || :query
      model_klass.restful_query_parser(params[query_param], options)
    end
        
    def admin_table(collection, options = {})
      html = '<table>'
      html <<	'<tr>'
      attributes = options[:attributes] || model_klass.column_names
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
          if i == 0
            html << %{<td class="first_col">#{link_to(instance.send(attribute), send("#{model_instance_name}_path", instance))}</td>}
          else
            html << %{<td>#{h(instance.send(attribute))}</td>}
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

  end
end