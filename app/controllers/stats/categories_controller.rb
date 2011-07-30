class Stats::CategoriesController < ApplicationController
  include Searching
  force_ssl

  def index
    conditions = expense_conditions_for_date
    @searching = !conditions.empty?

    @categories = current_account.categories.top_level
    @items = current_account.items.uncategorized

    gather_stats(conditions)
  end

  def show
    conditions = expense_conditions_for_date
    @searching = !conditions.empty?

    @category = current_account.categories.find(params[:id])

    @categories = @category.children
    @items = @category.items

    gather_stats(conditions)
  end

  private

  def gather_stats(conditions = nil)
    expenses = current_account.expenses.for_conditions(conditions)

    @category_totals = expenses.total_by_categories(@categories)
    @item_totals = expenses.total_by_items(@items)

    @categories.sort!{ |a,b| @category_totals[b.id] - @category_totals[a.id] }
    @items.sort!{ |a,b| @item_totals[b.id] - @item_totals[a.id] }

    @grand_total = @category_totals.map(&:last).sum + \
      @item_totals.map(&:last).sum
  end
end
