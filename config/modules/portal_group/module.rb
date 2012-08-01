# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :portal_group, 'ポータル記事分類' do |mod|
  ## contents
  mod.content :groups, 'ポータル記事分類'
  
  ## directory
#  mod.directory :docs, '記事一覧，記事ページ'
  mod.directory :recent_docs, '新着記事一覧'
#  mod.directory :event_docs, 'イベント記事一覧'
  mod.directory :tag_docs, 'タグ検索（記事）'
  mod.directory :categories, '分野一覧（記事）'
  mod.directory :businesses, '業種一覧（記事）'
  mod.directory :attributes, '属性一覧（記事）'
  mod.directory :areas     , '地域一覧（記事）'
  mod.directory :sites, '新着サイト一覧'
  mod.directory :site_categories, '分野一覧（サイト）'
  mod.directory :site_businesses, '業種一覧（サイト）'
  mod.directory :site_attributes, '属性一覧（サイト）'
  mod.directory :site_areas     , '地域一覧（サイト）'
  mod.directory :threads, '新着スレッド一覧'
  mod.directory :tag_threads, 'タグ検索（スレッド）'
  mod.directory :thread_categories, '分野一覧（スレッド）'
  mod.directory :thread_businesses, '業種一覧（スレッド）'
  mod.directory :thread_attributes, '属性一覧（スレッド）'
  mod.directory :thread_areas,      '地域一覧（スレッド）'
  
  ## pages
  #mod.page
  
  ## pieces
  mod.piece :recent_docs, '新着記事一覧'
  mod.piece :recent_tabs, '新着タブ'
#  mod.piece :calendars, 'カレンダー'
  mod.piece :categories, '分野一覧（記事）'
  mod.piece :businesses, '業種一覧（記事）'
  mod.piece :attributes, '属性一覧（記事）'
  mod.piece :areas     , '地域一覧（記事）'
  mod.piece :recent_sites, '新着サイト一覧'
  mod.piece :site_categories, '分野一覧（サイト）'
  mod.piece :site_businesses, '業種一覧（サイト）'
  mod.piece :site_attributes, '属性一覧（サイト）'
  mod.piece :site_areas     , '地域一覧（サイト）'
end
