class Buttercms::CaseStudiesController < Buttercms::BaseController

  def index
    @pages = ButterCMS::Page.list('casestudy', :page => params[:page], :page_size => 4)
    @paginatable_array = Kaminari.paginate_array([], total_count: @pages.meta.count).page(params[:page]).per(4)
  end

  def show
    @case_study_page = ButterCMS::Page.get('*', params[:slug]).data
    meta_tag('html_title', @case_study_page.fields.seo_title)
    meta_tag('meta_description', @case_study_page.fields.meta_description)
    meta_tag('path_to_interviewed_person_image', @case_study_page.fields.interviewed_person_image)
    meta_tag('interviewed_person_name', @case_study_page.fields.interviewed_person_name)
  end

end
