# encoding: utf-8
class Tag::Content::Tag < Cms::Content
  default_scope where(model: 'Tag::Tag')

  has_many :tags, :foreign_key => :content_id, :class_name => 'Tag::Tag', :order => 'last_tagged_at DESC', :dependent => :destroy
end
