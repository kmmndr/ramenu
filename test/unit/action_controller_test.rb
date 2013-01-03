require 'test_helper'
require 'dummy'

Ramenu.configure do |config|
  config.add_menu :static_menu, :root_path
  config.add_menu :static_menu_bis, :root_path, :menu => :default

  config.definer :user_menu, :flag_for_menu => true do |d|
    d.add_menu :home, :root_path
    d.add_menu :users, :users_path, :flag => :users do |menu|
      menu.add_menu :dashboard, :dashboard_users_path
      menu.add_menu :help, :help_users_path
    end
    
    d.set_flag :home, true
    d.set_flag :users, false
  end

end


class MenusTestController < ActionController::Base
  add_menu :root, :extranet_root_path
  add_menu :footab, :root_path
  add_menu_for_current :current_page 

  set_flag :foo, true
  set_flag :bar, false

  definer :user_menu, :flag_for_menu => true do |d|
    d.add_menu :dashboard, :root_path
    d.add_menu :main_screen, :root_path

    d.set_flag :dashboard, false
    d.set_flag :dashboard_icon, :none
    d.set_flag :main_screen_value, 2
  end


  def index
    render :text => ''
  end

  def show
    set_flag :bar, true
    render :text => ''
  end
end

class MenusTest < ActionController::TestCase
  tests MenusTestController

  def test_add_volatile_menu
    get :index
    assert_equal(:root, controller.volatile_menus(:default).first.name)
  end

  def test_add_menu_for_current
    get :show
    assert_equal('/menus_test/show', controller.volatile_menus(:default).last.path)
  end

  def test_add_static_menu
    get :index
    assert_equal(:static_menu, controller.menus(:default).first.name)
  end

  def test_static_and_volatile_menus
    get :index
    assert_equal(5, controller.menus(:default).count)
  end

  def test_set_volatile_flag
    get :index
    assert_equal(true, controller.flags(:default)[:foo])
  end

  def test_set_static_flag
    get :index
    assert_equal(true, controller.flags(:user_menu)[:home])
  end

  def test_static_and_volatile_flags
    get :index
    assert_equal(5, controller.flags(:user_menu).count)
  end

  def test_set_flag_within_method
    get :show
    assert_equal(true, controller.flags(:default)[:bar])
  end

  def test_add_menu_with_definer
    get :index
    assert_equal(:main_screen, controller.menus(:user_menu).last.name)
  end

  def test_definer_with_flag_for_menu_set
    get :index
    assert_equal(:main_screen, controller.menus(:user_menu).last.options[:flag])
  end

  def test_set_flag_with_definer
    get :index
    assert_equal(:none, controller.flags(:user_menu)[:dashboard_icon])
  end

end

