Ramenu::Routes = ActionDispatch::Routing::RouteSet.new
Ramenu::Routes.draw do
  match ':controller(/:action(/:id))'
end

ActionController::Base.view_paths = File.join(File.dirname(__FILE__), 'views')
ActionController::Base.send :include, Ramenu::Routes.url_helpers

class ActiveSupport::TestCase

  setup do
    @routes = Ramenu::Routes
  end


  def controller
    @controller_proxy ||= ControllerProxy.new(@controller)
  end

  class ControllerProxy
    def initialize(controller)
      @controller = controller
    end
    def method_missing(method, *args)
      @controller.instance_eval do
        m = method(method)
        m.call(*args)
      end
    end
  end

end


