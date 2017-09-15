module ConnecpathHelper
  class UsersController < ApplicationController

    
    # def internal_request(path, params={})
    #   request_env = Rack::MockRequest.env_for(path, params: params.to_query)

    #   # Returns: [ status, headers, body ]
    #   Rails.application.routes.call(request_env)
    # end

    # def trial
    #   internal_request('/users/password-reset/'+params[:email_token])
    # end

    def user_details(arr)
      arr = arr.uniq
      user_expanded_list = {}
      arr.each do |id|
        user = User.where(id: id).first
        user_params = (user.slice(:email, :active, :name, :username, :id, :created_at))      
        user_params[:user_fields] = add_field_name(user.user_fields).slice("role", "graduation_year")     
        user_expanded_list[id.to_s] = user_params 
      end
      return user_expanded_list
    end

    def user_fields
      user_expanded_list = {}

      # puts params
      # puts params[:user_list]
      params[:user_list].each do |id|
        user = User.where(id: id).first
        user_params = (user.slice(:email, :active, :name, :username, :id, :created_at))      
        user_params[:user_fields] = add_field_name(user.user_fields).slice("role", "graduation_year")     
        user_expanded_list[id.to_s] = user_params 
      end
      render json: {id_stream: params.slice(:user_list), field_stream: user_expanded_list}
    end

    def topic_list
      topic_expanded_list = []
      user_expanded_list = {}
      user_list = []
      # puts params
      # puts params[:topic_list]
      params[:topic_list].each do |id|
        topic = Topic.where(id: id).first
        topic_params = (topic.slice(:id, :title, :last_posted_at, :created_at, :posts_count, :user_id, :reply_count, :category_id, :participant_count))      
        
        topic_params["post_stream"] = []
        Post.where(topic: topic).limit(2).each do |post|
          # puts post.to_json
          puts post.user_id
          user_list << post.user_id
          post_params = (post.slice(:id, :user_id, :post_number, :raw, :reply_count, :like_count, :created_at))   
          if params[:user_id]
            post_params[:current_user_liked] = false
            PostAction.where(post: post).each do |post_action|
              # puts post.to_json
              puts "Post Action"+post_action.to_json.to_s
              if post_action.user_id.to_i == params[:user_id].to_i
                post_params[:current_user_liked] = true
              end
            end
          end
          topic_params["post_stream"] << post_params 
        end
        topic_expanded_list << topic_params 
      end

      user_expanded_list = user_details(user_list)
      render json: {id_stream: params.slice(:topic_list), details_stream: topic_expanded_list, user_stream: user_expanded_list}
    end

    def topic_details
      topic_expanded_list = {}
      user_expanded_list = {}
      user_list = []
      topic = Topic.where(id: params[:id]).first
      if(topic)
        topic_params = (topic.slice(:id, :title, :last_posted_at, :created_at, :posts_count, :user_id, :reply_count, :category_id, :participant_count))      
        topic_expanded_list["details"] = topic_params 
        topic_expanded_list["details"]["post_stream"] = []
        Post.where(topic: topic).order('created_at ASC').each do |post|
          user_list << post.user_id
          # puts "Current Post"+post.to_json.to_s
          post_params = (post.slice(:id, :user_id, :post_number, :raw, :reply_count, :like_count, :created_at, :reply_to_post_number))   
          puts params[:user_id]
          # puts "Current User"+params[:user_id].to_s
          if params[:user_id]
            post_params[:current_user_liked] = false
            PostAction.where(post: post).each do |post_action|
              # puts post.to_json
              # puts "Post Action"+post_action.to_json.to_s + (post_action.user_id.to_i == params[:user_id].to_i).to_s
              # puts "Post Action User"+post_action.user_id.to_s + (params[:user_id].to_s)
              if post_action.user_id.to_i == params[:user_id].to_i
                puts "Adding Current User Like"
                post_params[:current_user_liked] = true
              end
            end
          end

          topic_expanded_list["details"]["post_stream"] << post_params 
        # post = Topic.where(id: id).first
        end
      end

      user_expanded_list = user_details(user_list)
      render json: { details_stream: topic_expanded_list, user_stream: user_expanded_list}
    end



    def list
      puts "Params Role"+ params["role"]
      user_list = []
      User.order(created_at: :desc).each do |user|
        if(user.user_fields["1"] == params["role"])   
          user_params = (user.slice(:email, :active, :name, :username, :id, :created_at))      
          user_params[:user_fields] = add_field_name(user.user_fields)      
          user_list << user_params    
        end  
      end 
      page_num = params["page"].to_i-1
      limit = params["limit"].to_i
      # puts "Page Number"+page_num.to_s
      # puts "Limit"+page_num.to_s
      result = user_list.drop(page_num * limit).first(limit)
      total_count = user_list.count
      render json: { total_count: total_count, user_list: result, role: params["role"], page: page_num+1, limit: limit}
    end

    def login_info
      if params[:login]
        login_info = params[:login]
        user = User.find_by_username_or_email(params[:login])
      elsif params[:id]
        user = User.where(id: params[:id]).last
      end
      if(!user)
        render json: { errors: "Login info couldn't be found"}
      else
        user_params = (user.slice(:email, :active, :name, :username, :id, :created_at))      
        user_params[:user_fields] = add_field_name(user.user_fields)       
        render json: { user: user_params}
      end
    end
    def email_token
      email_token =''

      if params[:user_id]
        email_token = EmailToken.where(user_id: params[:user_id]).last
        user = User.where(id: params[:user_id]).last
      elsif params[:username]
        user = User.where(username: params[:username]).last
        email_token = EmailToken.where(user_id: user.id).last
      elsif params[:email]
        email_token = EmailToken.where(email: params[:email]).last
        user = User.where(email: params[:email]).last
      else
        email_token = EmailToken.last
      end
      if !email_token.confirmed && !email_token.expired
        render json: { success: true, email_token: email_token, username: user.username}
      else
        render json: {errors: "Email Token is not valid anymore. Kindly reset password again"}
      end
    end


    def activate_token
      if params[:username]
        user = User.where(username: params[:username]).last
      elsif params[:email]
        user = User.where(email: params[:email]).last
      else
        render json: { error: "No params found"}
      end
      if user
        activation_token = user.user_fields["6"]
        if activation_token 
          # Activate user with new password
          email_token = EmailToken.where(user_id: params[:user_id]).last
          EmailToken.confirm(token)
        end
      end
      render json: { email_token: email_token}
    end


    def sample
      user = User.first.user_fields
      render json: { name: "donut", description: "delicious!", user: user}
    end

    def create_post
      posts_controller = PostsController.new
      params = { created_at: "2017-09-23", raw: "Reply to 6 2017-09-262017-09-262017-09-262017-09-26", topic_id: 1,  reply_to_post_number: 6}
      # # posts_controller.request = params
      # # response = posts_controller.response
      # puts posts_controller.create(params).to_s
      # render json: JSON.parse(posts_controller.render(:create(params)))
    end
    # private
    #   def retrieve_user_info
    #     oauth_info = Oauth2UserInfo.find_by(user_id: current_user.id)
    #     response = RestClient.get(
    #       endpoint_store_url,
    #       {
    #         params: {
    #           user_uid: oauth_info.try(:uid),
    #           user_token: session[:authentication]
    #         }
    #       }
    #     )
    #     render json: response, status: :ok
    #   end

    #   def endpoint_store_url
    #     "#{SiteSetting.endpoint_url}/api/users/retrieve_user_info.json"
    #   end

    def add_field_name(params)
      fields = convert_to_h(params)
      @mapping  = {"1" => "role", "2" => "graduation_year", "3" => "sendbird_id", "4" => "device_token", "5" => "channel_url", "6" => "activation_token", "7" =>"head_counselor"}
      fields = fields.map {|k, v| [@mapping[k], v] }.to_h
      return fields
    end

    def convert_to_h(params)
      second_params = params
      if params.class == ActionController::Parameters
        second_params =  Hash[params.to_unsafe_h.map{ |k, v| [k.to_sym, v] }]
      end
      return second_params
    end
  end
end
