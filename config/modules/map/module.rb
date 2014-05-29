# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :map, 'マップ' do |mod|
  ## contents
  mod.content :markers, 'マップ'

  ## directories
  mod.directory :markers, 'マップ'
  mod.directory :navigations, '周辺検索'

  ## pieces
  mod.piece :category_types, '汎用カテゴリ一覧'
end
