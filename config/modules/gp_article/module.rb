# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :gp_article, '汎用記事' do |mod|
  ## contents
  mod.content :docs, '汎用記事'

  ## directories
  mod.directory :docs, '汎用記事ページ'
  mod.directory :archives, 'アーカイブ一覧'

  ## pieces
  mod.piece :docs, '汎用記事一覧'
  mod.piece :recent_tabs, '新着タブ'
  mod.piece :monthly_archives, '月間アーカイブ'
  mod.piece :archives, 'アーカイブ'
  mod.piece :comments, '最新コメント'
end
