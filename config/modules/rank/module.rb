# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :rank, 'アクセスランキング' do |mod|
  ## contents
  mod.content :ranks, 'アクセスランキング'

  ## directories
  mod.directory :previous_days, '前日'
  mod.directory :last_weeks, '先週（月曜日〜日曜日）'
  mod.directory :last_months, '先月'
  mod.directory :this_weeks, '週間（前日から一週間）'

  ## pieces
  mod.piece :ranks, 'アクセスランキング一覧'
end
