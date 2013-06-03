# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :tag, '関連ワード' do |mod|
  ## contents
  mod.content :tags, '関連ワード'

  ## directories
  mod.directory :tags, '関連ワードページ'

  ## pieces
  mod.piece :tags, '関連ワード一覧'
end
