module Stats::ExpensesHelper
  def update_quick_stats_function
    remote_function(:update => "quick_stats_wrapper",
                    :url => { :controller => "stats/expenses",
                      :action => "quick_stats" },
                    :method => :get)
  end
end
