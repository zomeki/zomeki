class GpArticle::Comment < ActiveRecord::Base
  include Sys::Model::Base

  attr_accessible :state,
                  :author_name,
                  :author_email,
                  :author_url,
                  :body,
                  :posted_at

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]

  scope :public, where(state: 'public')

  belongs_to :doc
  validates_presence_of :doc_id

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'
  validates_presence_of :state

  after_initialize :set_defaults
  after_save :set_display_attributes

  validates :author_name, :presence => true, :length => {maximum: 200}

  def editable?
    doc.editable?
  end

  def deletable?
    doc.deletable?
  end

  def self.all_with_content_and_criteria(content, criteria)
    comments = self.arel_table

    rel = self.joins(:doc).readonly(false)

    docs = GpArticle::Doc.arel_table
    rel = rel.where(docs[:content_id].eq(content.id))

    rel = rel.where(comments[:body].matches("%#{criteria[:free_word]}%")) if criteria[:free_word].present?
    rel = rel.where(comments[:author_name].matches("%#{criteria[:author_name]}%")) if criteria[:author_name].present?

    return rel
  end

  private

  def set_defaults
    self.state = STATE_OPTIONS.last.last if self.has_attribute?(:state) && self.state.nil?
  end

  def set_display_attributes
    self.update_column(:posted_at, self.created_at) if self.posted_at.nil?
  end
end
