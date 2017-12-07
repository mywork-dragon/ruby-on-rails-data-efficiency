class Api::ListsController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_action :set_current_user, :authenticate_request

  def get_lists
    render json: @current_user.lists
  end

  # Get a list, given a user_id and list_id
  def get_list
    list_id = params['listId']

    if ListsUser.where(user_id: @current_user.id, list_id: list_id).empty?
      render json: {:error => "not user's list"}
      return
    end

    list = List.find(list_id)

    page = params[:page] || 1
    per_page = 100

    listables_lists = list.listables_lists
    results = listables_lists.page(params[:page]).per(per_page).map(&:listable)

    render json: {:resultsCount => listables_lists.size, :currentList => list_id, :results => results.as_json({user: @current_user})}
  end

  def export_list_to_csv
    list_id = params['listId']
    list = List.find(list_id)

    ios_apps = list.ios_apps
    android_apps = list.android_apps
    apps = []

    header = csv_header

    ios_apps.each do |app|
      apps << app.to_csv_row
    end

    android_apps.each do |app|
      apps << app.to_csv_row
    end

    list_csv = CSV.generate do |csv|
      csv << header
      apps.each do |app|
        csv << app
      end
    end

    send_data list_csv

  end

  def create_new_list
    list_name = params['listName']

    render json: @current_user.lists.create(name: list_name)

    # render json: List.find(authenticated_user.id).find(list_name)

  end

  def add_to_list
    list_id = params['listId']
    apps = params['apps']
    app_platform = params['appPlatform']

    if ListsUser.where(user_id: @current_user.id, list_id: list_id).empty?
      render json: {:error => "not user's list"}
      return
    end

    if app_platform == 'ios'
      listable_type = 'IosApp'
    else
      listable_type = 'AndroidApp'
    end

    apps.each { |app|
      if ListablesList.find_by(listable_id: app['id'], list_id: list_id, listable_type: listable_type).nil?
        ListablesList.create(listable_id: app['id'], list_id: list_id, listable_type: listable_type)
      end
    }

    render json: {:status => 'success'}
  end

  def add_mixed_to_list
    list_id = params['listId']
    apps = params['apps']

    if ListsUser.where(user_id: @current_user.id, list_id: list_id).empty?
      render json: {:error => "not user's list"}
      return
    end

    apps.each { |app|
      if ListablesList.find_by(listable_id: app['id'], list_id: list_id, listable_type: app['type']).nil?
        ListablesList.create(listable_id: app['id'], list_id: list_id, listable_type: app['type'])
      end
    }

    render json: {:status => 'success'}
  end

  def delete_from_list
    list_id = params['listId']
    apps = params['apps']

    if ListsUser.where(user_id: @current_user.id, list_id: list_id).empty?
      render json: {:error => "not user's list"}
      return
    end

    apps.each { |app| ListablesList.find_by(listable_id: app['id'], list_id: list_id, listable_type: app['type']).destroy }

    render json: {:status => 'success'}
  end

  def delete_list
    list_id = params['listId']

    if ListsUser.where(user_id: @current_user.id, list_id: list_id).empty?
      render json: {:error => "not user's list"}
      return
    end

    List.find(list_id).destroy

    render json: {:status => 'success'}
  end
end
