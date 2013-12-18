class Tool::ConvertSetting < ActiveRecord::Base
  include Sys::Model::Base

  attr_accessible :body_tag, :site_url, :title_tag

  validates_uniqueness_of :site_url
  validates_presence_of :site_url, :title_tag, :body_tag

end
