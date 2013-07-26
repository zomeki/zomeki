# encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  valid_user = FactoryGirl.create(:valid_o_auth_user)

  factory :valid_thread, :class => 'PublicBbs::Thread' do
    user valid_user
    unid 1
    content_id 1
    state 'closed'
    title 'スレッドタイトル'
    body 'スレッド本文'
  end

  factory :valid_thread2, :class => 'PublicBbs::Thread' do
    user valid_user
    unid 1
    content_id 1
    state 'closed'
    title 'スレッドタイトル2'
    body 'スレッド本文2'
  end
end
