# encoding: utf-8

## ---------------------------------------------------------
## load config

core_uri   = Util::Config.load :core, :uri
core_title = Util::Config.load :core, :title
map_key    = Util::Config.load :core, :map_key

## ---------------------------------------------------------
## sys

first_group = Sys::Group.create!(
  :parent_id => 0,
  :level_no  => 1,
  :sort_no   => 1,
  :state     => 'enabled',
  :web_state => 'closed',
  :ldap      => 0,
  :code      => 'root',
  :name      => 'トップ',
  :name_en   => 'top'
)

zomeki_group = Sys::Group.create!(
  :parent_id => first_group.id,
  :level_no  => 2,
  :sort_no   => 2,
  :state     => 'enabled',
  :web_state => 'closed',
  :ldap      => 0,
  :code      => '001',
  :name      => 'ぞめき',
  :name_en   => 'zomeki'
)

first_user = Sys::User.create!(
  :state    => 'enabled',
  :ldap     => 0,
  :auth_no  => 5,
  :name     => 'システム管理者',
  :account  => 'zomeki',
  :password => 'zomeki'
)

Sys::UsersGroup.create!(group: zomeki_group, user: first_user)

Core.user_group = zomeki_group
Core.user       = first_user

awa = Sys::User.create!(state: 'enabled', ldap: 0, auth_no: 2, name: '阿波 ぞめき', name_en: 'awa zomeki', account: 'awa', password: 'awa')
Sys::UsersGroup.create!(group: zomeki_group, user: awa)
hachisuka = Sys::User.create!(state: 'enabled', ldap: 0, auth_no: 4, name: '蜂須賀 太郎', name_en: 'hachisuka taro', account: 'hachisuka', password: 'hachisuka')
Sys::UsersGroup.create!(group: zomeki_group, user: hachisuka)
ebisu = Sys::User.create!(state: 'enabled', ldap: 0, auth_no: 2, name: '恵比寿 花子', name_en: 'ebisu hanako', account: 'ebisu', password: 'ebisu')
Sys::UsersGroup.create!(group: zomeki_group, user: ebisu)
ukiyo = Sys::User.create!(state: 'enabled', ldap: 0, auth_no: 2, name: '浮世 蓮', name_en: 'ukiyo ren', account: 'ukiyo', password: 'ukiyo')
Sys::UsersGroup.create!(group: zomeki_group, user: ukiyo)
sasa = Sys::User.create!(state: 'enabled', ldap: 0, auth_no: 2, name: '笹 みやび', name_en: 'sasa miyabi', account: 'sasa', password: 'sasa')
Sys::UsersGroup.create!(group: zomeki_group, user: sasa)

## ---------------------------------------------------------
## cms

Sys::Language.create!(
  :state   => 'enabled',
  :sort_no => 1,
  :name    => 'Japanese',
  :title   => '日本語'
)

site = Cms::Site.create!(
  :state    => 'public',
  :name     => core_title,
  :full_uri => core_uri,
  :node_id  => 1,
  :map_key  => map_key,
  :portal_group_state => 'visible'
)
site.groups << first_group
site.groups << zomeki_group

concept = Cms::Concept.create!(
  :parent_id => 0,
  :site_id   => site.id,
  :state     => 'public',
  :level_no  => 1,
  :sort_no   => 1,
  :name      => core_title
)

Cms::Node.create!(
  :site_id      => site.id,
  :concept_id   => concept.id,
  :parent_id    => 0,
  :route_id     => 0,
  :state        => 'public',
  :published_at => Time.now,
  :directory    => 1,
  :model        => 'Cms::Directory',
  :name         => '/',
  :title        => core_title
)

Cms::Node.create!(
  :site_id      => site.id,
  :concept_id   => concept.id,
  :parent_id    => 1,
  :route_id     => 1,
  :state        => 'public',
  :published_at => Time.now,
  :directory    => 0,
  :model        => 'Cms::Page',
  :name         => 'index.html',
  :title        => core_title,
  :body         => 'ZOMEKI'
)

puts 'Imported base data.'
