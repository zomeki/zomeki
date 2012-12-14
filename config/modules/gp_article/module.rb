# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :gp_article, '汎用記事' do |mod|
  ## contents
  mod.content :docs, '汎用記事'

  ## directories
  mod.directory :category_types, 'カテゴリタイプページ'
  mod.directory :docs, '記事ページ'
end
