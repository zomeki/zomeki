# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :ad_banner, '広告バナー' do |mod|
  ## contents
  mod.content :banners, '広告バナー'

  ## directories
  mod.directory :banners, '広告バナー'

  ## pieces
  mod.piece :banners, '広告バナー一覧'
end
