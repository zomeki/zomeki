# encoding: utf-8
module Sys::Model::Rel::File
  def self.included(mod)
    mod.has_many :files, :foreign_key => 'parent_unid', :class_name => 'Sys::File',
      :primary_key => 'unid', :dependent => :destroy
    
    mod.before_save :publish_files
    mod.before_save :close_files
  end
  
  ## Remove the temporary flag.
  def fix_tmp_files(tmp_id)
    Sys::File.fix_tmp_files(tmp_id, unid)
    return true
  end
  
  def public_files_path
    "#{::File.dirname(public_path)}/files"
  end
  
  def publish_files
    return true unless @save_mode == :publish
    return true if files.size == 0
    
    dir = public_files_path
    FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
    
    files.each do |file|
      next unless FileTest.exist?(file.upload_path)
      new_file = dir + '/' + file.name
      if FileTest.exist?(new_file)
        if File::stat(new_file).mtime >= File::stat(file.upload_path).mtime
          next
        end
      end
      FileUtils.cp(file.upload_path, dir + '/' + file.name) if FileTest.exist?(file.upload_path)
    end
    return true
  end
  
  def close_files
    return true unless @save_mode == :close
    
    dir = public_files_path
    FileUtils.rm_r(dir) if FileTest.exist?(dir)
    return true
  end
end