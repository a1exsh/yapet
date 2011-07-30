class CategoriesController < ResourceController
  in_place_edit_for :category, :title
  auto_complete_for :category, :title,
    { :limit => nil },
    { :scope => :scope_for_records_on_current_account }

  in_place_edit_for :category, :parent_title
  auto_complete_for :category, :parent_title,
    { :limit => nil },
    { :method => :title, :scope => :scope_for_records_on_current_account }

  before_filter :expenses_stats, :only => :show

  def show
    @find_options = { :category => @category.id }
    super
  end

  # GET /categories/toplevel
  # GET /categories/toplevel.xml
  def toplevel
    find_records_for_index_on_current_account

    respond_to do |format|
      format.html # toplevel.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  # GET /categories/1/subcategories
  # GET /categories/1/subcategories.xml
  def subcategories
    find_record_on_current_account

    respond_to do |format|
      format.html # subcategories.html.erb
      format.xml  { render :xml => @subcategories }
    end
  end

  # GET /categories/1/details_table
  def details_table
    find_record_on_current_account

    respond_to do |format|
      format.html { render :partial => "details_table" }
    end
  end

  private

  def find_records_for_index_on_current_account
    @categories = current_account.categories.top_level
    @expense_total_by_category_id = Expense.total_by_categories(@categories)

    @items = current_account.items.uncategorized
    @expense_count_by_item_id = Expense.count_by_items(@items)
    @expense_total_by_item_id = Expense.total_by_items(@items)

    @uncategorized_only = true
  end

  def expenses_stats
    expenses = current_account.expenses.for_category(@category)

    @subcategories = @category.children
    @expense_total_by_category_id = Expense.total_by_categories(@subcategories)

    @items = @category.items
    @expense_count_by_item_id = Expense.count_by_items(@items)
    @expense_total_by_item_id = Expense.total_by_items(@items)

    @totals = calc_totals(expenses)
    @averages = calc_averages(@totals[:grand], current_account.age)
  end
end
