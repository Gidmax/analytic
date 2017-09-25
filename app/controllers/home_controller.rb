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
    page_id    = "134960289"  # access[:code]

    # sample instance
    instance = [
      {
        dimension:  ["ga:country","ga:hour","ga:dayOfWeekName","ga:userAgeBracket"] ,
        metric:     ["ga:users","ga:sessions","ga:pageviews"],
        date_range: [30,60],
        sort:       ["ga:users"],
        sampling:   "LARGE" ,
        max:        10000
      },
      {
        dimension:  ["ga:hour","ga:dayOfWeekName","ga:userAgeBracket"] ,
        metric:     ["ga:users","ga:pageviews"],
      },
      {
        dimension:  ["ga:userType","ga:userGender"] ,
        metric:     ["ga:users","ga:sessions"],
        date_range: [30,60],
        filter:      "ga:deviceCategory==mobile" ,
        segments:    "users::condition::ga:userGender==female"
      },
    ]

    # insert request
    dimensions = instance[0][:dimension]
    metrics    = unless params[:express].present? then instance[0][:metric] else params[:express].split(",") end
    date_range = unless params[:range].present?   then instance[0][:date_range] else params[:range].split(",")   end
    sort       = unless params[:sort].present?    then instance[0][:sort] else params[:sort].split(",")   end
    sampling_level = unless params[:sampling].present? then instance[0][:sampling] else params[:sort].split(",")   end
    max        = unless params[:max].present? then instance[0][:max] else params[:sort].split(",")   end
    filter     = unless params[:filter].present? then instance[2][:filter] else params[:sort].split(",")   end
    segments   = unless params[:segments].present? then instance[2][:segments] else params[:sort].split(",")   end

    # Get data
    batch    = reporter.batch_get_reports(reports( page_id, date_range, metrics, dimensions, sort, sampling_level, max, filter, segments  ))
    @peg     = object_parser(batch, date_range)
    @result  = batch
    puts "read file >>>"
    puts @result
    puts

    # Update accessible counter
    update_access(access)
  end

  def loot(dat,index)
    result = {}
    index.each_with_index do |desc,idx|
      result[desc] = dat[idx].to_i
    end
    return result
  end

  def simpler(text)
    p1 = text.to_s.delete "ga:"
    p2 = p1.underscore
    return p2
  end

  def format_fix(range)
    return "range_#{range}_day"
  end

  def object_parser(input, date_range)
    result    = []
    predicate = input.to_h[:reports]
    predicate.each do |pred|
      data      = pred[:data]
      metrics   = []
      dimension = []
      range_set = []
      metric_blob = {}

      # setup parser block
      parser  = {
        report: {
          dimension: {},
          metric:    {}
        },
        totals: {}
      }

      # get metric header
      pred[:column_header][:metric_header][:metric_header_entries].each do |mt|
        metrics << simpler(mt[:name])
        metric_blob[simpler(mt[:name])] = []
      end

      # get dimension header
      pred[:column_header][:dimensions].each do |dm|
        dimension << simpler(dm)
        parser[:report][:dimension][simpler(dm)] = []
      end

      # get daterange metric spiltter
      date_range.each do |range|
        range_set << format_fix(range)
        parser[:report][:metric][format_fix(range)] = metric_blob
      end

      # total table
      data[:totals].each_with_index do |total,idx|
        parser[:totals][dimension[idx]] = {
          total: loot(total[:values], metrics) ,
          max:   loot(data[:maximums][idx][:values], metrics) ,
          min:   loot(data[:minimums][idx][:values], metrics)
        }
      end
      #### report everything in this table ###
      data[:rows].each_with_index do |r,idx|
        # dimension report parsable
        r[:dimensions].each_with_index do |dim,dix|
          parser[:report][:dimension][dimension[dix]] << dim
        end
        # metrics report parsable
        # select metric by range set
        range_set.each_with_index do |rs,range_index|
          inspector = parser[:report][:metric][rs]
          r[:metrics][range_index][:values].each_with_index do |value,met_index|
            inspector[metrics[met_index]] << value
          end
        end
      end

      result << parser
    end

    return result

  end

  def update_access(track)
    if track[:count_of_access].present?
      track[:count_of_access] += 1
    else
      track[:count_of_access] = 1
    end
    track.save
  end

  def reports(page_id, range_date, metrics, dimensions, sorts, sampling_level, max, filter, segments)

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

    # sampling level
    requests.sampling_level = sampling_level

    # max results
    requests.page_size = max

    # filters expression
    requests.filters_expression = filter

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
