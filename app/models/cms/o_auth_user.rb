class Cms::OAuthUser < ActiveRecord::Base
  include Sys::Model::Base

  has_many :threads, :foreign_key => :user_id, :class_name => 'PublicBbs::Thread'

  validates :provider, :presence => true
  validates :uid, :presence => true

  def self.create_or_update_with_omniauth(auth)
    attrs = {
      nickname: auth[:info_nickname],
      name:     auth[:info_name],
      image:    auth[:info_image],
      url:      auth[:info_url]
    }

    if (user = self.find_by_provider_and_uid(auth[:provider], auth[:uid]))
      user.update_attributes!(attrs)
    else
      user = self.create!(attrs.merge(provider: auth[:provider], uid: auth[:uid]))
    end

    return user
  end
end
