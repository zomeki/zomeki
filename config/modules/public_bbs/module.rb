# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :public_bbs, '公開掲示板' do |mod|
  ## contents
  mod.content :threads, '公開掲示板'

  ## directories
  mod.directory :threads, 'スレッド一覧, スレッドページ'
  mod.directory :recent_threads, '新着スレッド一覧'
  mod.directory :categories, 'カテゴリ一覧'
  mod.directory :tag_threads, 'タグ検索'

  ## pieces
  mod.piece :categories, 'カテゴリ一覧'
end
