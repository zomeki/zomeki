class PublicBbs::Response < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::File
  include Sys::Model::Auth::Free

  belongs_to :content, :foreign_key => :content_id, :class_name => 'PublicBbs::Content::Thread'
  belongs_to :status,  :foreign_key => :state,      :class_name => 'Sys::Base::Status'
  belongs_to :thread,  :foreign_key => :thread_id,  :class_name => 'PublicBbs::Thread'
  belongs_to :user,    :foreign_key => :user_id,    :class_name => 'Cms::OAuthUser'

  validates :body, :presence => true
  validates :content_id, :presence => true
  validates :state, :presence => true
  validates :title, :presence => true
  validates :thread_id, :presence => true
  validates :user_id, :presence => true
end
