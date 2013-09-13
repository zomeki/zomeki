class Rank::GoogleAnalytics
  extend Garb::Model
  metrics :visits, :pageviews #:visitors
  dimensions :date, :page_title, :page_path, :hostname
end
