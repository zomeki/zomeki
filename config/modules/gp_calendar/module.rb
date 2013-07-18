# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :gp_calendar, '汎用カレンダー' do |mod|
  ## contents
  mod.content :events, '汎用カレンダー'

  ## directories
  mod.directory :events, 'イベント一覧'
  mod.directory :todays_events, '今日のイベント'
  mod.directory :calendar_styled_events, 'イベントカレンダー'

  ## pieces
  mod.piece :monthly_links, '月別リンク'
  mod.piece :daily_links, '日別リンク'
  mod.piece :category_types, '汎用カテゴリ一覧'
end
