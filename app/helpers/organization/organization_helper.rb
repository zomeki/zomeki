module Organization::OrganizationHelper
  def group_li(group, depth_limit: 1000, depth: 1)
    content_tag(:li) do
      result = link_to(group.sys_group.name, group.public_uri)
      if group.public_children.empty? || depth >= depth_limit
        result
      else
        result << content_tag(:ul) do
            group.public_children.inject(''){|lis, child|
              lis << group_li(child, depth_limit: depth_limit, depth: depth + 1)
            }.html_safe
          end
      end
    end
  end
end
