Cms::Lib::Modules::ModuleSet.draw :organization, '組織' do |mod|
  ## contents
  mod.content :groups, '組織'

  ## directories
  mod.directory :groups, '組織ページ'

  ## pieces
  mod.piece :categorized_docs, '汎用カテゴリ記事一覧'
  mod.piece :business_outlines, '業務内容'
end
