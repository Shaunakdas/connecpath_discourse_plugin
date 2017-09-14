ConnecpathHelper::Engine.routes.draw do
  resource :users do
    collection do
      # get 'current'
      get 'list'
      get 'sample'
      get 'create_post'
      get 'email_token'
      post 'trial'
      get 'login_info'
    end
  end
end
