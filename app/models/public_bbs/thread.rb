class PublicBbs::Thread < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::File
  include Sys::Model::Auth::Free
  include PublicBbs::Model::Rel::Thread::Category
  include PublicBbs::Model::Rel::Thread::Tag
  include PortalGroup::Model::Rel::Thread::Category
  include PortalGroup::Model::Rel::Thread::Business
  include PortalGroup::Model::Rel::Thread::Attribute
  include PortalGroup::Model::Rel::Thread::Area

  belongs_to :content,      :foreign_key => :content_id,      :class_name => 'PublicBbs::Content::Thread'
  belongs_to :portal_group, :foreign_key => :portal_group_id, :class_name => 'PortalGroup::Content::Group'
  belongs_to :status,       :foreign_key => :state,           :class_name => 'Sys::Base::Status'
  belongs_to :user,         :foreign_key => :user_id,         :class_name => 'Cms::OAuthUser'

  has_many :responses, :dependent => :destroy

  validates :body, :presence => true
  validates :content_id, :presence => true
  validates :state, :presence => true
  validates :title, :presence => true
  validates :user_id, :presence => true

  def public_uri
    return @public_uri if @public_uri
    return nil unless node = content.thread_node
    @public_uri = "#{node.public_uri}#{id}"
  end

  def public_full_uri
    return nil unless node = content.thread_node
    "#{node.public_full_uri}#{id}"
  end

  def public_responses_uri
    "#{public_uri}/responses"
  end

  def participants
    user_ids = responses.inject([self.user.id]){|ids, r| ids << r.user.id }.uniq
    Cms::OAuthUser.find(user_ids)
  end
end
