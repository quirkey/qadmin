require File.join(File.dirname(__FILE__), '..', 'qadmin/qadmin')

ActionController::Base.send(:extend, Qadmin::Base)
ActionView::Base.send(:include, Qadmin::Helper)