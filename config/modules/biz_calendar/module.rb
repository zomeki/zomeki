# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :biz_calendar, '業務カレンダー' do |mod|
  ## contents
  mod.content :places, '業務カレンダー'
  
  ## directory
  mod.directory :places, "拠点一覧"
  
  ## pages
  #mod.page
  
  ## pieces
  #mod.piece :daily_links, "日別リンク"
  #mod.piece :holidays, "休日一覧"
  #mod.piece :bussiness_times, "本日の業務時間"
end
