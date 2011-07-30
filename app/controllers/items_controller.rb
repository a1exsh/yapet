class ItemsController < ResourceController
  in_place_edit_for :item, :title
  auto_complete_for :item, :title,
    { :limit => nil },
    { :scope => :scope_for_records_on_current_account }

  in_place_edit_for :item, :category_title
  auto_complete_for :item, :category_title,
    { :limit => nil },
    { :record => :category, :method => :title,
      :scope => :categories_for_auto_complete }

  def show
    @find_options = { :item => @item.id }
    super
  end

  # GET /items/1/details_table
  def details_table
    find_record_on_current_account

    respond_to do |format|
      format.html { render :partial => "details_table" }
    end
  end

  private

  def categories_for_auto_complete
    current_account.categories
  end

  def find_records_for_index_on_current_account
    if params[:uncategorized]
      @uncategorized_only = true
      @items = current_account.items.uncategorized
    elsif params[:category]
      @parent_category = current_account.categories.find(params[:category])
      @items = @parent_category.items
    else
      super(:order => 'title', :include => :category)
    end

    @expense_count_by_item_id = Expense.count_by_items(@items)
    @expense_total_by_item_id = Expense.total_by_items(@items)
  end

  def find_record_on_current_account
    super
    return if request.xhr?

    expenses = current_account.expenses.for_item(@item)

    @totals = calc_totals(expenses)
    @averages = calc_averages(@totals[:grand], current_account.age)
  end
end
