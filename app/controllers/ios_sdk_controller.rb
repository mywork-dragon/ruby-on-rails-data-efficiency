class IosSdkController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_admin_account

  class BadRequest < RuntimeError; end

  def validate
    data = params.fetch('ios_sdk') # Rails autowraps inbound JSON into 'ios_sdk' root
    name = data.fetch('name')
    raise BadRequest, "SDK #{name} already exists" if IosSdk.find_by_name(name).present?

    website = data.fetch('website')

    classes = data.fetch('classes')
    existing = IosClassificationHeader.where(name: classes).pluck(:name)
    raise BadRequest, "Classes already taken: #{existing.join(', ')}" if existing.present?

    render json: {status: 'ok'}, status: 200
  end

  def create
    data = params.fetch('ios_sdk')
    name = data.fetch('name')
    classes = data.fetch('classes')
    website = data.fetch('website')

    summary = data['summary']
    sdk = IosSdk.create_manual(name: name, website: website, summary: summary, kind: :native)
    classes = classes.class == String ? classes.split.uniq : classes.uniq
    classes.map { |c| IosSdkSourceData.create!(name: c, ios_sdk_id: sdk.id) }

    render json: sdk, status: 201
  end

  def athena_query
    ids = params.fetch('ios_sdk_ids').split(',').map(&:to_i)
    q = IosSdk.gen_athena_query(ids)
    render json: { query: q }, status: 200
  end

  rescue_from BadRequest, KeyError do |exception|
    render json: { error: exception.message }, status: 400
  end
end
