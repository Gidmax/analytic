class HomeController < ApplicationController
  require 'date'
  require 'yaml'
  require 'googleauth'
  require 'googleauth/stores/redis_token_store'
  require 'google/apis/analyticsreporting_v4'
  require 'google-id-token'
  require 'dotenv'
  # require 'sinatra'
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

    # insert request
    dimensions = ["ga:dayOfWeekName"]
    metrics    = unless params[:express].present? then ["ga:users","ga:pageviews","ga:pageviews/ga:users"] else params[:express].split(",") end
    date_range = unless params[:range].present?   then [90] else params[:range].split(",")   end
    sort       = unless params[:sort].present?   then ["ga:users"] else params[:sort].split(",")   end

    # Get data
    @result = reporter.batch_get_reports(reports( page_id, date_range, metrics, dimensions, sort ))

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

  def reports(page_id, range_date, metrics, dimensions, sorts)

    # Build report request
    get_report          = GetReportsRequest.new
    requests            = ReportRequest.new
    requests.view_id    = page_id #"134960289"

    # Prepare blank request box
    get_report.report_requests = []

    # dimension expression
    requests.dimensions    = []
    dimensions.each_with_index do |exp,idx|
      dimension            = Dimension.new
      dimension.name       = exp
      requests.dimensions  << dimension
    end

    # metric expression
    requests.metrics    = []
    metrics.each_with_index do |exp,idx|
      metric            = Metric.new
      metric.expression = exp
      requests.metrics  << metric
    end

    # sort expression
    requests.order_bys = []
    sorts.each_with_index do |exp,idx|
      sort              = OrderBy.new
      sort.field_name   = exp
      sort.sort_order   = "DESCENDING"
      requests.order_bys << sort
    end

    # filters expression
    # requests.filters_expression = expressionist

    # date range
    requests.date_ranges = []
    range_date.each_with_index do |rdate,idx|
      range             = DateRange.new
      range.start_date  = "#{rdate}daysAgo"
      range.end_date    = "today"
      requests.date_ranges << range
    end

    # Send request
    get_report.report_requests << requests # = [requests]
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
