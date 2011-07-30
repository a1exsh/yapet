module CategoriesHelper
  def category_breadcrumbs(category, url = :category_path,
                           top_url = :categories_path,
                           options = {})
    path = category.with_ancestors.reverse

    ([link_to(_("(All)"), self.send(top_url, options))] + \
     path[0..-2].map{ |c| link_to c.title, self.send(url, c, options) } + \
     [path[-1].title]).join('&nbsp;&gt; ')
  end

  def link_to_category(*args)
    link_to '', category_path(*args),
      :class => "icon icon-category",
      :title => _("Click to view this Category")
  end

  def link_to_category_stats(category, options = {})
    link_to category.title, stats_category_path(category, options),
      :title => _("Click for Category Statistics")
  end

  def link_to_category_stats_with_search(options = {})
    if @search_category
      url = stats_category_path(@search_category, options)
    elsif @search_item
      url = stats_category_path(@search_item.category, options)
    else
      url = stats_categories_path(options)
    end
    link_to '', url, :class => "icon icon-category",
      :title => _("Click for Category Statistics")
  end
end
