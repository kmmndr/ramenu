require 'active_support/configurable'

module Ramenu
  # Configures global settings for Ramenu
  def self.configure(&block)
    yield @config ||= Ramenu::Configuration.new
  end

  # Global settings for Ramenu
  def self.config
    @config
  end

  # need a Class for 3.0
  class Configuration #:nodoc:
    include ActiveSupport::Configurable
    config_accessor :menus
    config_accessor :flags

    # common
    def definer(name = nil, options = {}, &block)
      # menus
      menus = Ramenu.static_menus(name)
      # flags
      flags = Ramenu.static_flags(name)

      # use a definer to allow block
      rd = RamenuDefiner.new(menus, flags, options)
      yield rd if block_given?
    end

    # create a new static flag in the configuration
    def set_flag(name, value = nil, options = {})
      flags = Ramenu.static_flags(options[:flagset])
      Ramenu.set_flag_in(flags, name, value, options)
    end

    # create a new static menus in the configuration
    def add_menu(name, path = nil, options = {}, &block)
      menus = Ramenu.static_menus(options[:menu])
      Ramenu.add_menu_to(menus, name, path, options, &block)
    end
  end
end
