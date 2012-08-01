class Cms::OAuthUser < ActiveRecord::Base
  include Sys::Model::Base

  has_many :threads, :foreign_key => :user_id, :class_name => 'PublicBbs::Thread'

  validates :provider, :presence => true
  validates :uid, :presence => true

  def self.create_or_update_with_omniauth(auth)
    attrs = {
      nickname: auth['info']['nickname'],
      name:     auth['info']['name'],
      image:    auth['info']['image'],
      url:      auth['info']['urls'].try('[]', 'Facebook')
    }

    if (user = self.find_by_provider_and_uid(auth['provider'], auth['uid']))
      user.update_attributes!(attrs)
    else
      user = self.create!(attrs.merge(provider: auth['provider'], uid: auth['uid']))
    end

    return user
  end
end
