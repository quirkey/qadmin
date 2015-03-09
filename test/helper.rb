require 'rubygems'
require 'stringio'
require 'minitest/autorun'
require 'mocha'
require 'shoulda'

require File.dirname(__FILE__) + '/../lib/qadmin'

require "active_record"

class MockColumn
  attr_accessor :name, :type

  def initialize(name, type)
    self.name = name
    self.type = type
  end

  def human_name
    name.to_s.humanize
  end

  def default
    nil
  end
end

class BasicModel < ActiveRecord::Base
end

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :basic_models, :force => true do |t|
    t.string :key
    t.string :name
    t.integer :age
    t.datetime :dob

    t.timestamps
  end

end

class Item < ActiveRecord::Base

  class << self

    def content_columns
      columns = {
        :name => :string,
        :sku  => :string,
        :description => :text,
        :made_at => :datetime,
        :price => :float,
        :created_at => :datetime,
        :updated_at => :datetime
      }
      columns.collect do |name, type|
        MockColumn.new(name, type)
      end
    end

    def column_names
      [] #content_columns.collect {|c| c.name }
    end
  end
end

class MockController
  class << self
    def append_view_path(paths)
    end

    def helper_method(*args)
    end
  end

  extend Qadmin::Controller::Macros
end

module Admin
  class ItemsController < MockController; end
end

class BasicModelsController < MockController; end
