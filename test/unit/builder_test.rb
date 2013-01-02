require 'test_helper'

class BuilderTest < ActionView::TestCase

  def setup
    @template = self
  end


  def test_initialize_should_require_context_and_elements
    assert_raise(ArgumentError) { Ramenu::Menus::Builder.new }
    assert_raise(ArgumentError) { Ramenu::Menus::Builder.new(@template) }
    assert_nothing_raised { Ramenu::Menus::Builder.new(@template, []) }
  end

  def test_initialize_should_allow_options
    assert_nothing_raised { Ramenu::Menus::Builder.new(@template, [], {}) }
  end

  def test_initialize_should_set_context
    builder = Ramenu::Menus::Builder.new(@template, [])
    assert_equal(@template, builder.instance_variable_get(:'@context'))
  end

  def test_initialize_should_set_elements
    builder= Ramenu::Menus::Builder.new(@template, [1, 2])
    assert_equal([1, 2], builder.instance_variable_get(:'@elements'))
  end


  def test_compute_name_with_symbol
    builder = Ramenu::Menus::Builder.new(@template, [])
    element = Ramenu::Menus::Element.new(:method_for_name, nil)

    assert_equal("name from symbol", builder.send(:compute_name, element))
  end

  def test_compute_name_with_proc
    builder = Ramenu::Menus::Builder.new(@template, [])
    element = Ramenu::Menus::Element.new(proc { |template| template.send(:proc_for_name) }, nil)

    assert_equal("name from proc", builder.send(:compute_name, element))
  end

  def test_compute_name_with_string
    builder = Ramenu::Menus::Builder.new(@template, [])
    element = Ramenu::Menus::Element.new("name from string", nil)

    assert_equal("name from string", builder.send(:compute_name, element))
  end


  def test_compute_path_with_symbol
    builder = Ramenu::Menus::Builder.new(@template, [])
    element = Ramenu::Menus::Element.new(nil, :method_for_path)

    assert_equal("http://localhost/#symbol", builder.send(:compute_path, element))
  end

  def test_compute_path_with_proc
    builder = Ramenu::Menus::Builder.new(@template, [])
    element = Ramenu::Menus::Element.new(nil, proc { |template| template.send(:proc_for_path) })

    assert_equal("http://localhost/#proc", builder.send(:compute_path, element))
  end

  def test_compute_path_with_hash
    builder = Ramenu::Menus::Builder.new(@template, [])
    element = Ramenu::Menus::Element.new(nil, { :foo => "bar" })

    assert_equal("http://localhost?foo=bar", builder.send(:compute_path, element))
  end

  def test_compute_path_with_string
    builder = Ramenu::Menus::Builder.new(@template, [])
    element = Ramenu::Menus::Element.new(nil, "http://localhost/#string")

    assert_equal("http://localhost/#string", builder.send(:compute_path, element))
  end

  def test_empty_associated_flagset
    builder = Ramenu::Menus::Builder.new(@template, [])
    element = Ramenu::Menus::Element.new(nil, "http://localhost/")

    assert_equal(nil, builder.send(:flag_for, element))
  end

  def test_associated_flagset
    builder = Ramenu::Menus::Builder.new(@template, [], :flags => {:activated => true, :seen => 5})
    element = Ramenu::Menus::Element.new(nil, "http://localhost/", :flag => :activated)

    assert_equal(true, builder.send(:flag_for, element, :flag))
  end

  def url_for(params)
    "http://localhost?" + params.to_param
  end

  protected

  def method_for_name
    "name from symbol"
  end

  def proc_for_name
    "name from proc"
  end

  def method_for_path
    "http://localhost/#symbol"
  end

  def proc_for_path
    "http://localhost/#proc"
  end

end
