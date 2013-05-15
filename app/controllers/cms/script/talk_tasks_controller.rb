# encoding: utf-8
require 'digest/md5'
class Cms::Script::TalkTasksController < Cms::Controller::Script::Publication
  def exec
    Cms::TalkTask.find(:all, :select => :id, :order => "id").each do |v|
      task = Cms::TalkTask.find_by_id(v[:id])
      next unless task
      
      begin
        if ::File.exist?(task.path)
          rs = make_sound(task)
        else
          rs = true
        end
        task.destroy
        raise "MakeSoundError" unless rs
      rescue Exception => e
        puts "#{e}: #{task.path}"
        #error_log "#{e} #{task.path}"
      end
    end
    render :text => "OK"
  end
  
  def make_sound(task)
    content = ::File.new(task.path).read
    #hash = Digest::MD5.new.update(content.to_s).to_s
    #return true if hash == task.content_hash && ::File.exist?("#{task.path}.mp3")
    
    gtalk = Cms::Lib::Navi::Gtalk.new
    gtalk.make(content)
    mp3 = gtalk.output
    return false unless mp3
    return false if ::File.stat(mp3[:path]).size == 0
    FileUtils.mv(mp3[:path], "#{task.path}.mp3")
    ::File.chmod(0644, "#{task.path}.mp3")
    return true
  end
end
