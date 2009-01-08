$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

unless defined?(ActiveSupport)
  require 'active_support'
end

module Qadmin
  VERSION = '0.0.1'
end

require 'qadmin/helper'
require 'qadmin/controller'