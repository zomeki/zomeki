class Rank::GoogleAnalytics
  extend Garb::Model
  metrics :pageviews, :unique_pageviews
  dimensions :date, :page_title, :page_path, :hostname
end
