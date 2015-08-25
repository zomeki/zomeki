# encoding: utf-8
class Cms::DataFile < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::File
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept

  belongs_to :status , :foreign_key => :state     , :class_name => 'Sys::Base::Status'
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :site   , :foreign_key => :site_id   , :class_name => 'Cms::Site'
  belongs_to :node   , :foreign_key => :node_id   , :class_name => 'Cms::DataFileNode'

  after_destroy :remove_public_file

  def self.find_by_public_path(path)
    path =~ /sites\/.*\/(.*?)\/public\/_files\/.*\/(.*?)\/(.*?)$/i
    _site_id = $1.to_i rescue 0;
    _id      = $2[0 .. -2].to_i rescue 0;
    _name    = $3
    Cms::DataFile.where(:id => _id, :name => _name, :site_id => _site_id).first
  end

  def public_path
    return nil unless site
    dir = Util::String::CheckDigit.check(format('%07d', id)).gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
    "#{site.public_path}/_files/#{dir}/#{escaped_name}"
  end

  def public_uri
    dir = Util::String::CheckDigit.check(format('%07d', id))
    "/_files/#{dir}/#{escaped_name}"
  end

  def public_full_uri
    "#{site.full_uri}#{public_uri.sub(/^\//, '')}"
  end

  def public
    self.and :state, 'public'
    self
  end

  def publishable?
    return false unless editable?
    return !public?
  end

  def closable?
    return false unless editable?
    return public?
  end

  def public?
    return published_at != nil
  end

  def publish(options = {})
    unless FileTest.exist?(upload_path)
      errors.add_to_base 'ファイルデータが見つかりません。'
      return false
    end
    self.state        = 'public'
    self.published_at = Core.now
    return false unless save(:validate => false)
    remove_public_file
    return upload_public_file
  end

  def close
    self.state        = 'closed'
    self.published_at = nil
    return false unless save(:validate => false)
    return remove_public_file
  end

  def duplicated?
    file = self.class.new
    file.and :id, "!=", id if id
    file.and :concept_id, concept_id
    file.and :name, name
    if node_id
      file.and :node_id, node_id
    else
      file.and :node_id, 'IS', nil
    end
    return file.find(:first) != nil
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_node_id'
        self.and :node_id, v
      end
    end if params.size != 0

    return self
  end

  def remove_public_file
    return true unless FileTest.exist?(public_path)
    FileUtils.remove_entry_secure(public_path)
    return true
  end

private
  def upload_public_file
    return false unless FileTest.exist?(upload_path)
    Util::File.put(public_path, :src => upload_path, :mkdir => true)
  end
end
