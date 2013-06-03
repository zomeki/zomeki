#!/usr/local/bin/ruby
# encoding: utf-8
# $KCODE = 'UTF-8'
require 'nkf'
require 'logger'
require 'shell'

class GtalkFilter
  def initialize
    ENV['PATH'] = ENV['PATH'].split(':').concat(%w!/usr/local/sbin /usr/local/bin!).uniq.join(':')

    dir = File.dirname(__FILE__)
    @chasen   = 'chasen'
    @chasenrc = File.expand_path('./config/chasenrc_gtalk', dir)
    @chaone   = File.expand_path('./morph/chaone/chaone', dir)
    @log_file = File.expand_path('./filter.log', dir)
  end
  
  def execute(text)
    x = ''
    c = exec_chaone('、')
    
    text = NKF.nkf('-w', text)
    text.split(/。/).each do |s|
      s.split(/、/).each do |w|
        t = exec_chaone(w)
        x += c + t if t !~ /pos="unk"/
      end
    end
    
    x.gsub!(/\n+/, "\n")
    return NKF.nkf('-We', "<S>#{x}</S>")
  end
  
  def exec_chaone(str)
    cmd = "echo \"#{str}\" | #{@chasen} -i w -r #{@chasenrc} | #{@chaone} -e UTF-8 -s gtalk"
    res = `#{cmd}`.to_s
    res = NKF.nkf('-Ww', res)
    return '' if $? != 0 || res.slice(0, 1) != '<'
    res.sub!('<S>', '')
    res.sub!('</S>', '')
    res.sub!('<S/>', '')
    return res
  rescue Exception => e
    ''
  end
  
  def log(msg)
    Logger.new(@log_file).debug(msg)
  end
end

begin
  puts GtalkFilter.new.execute($stdin.gets.to_s)
end
