# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :gp_calendar, '汎用カレンダー' do |mod|
  ## contents
  mod.content :events, '汎用カレンダー'

  ## directories
  mod.directory :events, 'イベント一覧'
end
