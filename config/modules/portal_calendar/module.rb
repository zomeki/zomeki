# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :portal_calendar, 'ポータルカレンダーDB' do |mod|
  ## contents
  mod.content :events, 'ポータルカレンダー'
  
  ## directory
  mod.directory :events, "月間イベントカレンダー"
  mod.directory :lists, "月間イベントリスト"
	
  ## pages
  #mod.page
  
  ## pieces
  mod.piece :event_links, "本日と明日のイベント"
  mod.piece :calendars, 'カレンダー'
end
