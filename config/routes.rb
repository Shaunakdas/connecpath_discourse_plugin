DiscourseEndpoint::Engine.routes.draw do
  resource :users do
    collection do
      # get 'current'
      get 'sample'
    end
  end
end
