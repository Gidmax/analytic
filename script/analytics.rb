require 'google/apis/analyticsreporting_v4'
require 'googleauth'

include Google::Apis::AnalyticsreportingV4
include Google::Auth

VIEW_ID = "150525409" #your profile ID from your Analytics Profile
SCOPE = 'https://www.googleapis.com/auth/analytics.readonly'

@client = AnalyticsReportingService.new

#Using the "Server to Server auth mechanism as documented at
#https://developers.google.com/api-client-library/ruby/auth/service-accounts
@creds = ServiceAccountCredentials.make_creds({:json_key_io => File.open('./client_secrets.json'),
                                                    :scope => SCOPE})
@client.authorization = @creds

grr = GetReportsRequest.new
rr = ReportRequest.new

rr.view_id = VIEW_ID

#put a filter which only returns results for the root page
rr.filters_expression="ga:pagePath==/"

#We want the number of sessions
metric = Metric.new
metric.expression = "ga:sessions"
rr.metrics = [metric]

#We want this for the last 7 days
range = DateRange.new
range.start_date = "7daysAgo"
range.end_date = "today"
rr.date_ranges = [range]

grr.report_requests = [rr]

response = @client.batch_get_reports(grr)
puts response.inspect
puts response.reports.inspect
