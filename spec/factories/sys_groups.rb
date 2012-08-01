# encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sys_group_root, :class => 'Sys::Group' do
    id 1
    unid 1
    state 'enabled'
    web_state 'closed'
    created_at '2012-03-02 15:11:27'
    updated_at '2012-03-02 15:11:27'
    parent_id 0
    level_no 1
    code 'root'
    sort_no 1
    layout_id nil
    ldap 0
    ldap_version nil
    name '組織'
    name_en 'soshiki'
    tel nil
    outline_uri nil
    email nil
  end

  factory :sys_group_001, :class => 'Sys::Group' do
    id 2
# TODO: unidを自動採番にする（システム全体でユニークにするため）
    unid 20
    state 'enabled'
    web_state 'public'
    created_at '2012-03-02 15:11:28'
    updated_at '2012-03-02 15:11:28'
    parent_id 1
    level_no 2
    code '001'
    sort_no 2
    layout_id nil
    ldap 0
    ldap_version nil
    name '企画部'
    name_en 'kikakubu'
    tel nil
    outline_uri nil
    email nil
  end

  factory :sys_group_002, :class => 'Sys::Group' do
    id 3
# TODO: unidを自動採番にする（システム全体でユニークにするため）
    unid 30
    state 'enabled'
    web_state 'public'
    created_at '2012-03-02 15:11:29'
    updated_at '2012-03-02 15:11:29'
    parent_id 1
    level_no 2
    code '002'
    sort_no 3
    layout_id nil
    ldap 0
    ldap_version nil
    name '総務部'
    name_en 'somubu'
    tel nil
    outline_uri nil
    email nil
  end
end
