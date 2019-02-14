class Buttercms::PostsController < Buttercms::BaseController
  helper BlogsHelper

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

    if @posts.count > 0
      @related_posts = related_posts(@posts)
    end
  end

  def show
    @post = ButterCMS::Post.find(params[:slug])
    @related_posts = related_posts(@post)
  end

  private

  # finding related posts in
  def related_posts(posts)
    current_posts = posts.class == ButterCMS::ButterCollection ? posts.to_a : [posts]
    current_posts.count == 1 && current_posts.first.categories.empty? ? related_posts = newest_posts(3) : related_posts = find_related_posts(current_posts)
    related_posts
  end

  def find_related_posts(current_posts)
    related_posts = Array.new
    categories = posts_categories(current_posts)
    posts_by_categories = posts_by_categories(categories)
    best_matches_posts = most_matches_posts(posts_by_categories, current_posts)
    best_matches_posts.each {|post| related_posts.push ButterCMS::Post.find(post[0])}
    if best_matches_posts.count < 3
      best_matches_posts = newest_posts(3 - best_matches_posts.count)
      best_matches_posts.map {|post| related_posts.push post}
    end
    related_posts
  end

  def newest_posts(number_of_posts)
    new_posts = ButterCMS::Post.all({:page => 1, :page_size => number_of_posts})
    new_posts.map {|post| post}
  end

  # get all categories from post
  def posts_categories(posts)
    posts.map(&:categories).flatten.map(&:slug).uniq
  end

  # get all posts by categories
  def posts_by_categories(categories)
    posts_all = ButterCMS::Post.all({:page => 1, :page_size => 100000000, :exclude_body => true})
    categories.map {|category| posts_all.select {|post| post.categories.any? {|post_category| post_category[:slug] == category}}}
  end

  # run through posts_by_categories to get list of posts in format {"some_slug": 5} without repetitions
  def most_matches_posts(posts_by_categories, posts)
    posts_arr = cleaned_posts_arr(posts_by_categories.flatten, posts)
    matches = posts_arr.uniq.map {|x| [x.slug, posts_arr.count(x)]}
    matches.sort_by {|slug, matches| matches}
    matches.last(3)
  end

  def cleaned_posts_arr(posts_arr, cur_posts)
    posts_arr.reject {|post| cur_posts.any? {|cur_post| cur_post.slug == post.slug}}
  end

end
