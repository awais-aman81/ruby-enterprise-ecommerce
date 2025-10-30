class Category < ApplicationRecord
  belongs_to :tenant
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  has_many :products, dependent: :restrict_with_error
  
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :slug, presence: true, uniqueness: { scope: :tenant_id },
            format: { with: /\A[a-z0-9\-]+\z/, message: "only lowercase letters, numbers, and hyphens allowed" }
  validates :status, presence: true, inclusion: { in: %w[active inactive] }
  validate :parent_belongs_to_same_tenant
  validate :cannot_be_parent_of_itself
  
  before_validation :generate_slug, if: :name_changed?
  
  scope :active, -> { where(status: 'active') }
  scope :root_categories, -> { where(parent_id: nil) }
  scope :for_tenant, ->(tenant) { where(tenant: tenant) }
  
  def root?
    parent_id.nil?
  end
  
  def leaf?
    children.empty?
  end
  
  def ancestors
    return [] if root?
    [parent] + parent.ancestors
  end
  
  def descendants
    children + children.flat_map(&:descendants)
  end
  
  private
  
  def generate_slug
    self.slug = name.downcase.strip.gsub(/\s+/, '-').gsub(/[^a-z0-9\-]/, '')
  end
  
  def parent_belongs_to_same_tenant
    return unless parent && tenant
    
    errors.add(:parent, 'must belong to the same tenant') if parent.tenant_id != tenant_id
  end
  
  def cannot_be_parent_of_itself
    return unless parent_id
    
    errors.add(:parent, 'cannot be itself') if parent_id == id
  end
end
