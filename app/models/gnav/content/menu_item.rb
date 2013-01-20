# encoding: utf-8
class Gnav::Content::MenuItem < Cms::Content
  default_scope where(model: 'Gnav::MenuItem')

  has_many :menu_items, :foreign_key => :content_id, :class_name => 'Gnav::MenuItem', :order => :sort_no, :dependent => :destroy
end
