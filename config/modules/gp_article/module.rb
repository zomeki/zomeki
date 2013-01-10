# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :gp_article, '汎用記事' do |mod|
  ## contents
  mod.content :docs, '汎用記事'

  ## directories
  mod.directory :docs, '汎用記事ページ'

  ## pieces
#TODO: 仕様未定
  mod.piece :docs, '汎用記事一覧'
end
