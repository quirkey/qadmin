# qadmin

# libs
require "erubis"
require "forwardable"
require "iconv"
require "active_support" unless defined?(ActiveSupport)

# modules
require "qadmin/controller"
require "qadmin/helper"
require "qadmin/overlay"
require "qadmin/page_titles"
require "qadmin/templates"
require "qadmin/util"

# classes
require "qadmin/configuration"

module Qadmin
  VERSION = "1.0.2.pp"
end
