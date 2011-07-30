class Stats::ExpensesController < ApplicationController
  include Searching
  force_ssl

  def index
    conditions = expense_conditions_for_item_or_category
    @searching = !conditions.empty?

    expenses = current_account.expenses.for_conditions(conditions)

    @monthly_stats = []
    current_account.for_each_month_of_usage do |month|
      @monthly_stats << [month, expenses.total_for_month(month)]
    end
    @grand_total = expenses.grand_total
  end

  def quick_stats
    respond_to do |format|
      format.html # quick_stats.html.erb
    end
  end
end
