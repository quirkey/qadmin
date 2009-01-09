module Qadmin
  module Helper
    
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

    def alt_rows
      %{class="#{cycle('alt', '')}"}
    end

  end
end