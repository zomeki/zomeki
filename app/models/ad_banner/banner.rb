# encoding: utf-8
class AdBanner::Banner < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::File
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]

  default_scope order(:sort_no)

  banners = self.arel_table
  scope :published, -> {
          now = Time.now
          where(banners[:state].eq('public').and(banners[:published_at].eq(nil).or(banners[:published_at].lteq(now)).and(banners[:closed_at].eq(nil).or(banners[:closed_at].gt(now)))))
        }
  scope :closed, -> {
          now = Time.now
          where(banners[:state].eq('closed').or(banners[:published_at].gt(now)).or(banners[:closed_at].lteq(now)))
        }

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'AdBanner::Content::Banner'
  validates_presence_of :content_id

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  validates_presence_of :state

  belongs_to :group, :foreign_key => :group_id, :class_name => 'AdBanner::Group'

  has_many :clicks, :foreign_key => :banner_id, :class_name => 'AdBanner::Click', :dependent => :destroy

  validates :advertiser_name, :presence => true
  validates :url, :presence => true

  after_initialize :set_defaults
  before_create :set_token

  private

  def set_defaults
    self.state   ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
    self.sort_no ||= 10 if self.has_attribute?(:sort_no)
  end

  def set_token
    self.token = Util::String::Token.generate_unique_token(self.class, :token)
  end

  # Override Sys::Model::Base::File#duplicated?
  def duplicated?
    banners = self.class.arel_table
    not self.class.where(content_id: self.content_id, name: self.name).where(banners[:id].not_eq(self.id)).empty?
  end
end
