ConnecpathHelper::Engine.routes.draw do
  resource :users do
    collection do
      # get 'current'
      get 'list'
      get 'sample'
      get 'create_post'
    end
  end
end
