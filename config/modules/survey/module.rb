# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :survey, '汎用アンケート' do |mod|
  ## contents
  mod.content :forms, '汎用アンケート'

  ## directories
  mod.directory :forms, 'フォーム一覧'

  ## pieces
  mod.piece :forms, 'フォーム'
end
