# encoding: utf-8
class Tool::ConvertLink < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Auth::Manager

  LINKABLE_TYPE_OPTIONS = [['ピース', 'Cms::Piece']]

  serialize :urls

  belongs_to :linkable, polymorphic: true
  belongs_to :concept, :class_name => 'Cms::Concept'

  after_initialize :set_defaults
  before_save :convert

  validates :linkable_id, presence: true
  validates :linkable_type, presence: true

  def linkable_id_options
    case linkable_type
    when 'Cms::Piece'
      items = Cms::Piece.where(model: 'Cms::Free')
      items = items.where(concept_id: concept_id) if concept_id.present?
      items.order('id').map{|piece| [piece.title, piece.id]}
    else
      []
    end
  end

  def convert
    return if !linkable || !linkable.has_attribute?(:body)

    self.before_body = body = linkable.body
    Nokogiri::HTML(body).xpath("//a[@href]").each do |e|
      url = e['href']
      uri = URI.parse(url) rescue next

      path = uri.absolute? ? "#{uri.host}#{uri.path}" : uri.path
      if cdoc = Tool::ConvertDoc.where('uri_path like ?', "%#{path}").first
        after_url = cdoc.doc_public_uri
        body = body.gsub(url, after_url)
        urls << [url, after_url]
      end
    end

    self.after_body = body
    linkable.update_attributes(body: body)
  end

  private

  def set_defaults
    self.urls ||= []
  end
end
