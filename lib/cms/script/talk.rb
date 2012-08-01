class Cms::Script::Talk
  def self.make
    options = {:agent => "#{self}.add_paths"}
    @@log1 = Sys::Lib::Logger::Date.new(:cms_add_talk_paths, options)
    
    unless @@lock = lock_process
      @@log1.close("Already executing.")
      return false 
    end
    
    add_paths
    @@lock.updated_at = Time.now.to_s(:db)
    @@lock.save
    
    options = {:agent => "#{self}.make_sound_files"}
    @@log2 = Sys::Lib::Logger::Date.new(:cms_make_sound_files, options)
    
    make_sound_files
    @@lock.destroy
  end
  
protected
  def self.lock_process
    lock_key = '#making'
    if lock = Cms::TalkTask.find_by_path(lock_key)
      if lock.updated_at.strftime('%s').to_i + (60 * 10) < Time.now.strftime('%s').to_i
        lock.destroy
      else
        return nil
      end
    end
    lock = Cms::TalkTask.new(:site_id => 0, :path => lock_key, :uri => lock_key)
    return nil unless lock.save
    return lock
  end
  
  ## add sound paths.
  def self.add_paths
    root = Cms::Node.find(1)
    @@added = 0
    add_paths_by_node(root)
    
    @@log1.close("Finished. Added: #{@@added}")
  end
  
  def self.add_paths_by_node(node)
    if node.parent_id == 0 || (node.content_id != nil && node.controller != 'nodes')
      require 'site'
      Core.set_site(node.site)
      
      params = {
        :site_id    => node.site_id,
        :content_id => node.content_id,
        :controller => node.controller,
        :path       => node.public_path,
        :uri        => node.public_uri,
        :regular    => 1
      }
      if Cms::TalkTask.add(params)
          @@log1.puts("add: #{params[:site_id]}, #{params[:uri]}, #{params[:path]}")
          @@added += 1
      end
    end
    
    node.children.each do |child|
      add_paths_by_node(child) if child.public?
    end
  end
  
  ## make sound files.
  def self.make_sound_files
    success = 0
    error   = 0
    
    ## find tasks
    cond = ['site_id != 0']
    tasks = Cms::TalkTask.find(:all, :conditions => cond, :order => 'regular DESC, id')
    if tasks.size == 0
      @@log2.close("Finished. No tasks.")
      return true
    end
    
    require 'site'
    
    ## make
    count = 0
    tasks.each_with_index do |task, idx|
      begin
        count += 1
        if count % 50 == 0
          GC.start
        end
        
        @@log2.puts("make: #{task.id}, #{task.site_id}, #{task.uri}")
        #@@log2.puts("make: #{task.id}, #{task.site_id}, #{task.uri}, #{task.sound_path}")
        #@@log2.puts("make: #{task.id}, #{task.site_id}, #{task.content_uri}, #{task.sound_path}")
        
        unless content = task.read_content
          raise 'ReadContentError'
        end
        
        if task.regular == 1 && task.content == content && FileTest.exist?(task.sound_path)
          @@log2.puts(" => No changed.")
          next
        end
        file = task.make_sound(content)
        if !file || File::stat(file[:path]).size == 0
          raise 'MakeSoundError'
        end
        
        dir = ::File.dirname(task.sound_path)
        FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
        FileUtils.mv(file[:path], task.sound_path)
        ::File.chmod(0644, task.sound_path)
        task.content = content
        task.result  = 'success'
        task.terminate
        
        success += 1
        @@log2.puts(" => Success.")
        
      #rescue NotImplementedError
      #  success += 1
      rescue => e
        @@log2.puts(" => #{e}")
        if task.result == 'error'
          FileUtils.rm(task.sound_path) if FileTest.exist?(task.sound_path)
          task.destroy
        else
          task.result = 'error'
          task.terminate
        end
        error += 1
      end
      
      @@lock.updated_at = Time.now.to_s(:db)
      @@lock.save
    end
    
    if error > 0
      @@log2.close("Finished. Made: #{success}, Error: #{error}")
    else
      @@log2.close("Finished. Made: #{success}")
    end
  end
end
