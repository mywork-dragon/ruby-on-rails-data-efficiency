module BlogsHelper

  # Blog post helper methods
  def post_image(post)
    post.featured_image.nil? ? asset_path("buttercms/posts_placeholder.svg") : post.featured_image
  end

  def author_profile_image(post)
    !post.author.profile_image.blank? ? post.author.profile_image : "http://placehold.jp/18/2db6d8/ffffff/30x30.png?text=" + post.author.first_name[0] + "&css=%7B%22font-weight%22%3A%22%20800%22%7D"
  end

  def author_full_name(post)
    post.author.first_name + ' ' + post.author.last_name
  end

  def date(post)
    raw_date = Date.parse(post.published)
    raw_date.strftime("%b") + ', ' + raw_date.strftime("%d") + ' ' + raw_date.strftime("%Y")
  end

end
