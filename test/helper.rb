dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift("#{dir}/../lib")

require "rubygems"
require "stringio"
require "minitest/autorun"
require "mocha"
require "shoulda"
require "active_record"
require "qadmin"

class MockController
  class << self
    def append_view_path(paths)
    end

    def helper_method(*args)
    end
  end

  extend Qadmin::Controller::Macros
end

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

# migrations

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :basic_models, :force => true do |t|
    t.timestamps
  end

  create_table :complex_models, :force => true do |t|
    t.string :key
    t.string :name
    t.integer :age
    t.datetime :dob

    t.timestamps
  end

  create_table :items, :force => true do |t|
    t.string :name
    t.string :sku
    t.text :description
    t.datetime :made_at
    t.float :price

    t.timestamps
  end

end

# model definitions

class BasicModel < ActiveRecord::Base; end

class ComplexModel < ActiveRecord::Base; end

class Item < ActiveRecord::Base; end

# controllers

module Admin
  class ItemsController < MockController; end
end

class BasicModelsController < MockController; end
