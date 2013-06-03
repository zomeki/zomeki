# encoding: utf-8

namespace :zomeki do
  namespace :gp_category do
    namespace :load do
      desc 'Load categories.'
      task(:categories => :environment) do
        next if (content_id = ENV['content_id'].to_i).zero?

        Core.user       = Sys::User.first
        Core.user_group = Core.user.group

        categories = YAML.load_file(Rails.root.join("tmp/gp_category_#{content_id}_categories.yml"))
        categories.each do |category|
          category_type = GpCategory::CategoryType.create!(content_id: content_id,
                                                           concept_id: category[:concept_id],
                                                           layout_id: category[:layout_id],
                                                           state: category[:state],
                                                           name: category[:name],
                                                           title: category[:title],
                                                           sort_no: category[:sort_no])
          category_type.reload
          category[:children].each do |child|
            parent = category_type.categories.create!(concept_id: child[:concept_id],
                                                      layout_id: child[:layout_id],
                                                      parent_id: nil,
                                                      state: child[:state],
                                                      name: child[:name],
                                                      title: child[:title],
                                                      level_no: child[:level_no] - 1,
                                                      sort_no: child[:sort_no],
                                                      description: child[:description])
            child[:children].each do |grandchild|
              descendants_from_hash(grandchild, parent.id, category_type.id)
            end
          end
        end
      end
    end
  end
end

def descendants_from_hash(category, parent_id, category_type_id)
  parent = GpCategory::Category.new(concept_id: category[:concept_id],
                                    layout_id: category[:layout_id],
                                    category_type_id: category_type_id,
                                    parent_id: parent_id,
                                    state: category[:state],
                                    name: category[:name],
                                    title: category[:title],
                                    level_no: category[:level_no] - 1,
                                    sort_no: category[:sort_no],
                                    description: category[:description])
  if parent.save
    unless category[:children].empty?
      category[:children].each {|c| descendants_from_hash(c, parent.id, category_type_id) }
    end
  else
    p parent.errors
  end
end
