# encoding: utf-8

namespace :gp_article do
  task :set_user_and_group do
    Core.user       = Sys::User.first
    Core.user_group = Core.user.group
  end

  namespace :load do
    desc 'Load documents.'
    task(:documents =>  [:environment, :set_user_and_group]) do
      next if (content_id = ENV['content_id'].to_i).zero?

      documents = YAML.load_file(Rails.root.join("tmp/gp_article_#{content_id}_documents.yml"))
      documents.each do |document|
        category_type = GpArticle::Content::Doc.find_by_id(content_id).gp_category.category_types.find_by_name('categories')
        doc = GpArticle::Doc.create!(content_id: content_id,
                                     title: document[:title],
                                     body: document[:body])
        doc.category_ids = document[:category_names].split(',').map {|cn| category_type.categories.find_by_name(cn).try(:id) }
      end
    end
  end
end
