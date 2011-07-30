class Expense < ActiveRecord::Base
  belongs_to :item
  belongs_to :account

  named_scope :for_item, lambda { |item|
    { :conditions => { :item_id => item } }
  }
  
  named_scope :for_category, lambda { |category|
    { :conditions => { :item_id => category.belonging_items } }
  }

  named_scope :for_conditions, lambda { |conditions|
    { :conditions => conditions }
  }

  attr_accessible :item_title, :amount, :comment

  validates_presence_of :item_title
  validates_numericality_of :amount,
    :greater_than_or_equal_to => 0.01,
    :less_than => 10**6

  validates_each :date do |record, attr, value|
    if value && value > Time.zone.now
      record.errors.add attr, _("Date cannot be set to future")
    end
  end

  def before_validation_on_create
    self.date = Time.zone.now
  end

  # NB: alias_method doesn't work for ActiveRecord db methods, so we
  # use super instead.
  def amount=(val)
    if val.is_a?(String)
      val.tr!(',', '.')
      if val.include?('.')
        parts = val.split('.')
        val = parts[0..-2].join + "." + parts[-1]
      end
    end

    super(val)
  end

  def item_title
    item.title unless item.nil?
  end

  def item_title=(title)
    self.item = account.items.with_title(title) unless title.blank?
    item_title
  end

  def date=(new_date)
    new_date = case new_date
               when String
                 DateTime.parse(new_date).in_time_zone
               else
                 new_date.to_datetime.in_time_zone
               end
    return if date && date.to_date == new_date.to_date

    now = Time.zone.now
    return super(now) if new_date.to_date == now.to_date

    conditions = Expense.conditions_for_date(new_date)
    last_expense = account.expenses.for_conditions(conditions).find(:first, :order => "expenses.date DESC")
    last_expense_time = last_expense ? last_expense.date : new_date.at_midnight

    last_time = new_date.at_midnight.tomorrow
    time_diff = last_time - last_expense_time

    super(last_time - time_diff/2)
  end

  # TODO: refactor next two functions
  def self.count_by_items(items)
    counts_array = count(:conditions => { :item_id => items.map(&:id) },
                         :group => :item_id)
    Hash[*(counts_array.flatten)]
  end

  def self.total_by_items(items)
    sum_array = sum(:amount,
                    :conditions => { :item_id => items.map(&:id) },
                    :group => :item_id)
    totals = Hash[*(sum_array.flatten)]

    # fill possible gaps with 0s
    items.each{ |item| totals[item.id] = totals[item.id] || 0 }
    totals
  end

  def self.total_by_categories(categories)
    cat_array = categories.map{ |cat| [cat.id, for_category(cat).grand_total] }
    Hash[*(cat_array.flatten)]
  end

  def self.grand_total
    sum(:amount)
  end

  def self.total_this_month
    total_for_month(Time.zone.now)
  end

  def self.total_last_month
    total_for_month(Time.zone.now.last_month)
  end

  def self.total_this_year
    total_for_year(Time.zone.now)
  end

  def self.total_last_year
    total_for_year(Time.zone.now.last_year)
  end

  def self.daily_average(period)
    sum(:amount) / (period / 1.day)
  end

  def self.monthly_average(period)
    sum(:amount) / (period / 1.month)
  end

  def self.annually_average(period)
    sum(:amount) / (period / 1.year)
  end

  def self.total_for_month(date)
    sum(:amount, :conditions => conditions_for_month(date))
  end

  def self.total_for_year(date)
    sum(:amount, :conditions => conditions_for_year(date))
  end

  def self.conditions_for_date(date)
    date = date.to_datetime.in_time_zone
    { :date => date.at_midnight..date.tomorrow.at_midnight }
  end

  def self.conditions_for_month(date)
    date = date.to_datetime.in_time_zone
    { :date => date.at_beginning_of_month..date.at_end_of_month }
  end

  def self.conditions_for_year(date)
    date = date.to_datetime.in_time_zone
    { :date => date.at_beginning_of_year..date.at_end_of_year }
  end

  def self.conditions_for_item(item)
    { :item_id => item }
  end

  def self.conditions_for_category(category)
    { :item_id => category.belonging_items }
  end
end
