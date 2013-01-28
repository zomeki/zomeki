# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :portal_calendar, 'ポータルカレンダーDB' do |mod|
  ## contents
  mod.content :events, 'ポータルカレンダー'
  
  ## directory
  mod.directory :events, "月間イベント"
	
  ## pages
  #mod.page
  
  ## pieces
  mod.piece :monthly_links, "月別リンク"
  mod.piece :daily_links, "日別リンク"
end
