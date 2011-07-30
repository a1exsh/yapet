module ItemsHelper
  def link_to_item(*args)
    link_to '', item_path(*args),
      :class => "icon icon-item",
      :title => _("Click to view this Item")
  end
end
