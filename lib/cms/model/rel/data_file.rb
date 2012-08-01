# encoding: utf-8
module Cms::Model::Rel::DataFile
  def self.included(mod)
    #mod.has_one :concept, :primary_key => 'concept_id', :foreign_key => 'id', :class_name => 'Cms::Concept'
    #mod.belongs_to :concept, :foreign_key => 'concept_id', :class_name => 'Cms::Concept'
  end
  
  def cms_data_file(name, params)
    file_id  = send("#{name}_id")
    return file_id ? Cms::DataFile.find_by_id(file_id) : nil
  end
  
  def cms_data_file_uri(name, params)
    file = cms_data_file(name, params)
    return nil unless file
    
    return file.public_uri
  end
  
  def save_cms_data_file(name, params)
    cond = {
      :site_id    => params[:site_id],
      :concept_id => 0,
      :name       => "#{self.class}/#{id}"
    }
    node = Cms::DataFileNode.find(:first, :conditions => cond)
    if !node
      node = Cms::DataFileNode.new(cond)
      node.title = node.name
      return false unless node.save(:validate => false)
    end
    
    if upload = send(name)
      file_id  = send("#{name}_id")
      filename = upload.original_filename.gsub(/^.*?\./, "#{name}.")
      
      file = file_id ? Cms::DataFile.find_by_id(file_id) : nil
      file.remove_public_file if file
      
      file ||= Cms::DataFile.new({
        :state      => 'public',
        :site_id    => node.site_id,
        :node_id    => node.id,
        :concept_id => 0,
        :title      => name.to_s.humanize
      })
      file.name = filename
      file.file = upload
      
      return false unless file.save
      file.publish
      
      if file.id != send("#{name}_id")
        self.send("#{name}_id=", file.id)
        self.class.update(self.id, "#{name}_id" => file.id)
      end
      return true
      
    elsif !send("del_#{name}").blank?
      file_id  = send("#{name}_id")
      if !file_id.blank?
        file = Cms::DataFile.find_by_id(file_id)
        if file
          return false unless file.destroy
          self.send("#{name}_id=", nil)
          self.class.update(self.id, "#{name}_id" => nil)
        end
      end
      return true
    end
    
    return true
  end
  
  def destroy_cms_data_file(name)
    dump "destroy cms data files"
    return true
  end
end