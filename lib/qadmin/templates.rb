module Qadmin
  module Templates

    def self.included(klass)
      if klass.respond_to?(:helper_method)
        klass.module_eval do
          helper_method :template_for_section, :partial_for_section
        end
      end
    end

    protected
    def render_template_for_section(action = nil, options = {})
      action ||= action_name
      rendered = render(template_for_section(action), options)
      rendered.respond_to?(:map) ? rendered.map(&:html_safe) : rendered.html_safe
    end

    def template_for_section(template_name, file_name = nil, options = {})
      file_name ||= template_name
      file_name += ".html" if file_name !~ /\.[a-z]+$/
      section_specific_template?(file_name, options) ? section_specific_template(template_name, options) : default_section_template(template_name, options)
    end

    def partial_for_section(partial_name, options = {})
      template_for_section(partial_name, "_#{partial_name}", options)
    end

    def section_specific_template?(template_name, options = {})
      template_exists?(section_specific_template(template_name, options))
    end

    def section_specific_template(template_name, options = {})
      "#{current_section_name(options)}/#{template_name}"
    end

    def default_section_template(template_name, options = {})
      "default/#{template_name}"
    end

    def current_section_name(options = {})
      options[:section_name] ? options[:section_name] : (@section ? @section.name : controller_path)
    end

    if !defined?(:template_exists?)
      def template_exists?(template_path)
        logger.debug "Checking for template: #{template_path}"
        self.view_paths.find_template(template_path)
      rescue ActionView::MissingTemplate
        logger.debug "Template not found: #{template_path}"
        false
      end
    end

  end
end
