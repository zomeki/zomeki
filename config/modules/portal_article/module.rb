# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :portal_article, 'ホームページ記事' do |mod|
  ## contents
  mod.content :docs, 'ホームページ記事'
  
  ## directory
  mod.directory :docs, '記事一覧，記事ページ'
  mod.directory :recent_docs, '新着記事一覧'
#  mod.directory :event_docs, 'イベント記事一覧'
  mod.directory :tag_docs, 'タグ検索'
  mod.directory :categories, 'カテゴリ一覧'
  mod.directory :archives, 'アーカイブ'
  
  ## pages
  #mod.page
  
  ## pieces
  mod.piece :recent_docs, '新着記事一覧'
  mod.piece :recent_tabs, '新着タブ'
#  mod.piece :calendars, 'カレンダー'
  mod.piece :categories, 'カテゴリ一覧'
  mod.piece :archives, 'アーカイブ'
end
