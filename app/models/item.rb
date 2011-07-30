class Item < ActiveRecord::Base
  has_many :expenses, :dependent => :destroy
  belongs_to :account
  belongs_to :category

  attr_accessible :title, :category_title

  named_scope :uncategorized,
    :conditions => "category_id IS NULL",
    :order => "title"

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :account_id

  include TitleCapitalization

  def category_title
    category.title unless category.nil?
  end

  # TODO: move to module or plugin
  def category_title=(title)
    self.category = account.categories.with_title(title)
    category_title
  end
end
