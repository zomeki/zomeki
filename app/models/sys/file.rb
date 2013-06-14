class Sys::File < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::File
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  
  #validates_presence_of :name
  
  ## garbage collect
  def self.garbage_collect
    conditions = Condition.new
    conditions.and :tmp_id, 'IS NOT', nil
    conditions.and :parent_unid, 'IS', nil
    conditions.and :created_at, '<', (Date.strptime(Core.now, "%Y-%m-%d") - 2)
    destroy_all(conditions.where)
  end
  
  ## Remove the temporary flag.
  def self.fix_tmp_files(tmp_id, parent_unid)
    updates = {:parent_unid => parent_unid, :tmp_id => nil }
    conditions = ["parent_unid IS NULL AND tmp_id = ?", tmp_id]
    update_all(updates, conditions)
  end

  def duplicated
    c_tmp_id, c_parent_unid = (tmp_id ? [tmp_id, nil] : [nil, parent_unid])

    files = self.class.arel_table

    self.class.where(name: name).where(files[:id].not_eq(id).and(files[:tmp_id].eq(c_tmp_id))
                                                            .and(files[:parent_unid].eq(c_parent_unid))).first
  end

  def duplicated?
    !!duplicated
  end
end
