class Rank::Rank < ActiveRecord::Base
  include Sys::Model::Base

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Rank::Content::Rank'
  validates_presence_of :content_id

  TERMS   = [['前日', 'previous_days'], ['先週（月曜日〜日曜日）', 'last_weeks'], ['先月', 'last_months'], ['週間（前日から一週間）', 'this_weeks']]
  TARGETS = [['PV', 'pageviews'], ['訪問者数', 'visitors']]

end
