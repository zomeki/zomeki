# encoding: utf-8
namespace :zomeki do
  namespace :cms do
    desc 'Clean static files'
    task(:clean_statics => :environment) do
      clean_feeds
      clean_statics('r')
      clean_statics('mp3')
      clean_pagings
    end

    desc 'Clean empty directories'
    task(:clean_directories => :environment) do
      clean_directories(Rails.root.join('sites'))
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

def clean_feeds
  Dir[Rails.root.join('sites/**/{feed,index}.{atom,rss}')].each do |file|
    info_log "DELETED: #{file}"
    File.delete(file)
  end
end

def clean_statics(base_ext)
  Dir[Rails.root.join("sites/**/*.html.#{base_ext}")].each do |base_file|
    ['', '.r', '.mp3'].each do |ext|
      next unless File.exist?(file = base_file.sub(Regexp.new("\.#{base_ext}$"), ext))
      info_log "DELETED: #{file}"
      File.delete(file)
    end
  end
end

def clean_pagings
  Dir[Rails.root.join('sites/**/*.p?.html')].each do |base_file|
    info_log "DELETED: #{base_file}"
    File.delete(base_file)

    next unless File.exist?(file = base_file.sub(/\.p\d+\.html\z/, '.html'))
    info_log "DELETED: #{file}"
    File.delete(file)
  end
end

def clean_directories(directory)
  return unless directory.directory?
  directory.each_child do |child|
    clean_directories(child)
  end
  return unless directory.children.empty?
  info_log "DELETED: #{directory}"
  directory.delete
end
