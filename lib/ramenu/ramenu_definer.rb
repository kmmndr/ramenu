module Ramenu
  # A menu definer to create menus in a block
  class RamenuDefiner
    attr_accessor :menus, :flags, :options

    def initialize(menus, flags, options = {})
      self.menus = menus
      self.flags = flags
      self.options = options
    end

    # create a new flag in a block
    def set_flag(name, value = nil, options = {})
      Ramenu.set_flag_in(flags, name, value, options)
    end

    # create a new menu in a block
    def add_menu(name, path = nil, options = {}, &block)
      options[:flag_for_menu] = true if @options[:flag_for_menu] == true
      Ramenu.add_menu_to(menus, name, path, options, &block)
    end
  end
end