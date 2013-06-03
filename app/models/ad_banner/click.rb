# encoding: utf-8
class AdBanner::Click < ActiveRecord::Base
  include Sys::Model::Base

  default_scope order('created_at DESC')

  belongs_to :banner, :foreign_key => :banner_id, :class_name => 'AdBanner::Banner'
  validates_presence_of :banner_id
end
