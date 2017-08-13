class HomeController < ApplicationController
  require 'date'
  require 'yaml'
  require 'googleauth'
  require 'googleauth/stores/redis_token_store'
  require 'google/apis/analytics_v3'
  require 'google/apis/analyticsreporting_v4'
  require 'google-id-token'
  require 'dotenv'
  before_action :authenticate_user!

  def index
    @hello = "world"
  end

  def test
    #set_up variable
    api_version = 'v3'
    app_name    = 'dikw'
    app_version = '1.0'
    service_email = 'analytic-service@analytic-173907.iam.gserviceaccount.com'  # Email of service account
    key_file    = '593935752050-jqkuklfcc1gu9jjk50fidouoj0tv51o0.apps.googleusercontent.com'                     # File containing your private key
    key_secret  = 'GrH4PchpUO6ajM88RPbB-WU7'                        # Password to unlock private key
    # @profileID  = Service.where(author: current_user[:email]).first[:account].to_s

    # authentication
    # key = Google::Apis::KeyUtils.load_from_pkcs12(key_file, key_secret)
    # @client = Google::Apis.new(
    #   :application_name => 'Analytic' ,
    #   :application_version => 'analytic-173907'
    #   )
    # @client.authorization = Signet::OAuth2::Client.new(
    #   :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
    #   :audience => 'https://accounts.google.com/o/oauth2/token',
    #   :scope => 'https://www.googleapis.com/auth/analytics.readonly',
    #   :issuer => service_email,
    #   :signing_key => key)
    # @client.authorization.fetch_access_token!

    # Analytic tracking
    # @analytics = @client.discovered_api('analytics', api_version)

  end

  def query_ga (dimension, metric, sort , start_date , end_date)
  query_data = @client.execute(:api_method => @analytics.data.ga.get, :parameters => {
    'ids' => "ga:" + @profileID,
    'start-date' => start_date,
    'end-date' => end_date,
    'dimensions' => dimension,
    'metrics' => metric,
    'sort' => sort
  })
  return query_data
end
end
