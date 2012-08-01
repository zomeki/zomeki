# encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sys_user_system_admin, :class => 'Sys::User' do
    id 1
    state 'enabled'
    created_at '2012-03-02 15:11:27'
    updated_at '2012-03-02 15:11:27'
    ldap 0
    ldap_version nil
    auth_no 5
    name 'システム管理者'
    name_en nil
    account 'zomeki'
    password 'zomeki'
    email nil
    remember_token nil
    remember_token_expires_at nil
    admin_creatable false
    site_creatable false
    groups {
      [fg_find_or_create(:sys_group_001), fg_find_or_create(:sys_group_002)]
    }
  end

  factory :sys_user_site_admin, :class => 'Sys::User' do
    id 2
    state 'enabled'
    created_at '2012-07-05 16:12:28'
    updated_at '2012-07-05 16:12:28'
    ldap 0
    ldap_version nil
    auth_no 5
    name 'サイト管理者'
    name_en nil
    account 'siteadmin'
    password 'siteadmin'
    email nil
    remember_token nil
    remember_token_expires_at nil
    admin_creatable false
    site_creatable false
    groups {
      [fg_find_or_create(:sys_group_001), fg_find_or_create(:sys_group_002)]
    }
  end
end
