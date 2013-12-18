class Tool::ConvertSetting < ActiveRecord::Base
  attr_accessible :body_tag, :site_url, :title_tag
end
