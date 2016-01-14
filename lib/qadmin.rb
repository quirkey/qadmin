# qadmin

# libs
require "erubis"
require "forwardable"
require "active_support" unless defined?(ActiveSupport)

# modules
require "qadmin/controller"
require "qadmin/helper"
require "qadmin/overlay"
require "qadmin/page_titles"
require "qadmin/templates"
require "qadmin/util"
require "qadmin/version"

# classes
require "qadmin/configuration"

module Qadmin
end
