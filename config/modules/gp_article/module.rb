# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :gp_article, '汎用記事' do |mod|
  ## contents
  mod.content :docs, '汎用記事'

  ## directories
  mod.directory :docs, '汎用記事ページ'

  ## pieces
  mod.piece :recent_tabs, '新着タブ'
end
