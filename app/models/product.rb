class Product < ApplicationRecord
  belongs_to :tenant
  belongs_to :category
  
  validates :name, presence: true, length: { minimum: 2, maximum: 200 }
  validates :slug, presence: true, uniqueness: { scope: :tenant_id },
            format: { with: /\A[a-z0-9\-]+\z/, message: "only lowercase letters, numbers, and hyphens allowed" }
  validates :sku, presence: true, uniqueness: { scope: :tenant_id },
            format: { with: /\A[A-Z0-9\-]+\z/, message: "only uppercase letters, numbers, and hyphens allowed" }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[active inactive discontinued] }
  validates :weight, numericality: { greater_than: 0 }, allow_nil: true
  validate :category_belongs_to_same_tenant
  
  before_validation :generate_slug, if: :name_changed?
  before_validation :normalize_sku
  
  scope :active, -> { where(status: 'active') }
  scope :for_tenant, ->(tenant) { where(tenant: tenant) }
  scope :by_category, ->(category) { where(category: category) }
  scope :search_by_name, ->(query) { where("name ILIKE ?", "%#{query}%") }
  
  def active?
    status == 'active'
  end
  
  def formatted_price
    "$#{'%.2f' % price}"
  end
  
  def search_data
    {
      name: name,
      description: description,
      sku: sku,
      category_name: category.name,
      tenant_id: tenant_id,
      status: status,
      price: price
    }
  end
  
  private
  
  def generate_slug
    self.slug = name.downcase.strip.gsub(/\s+/, '-').gsub(/[^a-z0-9\-]/, '')
  end
  
  def normalize_sku
    self.sku = sku&.upcase&.strip
  end
  
  def category_belongs_to_same_tenant
    return unless category && tenant
    
    errors.add(:category, 'must belong to the same tenant') if category.tenant_id != tenant_id
  end
end
