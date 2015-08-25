# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :biz_calendar, '業務カレンダー' do |mod|
  ## contents
  mod.content :places, '業務カレンダー'
  
  ## directory
  mod.directory :places, "拠点一覧"
  
  ## pages
  #mod.page
  
  ## pieces
  mod.piece :calendars, "休業日カレンダー"
  mod.piece :bussiness_holidays, "休業日一覧"
  mod.piece :bussiness_times, "業務時間"
end
