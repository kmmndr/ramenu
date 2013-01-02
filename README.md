# Ramenu - Rails 'A la carte' menu

*Ramenu* is a simple Ruby on Rails plugin for creating and managing a menu navigation for a Rails project.
It provides helpers for creating navigation elements with a flexible interface.


## Requirements

* Rails 3

Please note 

* Ramenu 2.x requires Rails 3. Use Ramenu 1.x with Rails 2.
* Ramenu doesn't work with Rails 2.1 or lower.


## Installation

[RubyGems](http://rubygems.org) is the preferred way to install *Ramenu* and the best way if you want install a stable version.

    $ gem install ramenu

Specify the Gem dependency in the [Bundler](http://gembundler.com) `Gemfile`.

    gem "ramenu"

Use [Bundler](http://gembundler.com) and the [:git option](http://gembundler.com/v1.0/git.html) if you want to grab the latest version from the Git repository.


## Basic Usage

Creating a navigation menu in your Rails app using **Ramenu** is really straightforward.
There are two kinds of menus types, statics and volatiles. The first are kept whereas the second ones are only defined in controllers.
Aside to the menu, you may want to set flags to interact with you menu generator.

To define static menus, do it only once by creating an initializer, there will be availlable everywhere in your controllers.

    # config/initializers/ramenu_config.rb
    Ramenu.configure do |config|
      # define a menu (by default, the :default menu is used)
      config.add_menu :welcome, :root_path #, :menu => :default
    
      # define a menu
      config.add_menu :home, :root_path, :menu => :bottom_menu
    
      # definer takes as argument the symbol name of the menus/flags to use
      config.definer :main_menu do |d|
        # add_menu method here takes the sames arguments as in a controller (see below)
        d.add_menu :home, :root_path
        d.add_menu :account, :root_path
        d.add_menu :bien, :root_path
      end
    
      # definer have an optional argument to pass options.
      # The main option is ':flag_for_menu'.
      # Turn it to 'true' and your definer will associate a flag of the same name for each menu
      # created. The flag is an option set in the menu element, and is later accessible in the
      # builder, use it at your own convenience.
      #
      config.definer :main_menu, :flag_for_menu => true do |d|
        # add_menu method here takes the sames arguments as in a controller (see below)
        d.add_menu :home, :root_path
        d.add_menu :account, :root_path
        d.add_menu :bien, :root_path
    
        # flags attributes can be set here
        d.set_flag :home, true
        d.set_flag :bien, false
    
        # you can use as may flag as you need.
        # theses options are accessible in your builders (see below)
        d.add_menu :visits, :users_path, :right_icon => :visits_icon_flag
    
        # and flag can be set with any value, boolean, or symbols for example
        d.set_flag :visits_icon_flag, :waiting
      end
    
    end


In your controller, call `add_menu` to push a new element on the menu stack. `add_menu` requires two arguments: the name of the menu and the target path. See the section "Menus Element" for more details about name and target class types.
The third, optional argument is a Hash of options to customize the menu.

You can use the same definer as in the configuration, by calling `definer`, except that it will create a volatile block by default.
During the rendering, volatile menus/flags will merge with statics ones or override them if they have the same name.
Doing that, you can define default flags in the configuration, and change their values in the controllers.

    class MyController
    
      add_menu "home", :root_path
      add_menu "my", :my_path

      # you may specify the menus you want to use instead of the default one
      add_menu "my", :my_path, :menu => :bottom_menu
      
      # to add sub-menu (alternate menus for the same level)
      add_menu :users, :users_path do |mm|
        # add submenu using a symbol for translation (see translation below)
        mm.add_menu :accounts, :accounts_path
        # or a string
        mm.add_menu "Profiles", :profiles_path
      end

      # to add a menu for current view
      add_menu_for_current "My profile"

      # definer takes as argument the symbol name of the menu/flags to use
      definer :main_menu do |d|
        d.add_menu :home, :root_path
        d.add_menu :bien, :root_path
      end

      # definer in the controller takes the same optional argument as in the configuration, to pass options.
      definer :main_menu, :flag_for_menu => true do |d|
        d.add_menu :folder, :folders_path

        # volatile flags override statics ones
        d.set_flag :visits_icon_flag, :valid
      end


      def index
        # ...
        
        add_menu "index", index_path
      end

      def create
        # definer in the controller takes the same optional argument as in the configuration, to pass options.
        # By default, volatile blocks are defined in the controller. You may use the <tt>static</tt> option to create static block.
        definer :main_menu, :flag_for_menu => true, :static => true do |d|
          d.add_menu :account, :account_path

          # flags attributes can be set here
          d.set_flag :home, true
          d.set_flag :bien, false

          # you can use as may flag as you need.
          # theses options are accessible in your builders (see below)
          d.add_menu :cart, :cart_path, :right_icon => :cart_icon_flag

          # and flag can be set with any value, boolean, or symbols for example
          d.set_flag :cart_icon_flag, :waiting
        end
      end
    
    end

In your view, you can render the menu menu with the `render_menus` helper.

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
      <title>untitled</title>
    </head>
    
    <body>
      <%= render_ramenu %>
    </body>
    </html>

`render_ramenu` understands a limited set of options. For example, you can pass change the default separator with the `:separator` option, or the default menu to use with the `:menu` option.

    <body>
      <%= render_ramenu :separator => ' / ', :menu => :side_menu_menu %>
    </body>

More complex customizations require a custom Builder, see custom builder below.

### Menus Element

A menu is composed by a number of `Element` objects. Each object contains two attributes: the name of the menu and the target path.

When you call `add_menu`, the method automatically creates a new `Element` object for you and append it to the menus stack. `Element` name and path can be one of the following Ruby types:

* Symbol
* Proc
* String

#### Symbol

If the value is a Symbol, it can be used for two different things.
At first, the library try to call the corresponding method in the same context and sets the `Element` attribute to the returned value.
Then, if no method are found with that name, the library search for a key in the translation. (see below for translation keys examples)

    class MyController
    
      # The Name is set to the value returned by
      # the :root_name method.
      add_menu :function_name, "/"
      add_menu :translate_me, "/"
      
      protected
  
        def function_name
          "the name"
        end
    
    end

#### Proc

If the value is a Proc, the library calls the proc passing the current view context as argument and sets the `Element` attribute to the returned value. This is useful if you want to postpone the execution to get access to some special methods/variables created in your controller action.

    class MyController
    
      # The Name is set to the value returned by
      # the :root_name method.
      add_menu Proc.new { |c| c.my_helper_method },
                     "/"
      
    end

#### String

If the value is a String, the library sets the `Element` attribute to the string value.

    class MyController
      
      # The Name is set to the value returned by
      # the :root_name method.
      add_menu "homepage", "/"
    
    end


### Restricting menu scope

The `add_menu` method understands all options you are used to pass to a Rails controller filter.
In fact, behind the scenes this method uses a `before_filter` to store the tab in the `@ramenu_menus` variable.

Taking advantage of Rails filter options, you can restrict a tab to a selected group of actions in the same controller.

    class PostsController < ApplicationController
      add_menu "admin", :admin_path
      add_menu "posts", :posts_path, :only => %w(index show)
    end
    
    class ApplicationController < ActionController::Base
      add_menu "admin", :admin_path, :if => :admin_controller?
      
      def admin_controller?
        self.class.name =~ /^Admin(::|Controller)/
      end
    end

### Internationalization and Localization

Ramenu is compatible with the standard Rails internationalization framework. 

For our previous example, if you want to localize your menu, define a new menus node in your .yml file with all the keys for your elements.
The convention is 'ramenu.menus' followed by your menus symbol (:default by default) then by the menu hierachy.

    add_menu :users, :users_path do |mm|
      # add submenu using a symbol for translation (see translation below)
      mm.add_child :accounts, :accounts_path 
    end

The menu itself is translated here by 'ramenu.menus.default.users.root', and the sub-menu is 'ramenu.menus.default.users.accounts'.

    # config/locales/en.yml
    en:
      ramenu:
        menus:
          default:
            translate_me: "Translated"
            users:
              root: "Menu title"
              accounts: "Accounts sub menu"


In your controller, you can also use the `I18n.t` method directly as it returns a string.

    class PostsController < ApplicationController
      add_menu I18n.t("events.new_year"),  :events_path
      add_menu I18n.t("events.holidays"),  :events_path, :only => %w(holidays)
    end
    
    class ApplicationController < ActionController::Base
      add_menu I18n.t("homepage"), :root_path
    end

### Custom builder

If you need a specific menu, you'll need to define a custom builder.
To create such builder, add a file like the following.
In your builder, you can use `flag_for(element, [:name_of_the_flag])`, without its optional argument you'll get the flag named ':flag'

    # /lib/ramenu/menus/html_builder.rb
    module Ramenu
      module Menus
        # The HtmlBuilder is an html5 breadcrumb builder.
        # It provides a simple way to render breadcrumb navigation as html5 tags.
        #
        # To use this custom Builder pass the option :builder => BuilderClass to the `render_ramenu` helper method.
        #
        class HtmlBuilder < Builder
    
          def render
            # creating nav id=breadcrumb
            @context.content_tag(:nav, :id => 'breadcrumb') do
              render_elements(@elements)
            end
          end
    
          def render_elements(elements)
            content = nil
            elements.each do |element|
              if content.nil?
                content = render_element(element)
              else
                content << render_element(element)
              end
            end
            @context.content_tag(:ul, content)
          end
    
          def render_element(element)
            # preparing element
            name = compute_name(element)
            path = compute_path(element)
            name_class = ''

            left_icon_class = element.options[:left_icon_class]
            left_icon_class = element.name if left_icon_class.nil?
            
            case left_icon_class
              when Symbol
                name_class = left_icon_class.to_s
              when String
                name_class = left_icon_class
            end
            
            span_class = "icons sprite-#{name_class}"
            content = @context.link_to(path, :title => name) do
              @context.content_tag(:span, '', :class => span_class) + @context.content_tag(:span, "#{name}", :class => 'label')
            end

            # rendering sub-elements
            if element.childs.length > 0
              content = content + render_elements(element.childs)
            end

            # adding element and it's sub-elements
            # activ ?
            class_arr = []
            class_arr << 'activ' if flag_for(element) == true
            class_arr << 'highlight' if element.childs.length > 0
            activ_class = nil
            activ_class = class_arr.join(" ") if class_arr.count > 0
            @context.content_tag(:li, content, :class => activ_class)
          end
        end
      end
    end


And do not forget to add /lib to rails autoload_paths by adding the following line.

    # config/application.rb
    module MyNiceRailsApplication
      class Application < Rails::Application
    
        ...

        # Custom directories with classes and modules you want to be autoloadable.
        # config.autoload_paths += %W(#{config.root}/extras)
        config.autoload_paths += %W( #{config.root}/lib )
    
        ...
    
      end
    end

Use your new builder by adding the builder option to the renderer.

    <%= render_ramenu(:builder => Ramenu::Menus::HtmlBuilder) %>

## Resources

* [Homepage](https://github.com/lafourmi/ramenu)
* [Documentation](https://github.com/lafourmi/ramenu)
* [API](http://rubydoc.info/gems/ramenu)
* [Repository](https://github.com/lafourmi/ramenu)
* [Issue Tracker](http://github.com/lafourmi/ramenu/issues)


## License

*Ramenu* is Copyright (c) 2013 La Fourmi Immo.
This is Free Software distributed under the MIT license and include code from Simone Carletti Copyright (c) 2009-2012.
