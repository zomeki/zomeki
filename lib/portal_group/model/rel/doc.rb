module PortalGroup::Model::Rel::Doc
  def portal_group_is(group)
    conditions = []
    
    if group.category.size > 0
      doc = self.class.new
      doc.portal_category_is(group.category_items)
      conditions << doc.condition
    end
    if group.business.size > 0
      doc = self.class.new
      doc.portal_business_is(group.business_items)
      conditions << doc.condition
    end
    if group.attribute.size > 0
      doc = self.class.new
      doc.portal_attribute_is(group.attribute_items)
      conditions << doc.condition
    end
    if group.area.size > 0
      doc = self.class.new
      doc.portal_area_is(group.area_items)
      conditions << doc.condition
    end
    
    condition = Condition.new
    if group.condition == 'and'
      conditions.each {|c| condition.and(c) if c.where }
    else
      conditions.each {|c| condition.or(c) if c.where }
    end
    
    self.and condition if condition.where
    self
  end
end