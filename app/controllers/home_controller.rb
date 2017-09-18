class HomeController < ApplicationController
  require 'date'
  require 'yaml'
  require 'googleauth'
  require 'googleauth/stores/redis_token_store'
  require 'google/apis/analyticsreporting_v4'
  require 'google-id-token'
  require 'dotenv'
  require 'sinatra'
  include Google::Apis::AnalyticsreportingV4
  include Google::Auth

  before_action :authenticate_user!

  LOGIN_URL = "/"

  def index
    reporter = Google::Apis::AnalyticsreportingV4::AnalyticsReportingService.new
  end

  def mod
    puts params[:title]
    @mod = params[:title]
  end

  def test
    # Check user contect before allow to this trigger
    if session[:user_contact].nil?
      redirect_to home_index_path
    end

    # Auth and Setup tracker
    access   = Tracker.where(user_id: "#{current_user.id}" ).first
    reporter = Google::Apis::AnalyticsreportingV4::AnalyticsReportingService.new
    reporter.authorization = credentials_for(Google::Apis::AnalyticsreportingV4::AUTH_ANALYTICS)

    # Prepare variable
    page_id    = access[:code]
    get_exp    = if params[:express].present? then params[:express].to_s else 'pagePath' end
    if params[:range].present?
      date_range = params[:range].split(",")
    else
      date_range = [30,7]
    end

    # Get data
    expression = "ga:#{get_exp}==/"
    @v_30_viewer = reporter.batch_get_reports(reports( page_id, date_range, expression ))
    # @total_viewer = reporter.batch_get_reports(reports( page_id, date_range, expression ))

    # Update accessible counter
    update_access(access)
  end

  def update_access(track)
    if track[:count_of_access].present?
      track[:count_of_access] += 1
    else
      track[:count_of_access] = 1
    end
    track.save
  end

  def reports(page_id, range_date, expressionist)

    # Build report request
    get_report          = GetReportsRequest.new
    requests            = ReportRequest.new
    requests.view_id    = page_id

    # Prepare blank request box
    get_report.report_requests = []

    puts "rdate init >>>"
    range_date.each do |rdate|
      puts rdate
      # metric expression
      metric              = Metric.new
      metric.expression   = "ga:sessions"
      requests.metrics    = [metric]

      # filters expression
      requests.filters_expression = expressionist

      # date range
      range               = DateRange.new
      range.start_date    = "#{rdate.to_s}daysAgo"
      range.end_date      = "today"
      requests.date_ranges  = [range]

      # Send request
      get_report.report_requests << requests
    end
    return get_report
  end

  def auth_storing
    if session[:user_contact].nil? || params[:id] != (session[:user_contact]['user_token'] rescue '')
      puts 'authenting >>>'
      audience  = session[:setting][:client_id].id
      token     = params[:id]
      validator = GoogleIDToken::Validator.new
      begin
        claim = validator.check(token, audience, audience)
        user_info = {
          user_id:    claim['sub'],
          user_email: claim['email'],
          first_name: claim['given_name'],
          last_name:  claim['family_name'],
          image:      claim['picture'],
          user_token: params[:id][0..20]
        }
        session[:user_contact] = user_info
      rescue GoogleIDToken::ValidationError => e
        puts "error on something >>>"
      end
    else
      puts 'ready contact >>>'
    end
    render json: session[:user_contact][:image] # user_info[:image]
  end

  def callback
    puts "request api >>>"
    target_url = Google::Auth::WebUserAuthorizer.handle_auth_callback_deferred(request)
    redirect target_url
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

  def credentials_for(scope)
    redis_token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new)
    authorizer  = Google::Auth::WebUserAuthorizer.new(session[:setting][:client_id] , scope, redis_token_store)
    user_id     = session[:user_contact]['user_id']
    puts request
    credentials = authorizer.get_credentials(user_id, request)
    if credentials.nil?
      redirect_to authorizer.get_authorization_url(login_hint: user_id, request: request)
    end
    credentials
  end
end
