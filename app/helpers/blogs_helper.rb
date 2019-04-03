module BlogsHelper

  # Blog post helper methods
  def post_image(post)
    post.featured_image.nil? ? asset_path("/lib/images/buttercms/posts_placeholder.svg") : post.featured_image
  end

  def page_image(page)
    page.fields.interviewed_person_image.nil? ? asset_path("/lib/images/buttercms/posts_placeholder.svg") : page.fields.interviewed_person_image
  end

  def author_profile_image(post)
    post.author.profile_image.present? ? post.author.profile_image : "http://placehold.jp/18/2db6d8/ffffff/30x30.png?text=" + post.author.first_name[0] + "&css=%7B%22font-weight%22%3A%22%20500%22%2C%22padding-top%22%3A%22%201px%22%7D"
  end

  def author_full_name(post)
    "#{post.author.first_name} #{post.author.last_name}"
  end

  def date(post)
    raw_date = Date.parse(post.published)
    raw_date.strftime("%b %d, %Y")
  end

  def meta_tag(tag, text)
    view_context.content_for tag.to_sym, text
  end

  def yield_meta_tag(tag, additional_text = '', default_text = '')
    content_for?(tag.to_sym) ? content_for(tag.to_sym).concat(additional_text) : default_text
  end

  def view_context
    super.tap do |view|
      (@_content_for || {}).each do |name, content|
        view.content_for name, content
      end
    end
  end

end
