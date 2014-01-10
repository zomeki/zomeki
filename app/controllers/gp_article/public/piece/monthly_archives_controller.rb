class GpArticle::Public::Piece::MonthlyArchivesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpArticle::Piece::MonthlyArchive.find_by_id(Page.current_piece.id)
    return render(text: '') unless @piece

    @node = @piece.content.public_archives_node
    return render(text: '') unless @node
  end

  def index
    @monthly_num_docs = @piece.content.public_docs
                              .group("DATE_FORMAT(display_published_at,'%Y-%m')").count
  end
end
