class Buttercms::BaseController < ActionController::Base
  include BlogsHelper

  layout 'buttercms/default'
  before_action :categories
  rescue_from Net::OpenTimeout, :with => :handle_open_timeout


  protected

  def handle_open_timeout
    flash[:alert] = "Something went wrong :( Please, try again."
    request.env["HTTP_REFERER"].present? ? redirect_to(:back) : redirect_to(buttercms_blog_path)
  end

  private

  def categories
    @categories = ButterCMS::Category.all
  end

  def view_context
    @_view_context ||= super
  end

end
