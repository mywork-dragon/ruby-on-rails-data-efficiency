class Api::SavedSearchesController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_action :set_current_user, :authenticate_request

  def get_saved_searches
    render json: @current_user.saved_searches.select(:id, :name, :search_params, :version)
  end

  def create_new_saved_search
    search_name = params['name']
    search_params = params['queryString']
    version = params['version']
    render json: @current_user.saved_searches.create(name: search_name, search_params: search_params, version: version)
  end

  def edit_saved_search
    saved_search = SavedSearch.find(params['id'])
    saved_search.update_attribute(:search_params, params['queryString'])
    render json: saved_search
  end

  def delete_saved_search
    id = params['id']
    saved_search = SavedSearch.find(id)
    saved_search.destroy
    render json: saved_search
  end
end
