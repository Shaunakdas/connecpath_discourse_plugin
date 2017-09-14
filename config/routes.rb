ConnecpathHelper::Engine.routes.draw do
  resource :users do
    collection do
      # get 'current'
      get 'list'
      get 'sample'
      get 'create_post'
      get 'email_token'
      post 'trial'
      post 'user_fields'
      post 'topic_list'
      get 'login_info'
      get 'topic_details'
    end
  end
end
