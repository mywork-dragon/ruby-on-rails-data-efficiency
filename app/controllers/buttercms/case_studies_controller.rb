class Buttercms::CaseStudiesController < Buttercms::BaseController

  def index
    @pages = ButterCMS::Page.list('casestudy', :page => params[:page], :page_size => 4)
    @paginatable_array = Kaminari.paginate_array([], total_count: @pages.meta.count).page(params[:page]).per(4)
  end

  def show
    @case_study_page = ButterCMS::Page.get('*', params[:slug]).data
    view_context.content_for :html_title, @case_study_page.fields.seo_title
    view_context.content_for :meta_description, @case_study_page.fields.meta_description
  end

end
