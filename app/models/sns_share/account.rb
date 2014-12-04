class SnsShare::Account < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  SUPPORTED_PROVIDERS = ['facebook', 'twitter']

  default_scope order("#{self.table_name}.provider IS NULL, #{self.table_name}.provider")

  has_many :shares, :dependent => :destroy

  belongs_to :content, :foreign_key => :content_id, :class_name => 'SnsShare::Content::Account'
  validates_presence_of :content_id

  validate :provider_existence
  validates :provider, :presence => true, :uniqueness => {:scope => [:content_id]}

  def facebook_page_options=(options)
    write_attribute(:facebook_page_options, YAML.dump(options.kind_of?(Array) ? options : []))
  end

  def facebook_page_options
    YAML.load(read_attribute(:facebook_page_options).presence || '[]')
  end

  def facebook_page_text
    facebook_page_options.detect{|o| o.last == facebook_page }.try(:first) || ''
  end

  def facebook_token_options=(options)
    write_attribute(:facebook_token_options, YAML.dump(options.kind_of?(Array) ? options : []))
  end

  def facebook_token_options
    YAML.load(read_attribute(:facebook_token_options).presence || '[]')
  end

  def facebook_token_text
    facebook_token_options.detect{|o| o.last == facebook_token }.try(:first) || ''
  end

  private

  def provider_existence
    return if provider.blank?
    errors.add(:provider, :invalid) unless SUPPORTED_PROVIDERS.include?(provider)
  end
end
