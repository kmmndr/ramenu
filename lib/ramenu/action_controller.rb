module Ramenu
  module ActionController
    extend ActiveSupport::Concern

    included do
      extend          ClassMethods
      helper          HelperMethods
      helper_method   :add_menu, :menus, :flags
    end


    module Utils

      def self.instance_proc(string)
        if string.kind_of?(String)
          proc { |controller| controller.instance_eval(string) }
        else
          string
        end
      end

      # This is an horrible method with an horrible name.
      #
      #   convert_to_set_of_strings(nil, [:foo, :bar])
      #   # => nil
      #   convert_to_set_of_strings(true, [:foo, :bar])
      #   # => ["foo", "bar"]
      #   convert_to_set_of_strings(:foo, [:foo, :bar])
      #   # => ["foo"]
      #   convert_to_set_of_strings([:foo, :bar, :baz], [:foo, :bar])
      #   # => ["foo", "bar", "baz"]
      #
      def self.convert_to_set_of_strings(value, keys)
        if value == true
          keys.map(&:to_s).to_set
        elsif value
          Array(value).map(&:to_s).to_set
        end
      end

    end

    module HelperMethods

      def render_ramenu(options = {}, &block)
        # passing all flags to Builder (static + volatile)
        options[:flags] = flags(options[:menu])
        builder = (options.delete(:builder) || Menus::SimpleBuilder).new(self, menus(options[:menu]), options)
        content = builder.render.html_safe
        if block_given?
          capture(content, &block)
        else
          content
        end
      end

    end

    module ClassMethods

      #
      # flags methods
      #

      # get flag value
      def get_flag(name, filter_options = {})
        before_filter(filter_options) do |controller|
          controller.send(:get_flag, name, filter_options)
        end
      end

      # set flag value
      def set_flag(name, value, filter_options = {})
        before_filter(filter_options) do |controller|
          controller.send(:set_flag, name, value, filter_options)
        end
      end

      # reset flag value
      def reset_flag(name, filter_options = {})
        before_filter(filter_options) do |controller|
          controller.send(:reset_flag, name, filter_options)
        end
      end

      #
      # menus methods
      #

      # add a menu
      def add_menu(name, path = nil, filter_options = {}, &block)
        # This isn't really nice here
        if eval = Utils.convert_to_set_of_strings(filter_options.delete(:eval), %w(name path))
          name = Utils.instance_proc(name) if eval.include?("name")
          unless path.nil?
            path = Utils.instance_proc(path) if eval.include?("path")
          end
        end

        before_filter(filter_options) do |controller|
          # if path isn't defined, use current path
          path = request.fullpath if path.nil?

          controller.send(:add_menu, name, path, filter_options, &block)
        end
      end
      alias :add_menu_for_current :add_menu

      # define volatile menus/flags in a block
      def definer(name = nil, filter_options = {}, &block)
        before_filter(filter_options) do |controller|
          controller.send(:definer, name, filter_options, &block)
        end
      end
    end

    protected

    # common

    def definer(name = nil, options = {}, &block)
      static = options[:static] || false

      menus = static ? static_menus(name) : volatile_menus(name)
      flags = static ? static_flags(name) : volatile_flags(name)

      # use a definer to allow block
      rd = Ramenu::RamenuDefiner.new(menus, flags, options)
      yield rd if block_given?
    end

    # flags

    # get flag value
    def get_flag(name, options = {})
      # getting options
      static = options[:static] || false
      volatile = options[:volatile] || false

      f = static_flags(options[:flagset]) if static
      f = volatile_flags(options[:flagset]) if volatile
      f = flags(options[:flagset]) unless static || volatile

      f[name] if f.include?(name)
    end

    # reset flag value
    def reset_flag(name, options = {})
      set_flag(name, nil, options) unless name.nil?
    end

    # set flag value
    def set_flag(name, value = nil, options = {})
      # getting options
      static = options[:static] || false

      # setting flag
      if static
        set_static_flag(name, value, options)
      else #if volatile
        # default is volatile when nothing's set
        set_volatile_flag(name, value, options)
      end
    end

    # add a static flag, which will be kept for next instances
    def set_static_flag(name, value, options = {})
      flagset = options[:flagset]
      Ramenu.set_flag_in(static_flags(flagset), name, value, options)
    end

    # add a volatile flag, only valid in the current instances
    def set_volatile_flag(name, value, options = {})
      flagset = options[:flagset]
      Ramenu.set_flag_in(volatile_flags(flagset), name, value, options)
    end

    # return volatile flags defined in the current instance
    def volatile_flags(flagset = nil)
      flagset = :default if flagset.nil? 
      @flags ||= {}
      @flags[flagset] ||= {}
      @flags[flagset]
    end
    # return static flags defined in the configuration
    def static_flags(flagset = nil)
      Ramenu.static_flags(flagset)
    end
    # return all defined flags, static ones first then volatile ones
    def flags(flagset = nil)
      static_flags(flagset).merge(volatile_flags(flagset))
    end

    # add a static menu, which will be kept for next instances
    def add_static_menu(name, path, options = {}, &block)
      menu = options[:menu]
      Ramenu.add_menu_to(static_menus(menu), name, path, options, &block)
    end

    # add a volatile menu, only valid in the current instances
    def add_volatile_menu(name, path, options = {}, &block)
      menu = options[:menu]
      Ramenu.add_menu_to(volatile_menus(menu), name, path, options, &block)
    end
    alias :add_menu :add_volatile_menu

    # return volatile menus defined in the current instance
    def volatile_menus(menu = nil)
      menu = :default if menu.nil? 
      @ramenu_menus ||= {}
      @ramenu_menus[menu] ||= []
    end
    # return static menus defined in the configuration
    def static_menus(menu = nil)
      Ramenu.static_menus(menu)
    end
    # return all defined menus, static ones first then volatile ones
    def menus(menu = nil)
      static_menus(menu) + volatile_menus(menu)
    end

  end
end
