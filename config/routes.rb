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
      post 'user_fields_by_username'
      post 'topic_list'
      get 'login_info'
      get 'topic_details'
      get 'users_all'
      get 'delete_all_users'
      get 'delete_user'
      get 'posts_all'
      get 'delete_all_posts'
      get 'delete_post'
      get 'topics_all'
      get 'delete_all_topics'
      get 'delete_topic'
      get 'categories_all'
      get 'delete_all_categories'
      get 'delete_category'
    end
  end
end
