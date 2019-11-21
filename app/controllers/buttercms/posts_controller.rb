class Buttercms::PostsController < Buttercms::BaseController
  include SeoLinks

  before_action :retrieve_canonical_url
  before_action :retrieve_prev_next_url, only: :index

  def index
    @current_slug = params[:category]
    @current_search = params[:search]
    search_options = {:page => params[:page], :page_size => 4, :exclude_body => true}
    if params.include?(:search)
      @posts = ButterCMS::Post.search(@current_search, search_options)
    else
      search_options[:category_slug] = @current_slug if @current_slug
      @posts = ButterCMS::Post.all(search_options)
    end

    @paginatable_array = Kaminari.paginate_array([], total_count: @posts.meta.count).page(params[:page]).per(4)
    blog_next_prev_links(@paginatable_array, buttercms_posts_path)

    if @posts.count > 0
      @related_posts = related_posts(@posts)
    end
  end

  def show
    @post = ButterCMS::Post.find(params[:slug])
    @related_posts = related_posts(@post)
  end

  private

  # finding related posts
  def related_posts(posts)
    current_posts = posts.class == ButterCMS::ButterCollection ? posts.to_a : [posts]
    all_posts = ButterCMS::Post.all({:page => 1, :page_size => 100000000})
    single_post_without_category?(current_posts) ? newest_posts(3, all_posts) : find_related_posts(current_posts, all_posts)
  end

  def single_post_without_category?(current_posts)
    current_posts.count == 1 && current_posts.first.categories.empty?
  end

  def find_related_posts(posts, all_posts)
    categories = posts_categories(posts)
    posts_by_categories = posts_by_categories(categories, all_posts)
    best_matches = best_matches_posts(posts_by_categories, posts)
    related_posts = all_posts.select {|post| best_matches.any? {|slug| post.slug == slug[0]}}
    if best_matches.count < 3
      best_matches = newest_posts(3 - best_matches.count, all_posts)
      best_matches.each {|post| related_posts.push post}
    end
    related_posts
  end

  def newest_posts(number_of_posts, all_posts)
    new_posts = all_posts.first(number_of_posts)
    new_posts.map {|post| post}
  end

  # get all categories from posts
  def posts_categories(posts)
    posts.map(&:categories).flatten.map(&:slug).uniq
  end

  # get all posts by categories
  def posts_by_categories(categories, all_posts)
    categories.map {|category| all_posts.select {|post| post.categories.any? {|post_category| post_category[:slug] == category}}}
  end

  # run through posts_by_categories to get list of posts in format {"some_slug": 5} without repetitions
  def best_matches_posts(posts_by_categories, posts)
    posts_arr = cleaned_posts_arr(posts_by_categories.flatten, posts)
    posts_arr.uniq.map {|x| [x.slug, posts_arr.count(x)]}.sort_by {|slug, matches| matches}.last(3)
  end

  def cleaned_posts_arr(posts_arr, cur_posts)
    posts_arr.reject {|post| cur_posts.any? {|cur_post| cur_post.slug == post.slug}}
  end

end
