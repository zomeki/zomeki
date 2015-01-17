#!/usr/bin/env ruby
DONE_FLAG = "/tmp/#{$0}_done"

puts '#### Configure ZOMEKI ####'
exit if File.exist?(DONE_FLAG)
puts '-- PRESS ENTER KEY --'
gets

require 'fileutils'
require 'yaml/store'

def ubuntu
  puts 'Ubuntu will be supported shortly.'
end

def centos
  puts "It's CentOS!"

  core_yml = '/var/share/zomeki/config/core.yml'
  FileUtils.copy("#{core_yml}.sample", core_yml, preserve: true)

  db = YAML::Store.new(core_yml)
  db.transaction do
    db['production']['uri'] = "http://#{`hostname`.chomp}/"
  end

  sns_apps_yml = '/var/share/zomeki/config/sns_apps.yml'
  FileUtils.copy("#{sns_apps_yml}.sample", sns_apps_yml, preserve: true)

  sites_conf = '/var/share/zomeki/config/virtual-hosts/sites.conf'
  FileUtils.copy("#{sites_conf}.sample", sites_conf, preserve: true)

  zomeki_conf = '/var/share/zomeki/config/virtual-hosts/zomeki.conf'
  FileUtils.copy("#{zomeki_conf}.sample", zomeki_conf, preserve: true)

  File.open(zomeki_conf, File::RDWR) do |f|
    f.flock(File::LOCK_EX)

    conf = f.read

    f.rewind
    f.write conf.sub(/(?<= ServerName ).+$/) {|m| `hostname`.chomp }
    f.flush
    f.truncate(f.pos)

    f.flock(File::LOCK_UN)
  end

  system "ln -s #{zomeki_conf} /etc/httpd/conf.d/zomeki.conf"
  system 'service mysqld start'
  sleep 1 until system 'mysqladmin ping' # Not required to connect
  system "su - zomeki -c 'cd /var/share/zomeki && bundle exec rake db:setup RAILS_ENV=production'"
  system 'service mysqld stop'
end

def others
  puts 'This OS is not supported.'
  exit
end

if __FILE__ == $0
  if File.exist? '/etc/centos-release'
    centos
  elsif File.exist? '/etc/lsb-release'
    unless `grep -s Ubuntu /etc/lsb-release`.empty?
      ubuntu
    else
      others
    end
  else
    others
  end

  system "touch #{DONE_FLAG}"
end
