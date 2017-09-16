json.extract! tracker, :id, :code, :desc, :user_id, :count_of_access, :created_at, :updated_at
json.url tracker_url(tracker, format: :json)
