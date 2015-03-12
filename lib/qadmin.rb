require "iconv"

unless defined?(ActiveSupport)
  require "active_support"
end

require "erubis"
require "forwardable"

module Qadmin
  VERSION = "0.3.0"
end

require "qadmin/configuration"
require "qadmin/helper"
require "qadmin/overlay"
require "qadmin/page_titles"
require "qadmin/templates"
require "qadmin/controller"
