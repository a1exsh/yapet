module ExpensesHelper
  def find_expenses_link(options = {})
    link_to('', expenses_path(options),
            :class => "icon icon-expenses",
            :title => _("Click to find matching Expenses"))
  end

  def link_to_expenses_stats(options = {})
    link_to '', stats_expenses_path(options),
      :class => "icon icon-stats-date",
      :title => _("Click to view Expense Statistics by Date")
  end
end
