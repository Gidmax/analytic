# Create credentials json file
# 1. Go to Google API Console
# 2. Create credentials (Service Account Key). Note 'Service account ID'
# 3. Download key as 'client_secrets.json'
# 4. Go to Google Analytics -> Admin -> View Settings. Note 'View ID'
# 5. Go to User Management -> Add permissions for: (Service account ID) [Read & Analyze]

# Terminal
# export GOOGLE_APPLICATION_CREDENTIALS='./client_secrets.json'

# gem install googleauth
# gem install google-api-client

# IRB
require 'googleauth'
require 'google/apis/analytics_v3'
scopes = ['https://www.googleapis.com/auth/analytics.readonly']
stats = Google::Apis::AnalyticsV3::AnalyticsService.new
stats.authorization = Google::Auth.get_application_default(scopes)
stats.get_ga_data('ga:150525409', '7daysAgo', 'today', 'ga:pageviews', dimensions: 'ga:city')
# 150525409 is 'View ID' from step 4

# RAILS (using Figaro for env variables)
# in Gemfile
gem 'google-api-client', '~> 0.9.10', require: ['google/apis/analytics_v3', 'googleauth', 'google/api_client/client_secrets']

# in intializer
scopes = ['https://www.googleapis.com/auth/analytics.readonly']
json = StringIO.new(Figaro.env.client_secrets_json)
auth = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: json, scope: scopes)
stats = Google::Apis::AnalyticsV3::AnalyticsService.new
stats.authorization = auth
stats.get_ga_data('ga:150525409', '7daysAgo', 'today', 'ga:pageviews', dimensions: 'ga:pagePath')
