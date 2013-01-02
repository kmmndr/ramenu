module Ramenu

  class Railtie < Rails::Railtie
    initializer "ramenu.initialize" do
    end
  end

end

ActiveSupport.on_load(:action_controller) do
  include Ramenu::ActionController
end
