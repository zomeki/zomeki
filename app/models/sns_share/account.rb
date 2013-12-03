class SnsShare::Account < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Concept

  SUPPORTED_PROVIDERS = ['facebook', 'twitter']

  default_scope order("#{self.table_name}.provider IS NULL, #{self.table_name}.provider")

  belongs_to :content, :foreign_key => :content_id, :class_name => 'SnsShare::Content::Account'
  validates_presence_of :content_id

  validate :provider_existence
  validates :provider, :presence => true, :uniqueness => {:scope => [:content_id]}

  private

  def provider_existence
    errors.add(:provider, :invalid) unless SUPPORTED_PROVIDERS.include?(self.provider)
  end
end
