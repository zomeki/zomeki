# encoding: utf-8
namespace :zomeki do
  namespace :cms do
    desc 'Clean static files'
    task(:clean_statics => :environment) do
      Cms::Lib::FileCleaner.clean_files
    end

    desc 'Clean empty directories'
    task(:clean_directories => :environment) do
      Cms::Lib::FileCleaner.clean_directories
    end

    namespace :feeds do
      desc 'Read feeds'
      task(:read => :environment) do
        Script.run('cms/script/feeds/read')
      end
    end

    namespace :link_check do
      desc 'Check links.'
      task(:check => :environment) do
        Util::LinkChecker.check
      end
    end

    namespace :nodes do
      desc 'Publish nodes'
      task(:publish => :environment) do
        Script.run('cms/script/nodes/publish')
      end

      desc 'Publish all nodes'
      task(:publish_all => :environment) do
        Script.run('cms/script/nodes/publish?all=all')
      end
    end

    namespace :talks do
      desc 'Exec talk tasks'
      task(:exec => :environment) do
        Script.run('cms/script/talk_tasks/exec')
      end

      desc 'Clean excluded talk tasks'
      task(:clean_excluded_tasks => :environment) do
        ids = Zomeki.config.application['cms.use_kana_exclude_site_ids'] || []
        Cms::TalkTask.find_each{|t| t.destroy if ids.include?(t.site_id) }
      end
    end
  end
end
