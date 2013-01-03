module Ramenu

  module Menus

    # The Builder class represents the abstract class for any custom Builder.
    #
    # To create a custom Builder, just extend this class
    # and implement the following abstract methods:
    #
    # * <tt>#render</tt>: Renders and returns the collection of navigation elements
    #
    class Builder

      # Initializes a new Builder with <tt>context</tt>,
      # <tt>element</tt> and <tt>options</tt>.
      #
      # @param [ActionView::Base] context The view context.
      # @param [Array<Element>] elements The collection of Elements.
      # @param [Hash] options Hash of options to customize the rendering behavior.
      #
      def initialize(context, elements, options = {})
        @context  = context
        @elements = elements
        @options  = options
      end

      # Renders Elements and returns the Breadcrumb navigation for the view.
      #
      # @return [String] The result of the menu rendering.
      #
      # @abstract You must implement this method in your custom Builder.
      def render
        raise NotImplementedError
      end

      # get flag associated to element
      def flag_for(element, option = :flag)
        flag = nil
        flag_selector = element.options[option]
        unless flag_selector.nil?
          flag = @options[:flags][flag_selector] if @options[:flags].include?(flag_selector)
        end
        return flag
      end

      protected

        def compute_name(element)
          case name = element.name
          when Symbol
            begin
              @context.send(name)
            rescue NoMethodError
              key = 'ramenu.menus.' + @options[:menu].to_s + element.translation_key
              I18n.t(key)
            end
          when Proc
            name.call(@context)
          else
            name.to_s
          end
        end

        def compute_path(element)
          case path = element.path
          when Symbol
            @context.send(path)
          when Proc
            path.call(@context)
          when Hash
            @context.url_for(path)
          else
            path.to_s
          end
        end

    end

    # The SimpleBuilder is the default menu builder.
    # It provides basic functionalities to render a menu navigation.
    #
    # The SimpleBuilder accepts a limited set of options.
    # If you need more flexibility, create a custom Builder and
    # pass the option :builder => BuilderClass to the <tt>render_menus</tt> helper method.
    #
    class SimpleBuilder < Builder

      def render
        @elements.collect do |element|
          render_element(element)
        end.join(@options[:separator] || " &raquo; ")
      end

      def render_element(element)
        content = @context.link_to_unless_current(compute_name(element), compute_path(element), element.options)

        # rendering sub-elements
        if (element.childs.length > 0)
          content = content + " |"
          element.childs.each do |child|
            content = content + @context.link_to_unless_current(compute_name(child), compute_path(child)) + "|"
          end
        end

        if @options[:tag]
          @context.content_tag(@options[:tag], content)
        else
          content
        end
      end

    end


    # Represents a navigation element in the menu collection.
    #
    class Element

      # @return [String] The element/link name.
      attr_accessor :name
      # @return [String] The element/link URL.
      attr_accessor :path
      # @return [Hash] The element/link childs
      attr_accessor :childs
      # @return [Element] The element/link parent
      attr_accessor :parent
      # @return [Hash] The element/link URL.
      attr_accessor :options

      # Initializes the Element with given parameters.
      #
      # @param  [String] name The element/link name.
      # @param  [String] path The element/link URL.
      # @param  [Hash] options The element/link URL.
      # @return [Element]
      #
      def initialize(name, path, options = {})
        self.name     = name
        self.path     = path
        self.childs   = []
        #self.parent   = @options[:parent]
        self.parent   = options.delete(:parent)
        self.options  = options
      end

      def translation_key
        key = ''
        elem = self
        while !elem.nil? do
          key = '.' + elem.name.to_s + key if elem.name.is_a?(Symbol)
          key = '.' + elem.name.to_sym.to_s + key if elem.name.is_a?(String)
          elem = elem.parent
        end
        key += '.root' if self.childs.count > 0
        return key
      end

      def add_menu(name, path, options = {}, &block)
        opts = options.merge({:parent => self})
        self.childs << Ramenu.new_ramenu_element(name, path, opts, &block)
      end
      alias :add_child :add_menu
    end

  end

end
