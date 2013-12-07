# encoding: utf-8
namespace :zomeki do
  namespace :cms do
    namespace :link_check do
      desc 'Check links.'
      task(:check => :environment) do
        Util::LinkChecker.check
      end
    end

    desc 'Clean static files'
    task(:clean_statics => :environment) do
      clean_feeds
      clean_statics('r')
      clean_statics('mp3')
    end
  end
end

def clean_feeds
  Dir["#{Rails.root.join('sites')}/**/index.{atom,rss}"].each do |file|
    info_log "DELETED: #{file}"
    File.delete(file)
  end
end

def clean_statics(base_ext)
  Dir["#{Rails.root.join('sites')}/**/*.html.#{base_ext}"].each do |base_file|
    ['', '.r', '.mp3'].each do |ext|
      next unless File.exist?(file = base_file.sub(Regexp.new("\.#{base_ext}$"), ext))
      info_log "DELETED: #{file}"
      File.delete(file)
    end
  end
end
