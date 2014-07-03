class Tool::ConvertSetting < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Auth::Manager

  validates_uniqueness_of :site_url
  validates_presence_of :site_url, :title_tag, :body_tag

  def title_xpath
    Tool::Convert::Common.convert_to_xpath(title_tag)
  end

  def body_xpath
    Tool::Convert::Common.convert_to_xpath(body_tag)
  end

  def updated_at_xpath
    Tool::Convert::Common.convert_to_xpath(updated_at_tag)
  end
end
