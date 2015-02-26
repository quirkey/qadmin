require 'iconv'

unless defined?(ActiveSupport)
  require 'active_support'
end

require 'erb'

module Qadmin
  VERSION = '0.3.0'
end

%w{
  configuration
  helper
  overlay
  page_titles
  templates
  controller
}.each {|lib| require "qadmin/#{lib}" }
