# encoding: utf-8

namespace :zomeki do
  namespace :article do
    task :set_user_and_group do
      Core.user       = Sys::User.first
      Core.user_group = Core.user.group
    end

    namespace :save do
      desc 'Save categories.'
      task(:categories => :environment) do
        next if (content_id = ENV['content_id'].to_i).zero?

        categories = Article::Category.unscoped.where(content_id: content_id, parent_id: 0).map {|c| descendants_to_hash(c) }

        File.write(Rails.root.join("tmp/article_#{content_id}_categories.yml"), YAML.dump(categories))
      end

      desc 'Save documents.'
      task(:documents => :environment) do
        next if (content_id = ENV['content_id'].to_i).zero?

        documents = Article::Doc.unscoped.where(content_id: content_id).map do |document|
            {title: document.title,
             body: document.body,
             published_at: document.published_at,
             category_names: document.category_items.map{|ci| ci.name }.join(',')}
          end

        File.write(Rails.root.join("tmp/article_#{content_id}_documents.yml"), YAML.dump(documents))
      end
    end

    namespace :load do
      desc 'Load categories.'
      task(:categories => [:environment, :set_user_and_group]) do
        next if (content_id = ENV['content_id'].to_i).zero?

        categories = YAML.load_file(Rails.root.join("tmp/article_#{content_id}_categories.yml"))
        categories.each {|c| descendants_from_hash(c, content_id, 0) }
      end
    end
  end
end

def descendants_to_hash(category)
  children = category.children.map {|c| descendants_to_hash(c) }

  {state: category.state,
   concept_id: category.concept_id,
   layout_id: category.layout_id,
   name: category.name,
   title: category.title,
   level_no: category.level_no,
   sort_no: category.sort_no,
   children: children}
end

def descendants_from_hash(category, content_id, parent_id)
  parent = Article::Category.new(content_id: content_id,
                                 parent_id: parent_id,
                                 state: category[:state],
                                 concept_id: category[:concept_id],
                                 layout_id: category[:layout_id],
                                 name: category[:name],
                                 title: category[:title],
                                 level_no: category[:level_no],
                                 sort_no: category[:sort_no])
  if parent.save
    unless category[:children].empty?
      category[:children].each {|c| descendants_from_hash(c, content_id, parent.id) }
    end
  else
    p parent.errors
  end
end
