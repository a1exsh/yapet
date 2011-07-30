module Searching
  def self.included(target)
    target.before_filter(:parse_search_params, :only => [:index, :show])
  end

  protected

  def parse_search_params
    @search_options = {}

    if params[:item]
      @search_item = current_account.items.find(params[:item])
      @search_options[:item] = params[:item]
    elsif params[:category]
      @search_category = current_account.categories.find(params[:category])
      @search_options[:category] = params[:category]
    end

    if params[:date]
      @search_date = Date.parse(params[:date]).to_time
      @search_options[:date] = params[:date]
    elsif params[:month]
      @search_month = Date.parse(params[:month]).to_time
      @search_options[:month] = params[:month]
    elsif params[:year]
      @search_year = Date.parse(params[:year]).to_time
      @search_options[:year] = params[:year]
    end
  rescue ActiveRecord::RecordNotFound
  end

  def expense_conditions_for_item_or_category
    if @search_item
      Expense.conditions_for_item(@search_item)
    elsif @search_category
      Expense.conditions_for_category(@search_category)
    else
      {}
    end
  end

  def expense_conditions_for_date
    if @search_date
      Expense.conditions_for_date(@search_date)
    elsif @search_month
      Expense.conditions_for_month(@search_month)
    elsif @search_year
      Expense.conditions_for_year(@search_year)
    else
      {}
    end
  end
end
