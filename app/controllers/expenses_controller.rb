class ExpensesController < ResourceController
  in_place_edit_for :expense, :item_title
  auto_complete_for :expense, :item_title,
    { :limit => nil },
    { :record => :item, :method => :title,
      :scope => :items_for_auto_complete }

  in_place_edit_for :expense, :amount
  in_place_edit_for :expense, :comment

  # TODO: make this cleaner
  before_filter :find_record_on_current_account,
    :only => [:show, :edit, :update, :destroy, :set_date]

  def set_date
    @expense.date = params[:value]
    @expense.save!
    head :ok
  rescue ArgumentError
    render :text => _("Invalid date format"), :status => :unprocessable_entity
  end

  private

  def items_for_auto_complete
    current_account.items
  end

  def find_records_for_index_on_current_account
    conditions = expense_conditions_for_item_or_category
    conditions.merge! expense_conditions_for_date

    @searching = !conditions.empty?

    super(:conditions => conditions, :include => :item,
          :order => "expenses.date DESC")
  end
end
