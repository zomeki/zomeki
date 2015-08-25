class Tool::ConvertSetting < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Auth::Manager

  GROUP_RELATION_OPTIONS = [['グループIDと照合', 0], ['グループ名と照合', 1], ['グループ名英語表記と照合', 2]]

  validates_uniqueness_of :site_url
  validates_presence_of :site_url, :title_tag, :body_tag

  def title_xpath
    Tool::Convert::Common.convert_to_xpath(title_tag)
  end

  def body_xpath
    Tool::Convert::Common.convert_to_xpath(body_tag)
  end

  def updated_at_xpath
    Tool::Convert::Common.convert_to_xpath(updated_at_tag)
  end

  def category_xpath
    Tool::Convert::Common.convert_to_xpath(category_tag)
  end

  def relate_url_to_group_code?
    creator_group_relation_type.to_i == 0
  end

  def relate_url_to_group_name?
    creator_group_relation_type.to_i == 1
  end

  def relate_url_to_group_name_en?
    creator_group_relation_type.to_i == 2
  end

  def creator_group_url_relations_map
    return @creator_group_url_relations_map if @creator_group_url_relations_map
    @creator_group_url_relations_map = {}
    creator_group_url_relations.to_s.split(/\r\n|\n|\r/).each do |l|
      l =~ /^(.*?)>(.*?)$/
      break if $1 == nil || $2 == nil
      bef = $1
      aft = $2
      @creator_group_url_relations_map[bef] = aft
    end
    @creator_group_url_relations_map
  end

end
