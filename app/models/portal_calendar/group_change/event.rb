# encoding: utf-8
class Calendar::GroupChange::Event < Sys::GroupChangeItem

  belongs_to :entity,   :foreign_key => :item_id,      :class_name => 'Calendar::Event'

  def entity_cls_name
    Calendar::Event.name
  end


  def pull(change, setting)
    return unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')

    t = target_cols(setting)
    return if t.size == 0

    item = Calendar::Event.new
    item.or 'title', 'LIKE', "%#{change.old_name}%" if t.include?('title')
    item.order "content_id, updated_at DESC"

    events = item.find(:all)
    transcribe_data events
  end


  def synchronize(changes, setting)
    t = target_cols(setting)
    return if t.size == 0

    self.class.find(:all, :conditions => { :model => entity_cls_name } , :order => 'id').each do |temp|
      if org = temp.entity
        changes.each do |change|
          next unless (change.change_division == 'rename' || change.change_division == 'move' || change.change_division == 'integrate')

          org.title = org.title.gsub(/#{change.old_name}/, change.name) if org.title && t.include?('title')
        end
      end
      begin
        org.save(false)
      rescue
      end if org.changed?

    end
  end

end