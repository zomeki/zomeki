# encoding: utf-8
class Laby::Doc < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  belongs_to :content, :foreign_key => :content_id, :class_name => 'Article::Content::Doc'
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  validates_presence_of :state, :title
  validates_uniqueness_of :name, :scope => :content_id
  
  before_save :save_name
  
  def states
    [['公開保存','public'],['非公開保存','closed']]
  end
  
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        self.and "#{self.class.table_name}.id", v
      when 's_name'
        self.and "#{self.class.table_name}.name", v
      when 's_title'
        self.and_keywords v, :title
      when 's_keyword'
        self.and_keywords v, :title, :body
      end
    end if params.size != 0

    return self
  end
  
protected
  def save_name
    if name.blank?
      seq  = Util::Sequencer.next_id('laby_#{content_id}_doc_id')
      self.name = "c#{seq}"
    end
    return true
  end
end