class Sys::TransferredFile < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :site, :class_name => 'Cms::Site'

  def operations
    [['作成','create'],['更新','update'],['削除','delete']]
  end

  def operation_label
    operations.each {|a| return a[0] if a[1] == operation }
    return nil
  end

  def file_types
    [['ディレクトリ','directory'],['ファイル','file']]
  end

  def file_type_label
    file_types.each {|a| return a[0] if a[1] == file_type }
    return nil
  end

  def file?
    file_type == 'file'
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_version'
        self.and :version, v
      when 's_operation'
        self.and :operation, v
      when 's_path'
        self.and 'path', 'LIKE', "%#{v.gsub(/([%_])/, '\\\\\1')}%"
      end
    end if params.size != 0

    return self
  end

end
