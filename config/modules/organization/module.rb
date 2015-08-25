Cms::Lib::Modules::ModuleSet.draw :organization, '組織' do |mod|
  ## contents
  mod.content :groups, '組織'

  ## directories
  mod.directory :groups, '組織ページ'

  ## pieces
  mod.piece :all_groups, '組織一覧'
  mod.piece :categorized_docs, '汎用カテゴリ記事一覧'
  mod.piece :business_outlines, '業務内容'
  mod.piece :contact_informations, '連絡先'
  mod.piece :outlines, '組織概要'
end
