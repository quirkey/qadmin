require 'qadmin'
require 'qadmin/form_builder'

ActionController::Base.send(:extend, Qadmin::Controller::Macros)
ActionView::Base.send(:include, Qadmin::Helper)
ActionView::Base.default_form_builder = Qadmin::FormBuilder
