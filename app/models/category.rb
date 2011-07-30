class Category < ActiveRecord::Base
  belongs_to :account
  has_many :items, :order => 'title', :include => :category

  # NB: this should go before acts_as_tree
  before_destroy :reparent_children_and_items

  acts_as_tree :order => 'title'

  attr_accessible :title, :parent_title

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :account_id

  include TitleCapitalization

  def self.top_level
    roots
  end

  alias_method :unchecked_parent=, :parent=

  def parent=(node)
    check_cyclic_parents(node)
    self.unchecked_parent = node
  end

  def parent_title
    parent.title unless parent.nil?
  end

  # TODO: move to module or plugin
  def parent_title=(title)
    self.parent = account.categories.with_title(title)
    parent_title
  end

  def self.with_title(title)
    title.blank? ? nil : find_or_create_by_title(canonical_title(title))
  end

  def with_ancestors
    [self] + (parent ? parent.with_ancestors : [])
  end

  def with_descendants
    [self] + children.map(&:with_descendants)
  end

  def belonging_items
    with_descendants.flatten.map(&:items).flatten
  end

  def belonging_item_ids
    belonging_items.map{ |item| item.id }
  end

  private

  def check_cyclic_parents(new_parent)
    node = new_parent
    while node do
      if node == self
        self.errors.add :parent, :refcycle
        raise ActiveRecord::RecordInvalid.new(self)
      end
      node = node.parent
    end
  end

  def reparent_children_and_items
    new_parent_id = parent ? parent.id : "NULL"
    children.update_all("parent_id = #{new_parent_id}")
    items.update_all("category_id = #{new_parent_id}")
  end
end
