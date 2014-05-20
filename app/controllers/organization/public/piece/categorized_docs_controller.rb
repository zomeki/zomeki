class Organization::Public::Piece::CategorizedDocsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Organization::Piece::CategorizedDoc.where(id: Page.current_piece.id).first
    render :text => '' unless @piece

    @item = Page.current_item
  end

  def index
    case @item
    when Organization::Group
      content = @piece.content
      settings = GpArticle::Content::Setting.arel_table
      article_contents = GpArticle::Content::Doc.joins(:settings)
                                                .where(settings[:name].eq('organization_content_group_id')
                                                       .and(settings[:value].eq(content.id)))
                                                .where(site_id: content.site.id)

      @docs = if article_contents.empty?
                GpArticle::Doc.none
              else
                sys_group_ids = @item.public_descendants.map{|g| g.sys_group.id }
                find_public_docs_with_group_id(sys_group_ids)
                  .where(content_id: article_contents.pluck(:id))
                  .order(@item.docs_order)
              end

      categorizations = GpCategory::Categorization.arel_table
      @docs = @docs.joins(:categorizations).where(categorizations[:categorized_as].eq('GpArticle::Doc')
                                                  .and(categorizations[:category_id].in(@piece.category_ids)))
    else
      render :text => ''
    end
  end

  private

  def find_public_docs_with_group_id(group_id)
    GpArticle::Doc.all_with_content_and_criteria(nil, group_id: group_id).mobile(::Page.mobile?).public
  end
end
