module Ramenu
  
  # flags
  def self.static_flags(flagset = nil)
    flagset = DEFAULT_GROUP if flagset.nil?
    @ramenu_flags ||= {}
    @ramenu_flags[flagset] ||= {}
  end

  # return static menus
  def self.static_menus(menu = nil)
    menu = DEFAULT_GROUP if menu.nil? 
    @ramenu_menus ||= {}
    @ramenu_menus[menu] ||= []
  end

  # add a new flag to a set of flags
  def self.set_flag_in(flags, name, value, options = {})
    flags.merge!({ name => value }) unless name.nil? || value.nil?
  end
  # add a new menu element to a set of menus
  def self.add_menu_to(menu, name, path, options = {}, &block)
    menu << new_ramenu_element(name, path, options, &block)
  end

  # create a new menu element
  def self.new_ramenu_element(name, path = nil, options = {}, &block)
    options[:flag] = name if options[:flag_for_menu] == true && name.is_a?(Symbol)
    
    elem = Menus::Element.new(name, path, options)
    yield elem if block_given?
    return elem
  end

  # menus
  def self.add_menu(name, path, options = {}, &block)
    menu = options[:menu]
    add_menu_to(static_menus(menu), name, path, options, &block)
  end

end

