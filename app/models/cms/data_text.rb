# encoding: utf-8
class Cms::DataText < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept
  
  belongs_to :status,  :foreign_key => :state,      :class_name => 'Sys::Base::Status'
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  
  validates_presence_of :state, :name, :title, :body
  validates_uniqueness_of :name, :scope => :concept_id
  validates_format_of :name, :with => /^[0-9a-zA-Z\-_]+$/, :if => "!name.blank?",
    :message => "は半角英数字、ハイフン、アンダースコアで入力してください。"
end
