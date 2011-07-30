module Stats
  def self.included(target)
    target.before_filter(:set_quick_stats)
  end

  protected

  class QuickStats
    def initialize(expenses)
      @now = Time.zone.now
      @expenses = expenses
    end

    ATTRS=%w(this_month last_month total_this_month total_last_month
             grand_total)

    ATTRS.each do |name|
      define_method(name.to_sym) do
        value = self.instance_variable_get(:"@#{name}")
        if value.nil?
          calculate
          value = self.instance_variable_get(:"@#{name}")
        end
        value
      end
    end

    private

    def calculate
      @this_month = @now.at_beginning_of_month
      @last_month = @this_month.last_month

      @total_this_month = @expenses.total_this_month
      @total_last_month = @expenses.total_last_month

      @grand_total = @expenses.grand_total
    end
  end

  def set_quick_stats
    @quick_stats = QuickStats.new(current_account.expenses) if logged_in?
  end

  def calc_totals(expenses)
    totals = {}
    now = Time.zone.now

    totals[:this_month] = now.at_beginning_of_month
    totals[:last_month] = totals[:this_month].last_month

    totals[:this_year] = now.at_beginning_of_year
    totals[:last_year] = totals[:this_year].last_year

    totals[:total_this_month] = expenses.total_this_month
    totals[:total_last_month] = expenses.total_last_month

    totals[:total_this_year] = expenses.total_this_year
    totals[:total_last_year] = expenses.total_last_year

    totals[:grand] = expenses.grand_total

    totals
  end

  def calc_averages(grand_total, age)
    {
      :daily => grand_total / (age / 1.day),
      :monthly => grand_total / (age / 1.month),
      :annually => grand_total / (age / 1.year)
    }
  end
end
