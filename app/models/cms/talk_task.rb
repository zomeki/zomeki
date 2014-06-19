# encoding: utf-8
class Cms::TalkTask < ActiveRecord::Base
  include Sys::Model::Base
  
  validates_presence_of :path

  def site_id
    if s = self.path.match(/\/sites\/[\d]{2}\/[\d]{2}\/[\d]{2}\/[\d]{2}\/([\d]{8})\//)
      return s[1].to_i
    end
    return nil
  end
end
