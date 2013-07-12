# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :gp_calendar, '汎用カレンダー' do |mod|
  ## contents
  mod.content :events, '汎用カレンダー'

  ## directories
  mod.directory :events, 'イベント一覧'
  mod.directory :todays_events, '今日のイベント'

  ## pieces
  mod.piece :monthly_links, '月別リンク'
  mod.piece :daily_links, '日別リンク'
end
