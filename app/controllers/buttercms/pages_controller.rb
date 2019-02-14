class Buttercms::PagesController < Buttercms::BaseController

  def index
    @pages = ButterCMS::Page.list('casestudy', :page => params[:page], :page_size => 4)
    @paginatable_array = Kaminari.paginate_array([], total_count: @pages.meta.count).page(params[:page]).per(4)
  end

  def show
    @case_study_page = ButterCMS::Page.get('*', params[:slug]).data
  end

end
