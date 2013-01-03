# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :gp_category, '汎用カテゴリ' do |mod|
  ## contents
  mod.content :category_types, '汎用カテゴリタイプ'

  ## directories
  mod.directory :category_types, '汎用カテゴリタイプページ'

  ## pieces
  mod.piece :category_types, '汎用カテゴリ一覧'
end
