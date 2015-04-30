# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# set :environment, 'development'

set :output, nil

env :PATH, ENV['PATH']

# http://rubygems.org/gems/delayed_job_active_record
every 3.minutes do
  rake 'jobs:workoff'
end

# 記事の公開/非公開処理を行います。
every '0-45/15 * * * *' do
  rake 'zomeki:sys:tasks:exec'
end

# トップページや中間ページを静的ファイルとして書き出します。
every '3-48/15 * * * *' do
  rake 'zomeki:cms:nodes:publish'
end

# 音声ファイルを静的ファイルとして書き出します。
every '6-51/15 * * * *' do
  rake 'zomeki:cms:talks:exec'
end

# 新着記事ポータルで設定したAtomフィードを取り込みます。
every :hour do
  rake 'zomeki:cms:feeds:read'
end

# アクセスランキングデータを取り込みます。
every :day, at: '3:00 am' do
  rake 'zomeki:rank:ranks:exec'
end

# 汎用アンケートの回答データを取り込みます。
every '9-54/15 * * * *' do
  rake 'zomeki:survey:answers:pull'
end

# 今日のイベントページを静的ファイルとして書き出します。
every :day, at: '0:30 am' do
  rake 'zomeki:gp_calendar:publish_todays_events'
end
