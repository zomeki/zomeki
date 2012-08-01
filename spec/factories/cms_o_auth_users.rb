# encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :valid_o_auth_user, :class => Cms::OAuthUser do
    provider 'provider'
    uid '1234567890'
    name '山田 太郎'
    image 'http://example.com/images/yamada.jpg'
  end
end
