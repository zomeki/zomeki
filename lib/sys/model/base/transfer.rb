module Sys::Model::Base::Transfer
  def self.included(base)
    base.belongs_to :site, :class_name => 'Cms::Site'
    base.belongs_to :user, :class_name => 'Sys::User'
  end

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
    file_type.to_s == 'file'
  end

  def item_info(attr)
    return @item_info[attr] || '-' if @item_info

    if pub = Sys::Publisher.where(:path => "#{parent_dir}#{path}").order('id DESC').first
      if log = Sys::OperationLog.where(:item_unid => pub.unid).order('id DESC').first
        @item_info = {}
        @item_info[:item_id]      = log.item_id
        @item_info[:item_unid]    = log.item_unid
        @item_info[:item_model]   = log.item_model
        @item_info[:item_name]    = log.item_name
        @item_info[:operated_at]  = log.created_at
        @item_info[:operator_id]  = log.user_id
        @item_info[:operator_name] = log.user_name
        return @item_info[attr] || '-'
      end
    end
    '-'
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_version'
        self.and :version, v
      when 's_operation'
        self.and :operation, v
      when 's_file_type'
        self.and :file_type, v
      when 's_path'
        self.and 'path', 'LIKE', "%#{v.gsub(/([%_])/, '\\\\\1')}%"
      when 's_item_name'
        self.and 'item_name', 'LIKE', "%#{v.gsub(/([%_])/, '\\\\\1')}%"
      when 's_operator_name'
        self.and 'operator_name', 'LIKE', "%#{v.gsub(/([%_])/, '\\\\\1')}%"
      end
    end if params.size != 0

    return self
  end

  module_function :operations
  module_function :file_types
end
