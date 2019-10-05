require 'active_support/concern'

module SeoLinks
  extend ActiveSupport::Concern

  def retrieve_canonical_url
    @canonical = "#{retrieve_production_host}#{request.fullpath}"
  end

  def retrieve_prev_next_url
    if Rails.cache.exist?("next_prev_pagination/#{request.url}")
      @pagination = Rails.cache.fetch("next_prev_pagination/#{request.url}")
    end
  end

  def public_next_prev_links(paginateable_array = nil, action_path = nil, category = nil)
    if paginateable_array.present?
      base_path = "#{retrieve_production_host}#{action_path}?page="
      tag = category.present? ? "&tag=#{category}" : ''
      prev_url = paginateable_array.prev_page.present? ? "#{base_path}#{paginateable_array.prev_page}#{tag}" : nil
      next_url = paginateable_array.next_page.present? ? "#{base_path}#{paginateable_array.next_page}#{tag}" : nil
      @pagination = cache_content("next_prev_pagination/#{request.url}", 24.hours) do
        @pagination = OpenStruct.new({prev: prev_url, next: next_url})
      end
    end
  end

  def blog_next_prev_links(paginateable_array = nil, action_path=nil)
    base_path = "#{retrieve_production_host}#{action_path}/page/"
    prev_url = paginateable_array.prev_page.present? ? "#{base_path}#{paginateable_array.prev_page}" : nil
    next_url = paginateable_array.next_page.present? ? "#{base_path}#{paginateable_array.next_page}" : nil
    @pagination = OpenStruct.new({prev: prev_url, next: next_url})
  end

  protected

  def retrieve_production_host
    'https://mightysignal.com'
  end

  def cache_content(key, expires)
    Rails.cache.fetch(
        key,
        expires_in: expires
    ) do
      yield
    end
  end

end