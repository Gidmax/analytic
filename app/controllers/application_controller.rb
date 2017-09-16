class ApplicationController < ActionController::Base
  require 'date'
  require 'yaml'
  require 'googleauth'
  require 'googleauth/stores/redis_token_store'
  require 'google/apis/analyticsreporting_v4'
  require 'google-id-token'
  require 'dotenv'
  include Google::Apis::AnalyticsreportingV4
  include Google::Auth

  protect_from_forgery with: :exception
  before_action :update_session
  # after_action  :update_session

  def update_session
    Dotenv.load
    Google::Apis::ClientOptions.default.application_name = 'Ruby client samples'
    Google::Apis::ClientOptions.default.application_version = '0.9'
    Google::Apis::RequestOptions.default.retries = 3

    # if action_name == 'index'
      # google authentication
      token_id = '593935752050-jqkuklfcc1gu9jjk50fidouoj0tv51o0.apps.googleusercontent.com'
      token_secret = 'GrH4PchpUO6ajM88RPbB-WU7'
      initialize_token = Google::Auth::ClientId.new(token_id,token_secret)

      # prepare setting parameter
      @setting = {
        show_exceptions:  false ,
        client_id:        initialize_token,
        # token_store:      Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new)
      }
      puts "redis load >>"
      # puts @setting[:token_store]
      session[:setting] = @setting
      # puts session[:setting]
    # end
  end

end
