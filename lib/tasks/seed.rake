# encoding: utf-8

namespace :db do
  namespace :seed do
    task :demo => :environment do
      load "#{Rails.root}/db/seed/demo.rb"
    end
  end
end