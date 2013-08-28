class Rank::GoogleAnalytics
  extend Garb::Model
  metrics :visitors, :pageviews
  dimensions :date, :page_title, :page_path, :hostname
end
