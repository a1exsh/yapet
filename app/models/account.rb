class Account < ActiveRecord::Base
  has_many :users, :dependent => :destroy
  has_many :items, :dependent => :destroy
  has_many :expenses, :dependent => :destroy
  has_many :categories, :dependent => :destroy

  has_one :owner, :class_name => 'User',
    :conditions => 'users.id = #{self.owner_id}'

  named_scope :expired_sandboxes,
    :conditions => ["accounts.sandbox = ? AND accounts.created_at < ?",
                    true, 1.day.ago]

  def exclusive?
    users.count == 1
  end

  def is_sandbox?
    sandbox
  end

  ######################################################################

  # cache all things age-related and return the same value throughout
  # request to avoid potential side-effects
  def first_use_time
    return @first_use_time unless @first_use_time.nil?
    
    first_expense = expenses.find(:first, :order => "expenses.date")
    @first_use_time = first_expense.nil? ? self.created_at : first_expense.date
  end

  def age
    @age ||= Time.zone.now - first_use_time
  end

  def age_span_in_months
    return @age_span_in_months unless @age_span_in_months.nil?
    
    @age_span_in_months = 0
    for_each_month_of_usage { @age_span_in_months += 1 }
    @age_span_in_months
  end

  def age_span_in_years
    return @age_span_in_years unless @age_span_in_years.nil?
    
    @age_span_in_years = 0
    for_each_year_of_usage { @age_span_in_years += 1 }
    @age_span_in_years
  end

  def for_each_month_of_usage
    now = Time.zone.now
    month = first_use_time.at_beginning_of_month
    while month < now do
      yield month
      month = month.next_month
    end
  end

  def for_each_year_of_usage
    now = Time.zone.now
    year = first_use_time.at_beginning_of_year
    while year < now do
      yield year
      year = year.next_year
    end
  end
end
