require 'minitest/autorun'
require 'minitest/pride'

#require 'mocha'
#require 'dummy'

# minitest and turn
#require 'minitest_helper'

ENV["RAILS_ENV"] = "test"

require "active_support"
require "action_controller"
require "rails/railtie"
#require "i18n"

$:.unshift File.expand_path('../../lib', __FILE__)
require 'ramenu'

#ActionController::Base.view_paths = File.join(File.dirname(__FILE__), 'views')


