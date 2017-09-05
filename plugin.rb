# name: discourse-plugin-test
# about: Shows how to set up Git
# version: 0.0.1
# authors: Robin Ward
# add_admin_route 'purple_tentacle.title', 'purple-tentacle'

# Discourse::Application.routes.append do
#   get '/admin/plugins/purple-tentacle' => 'admin/plugins#index', constraints: StaffConstraint.new
# end

# after_initialize do
#   Discourse::Application.routes.append do
#     mount ::Disraptor::Engine, at: "/admin"
#     namespace :admin, constraints: StaffConstraint.new do
#       get 'snack' => 'snack#index'
#     end
#   end
# end
# class SnackController < ::Admin::AdminController

#   def index
#     render json: { name: "donut", description: "delicious!" }
#   end

# end

load File.expand_path('../lib/discourse_endpoint.rb', __FILE__)
# module DiscourseEndpoint ; end
load File.expand_path('../lib/discourse_endpoint/engine.rb', __FILE__)
# module DiscourseEndpoint
#   class Engine < ::Rails::Engine
#     isolate_namespace DiscourseEndpoint
#   end
# end

# And mount the engine
Discourse::Application.routes.append do
  mount ::DiscourseEndpoint::Engine, at: '/endpoint'
end