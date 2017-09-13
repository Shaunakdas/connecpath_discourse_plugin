module ConnecpathHelper
  class UsersController < ApplicationController

    # def current
    #   if current_user.present?
    #     retrieve_user_info
    #   else
    #     render nothing: true, status: 404
    #   end
    # end
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
