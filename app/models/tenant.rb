class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :subdomain, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\A[a-z0-9\-]+\z/, message: "only lowercase letters, numbers, and hyphens allowed" },
            length: { minimum: 3, maximum: 50 }
  validates :status, presence: true, inclusion: { in: %w[active inactive suspended] }
  
  before_validation :normalize_subdomain
  
  scope :active, -> { where(status: 'active') }
  scope :by_subdomain, ->(subdomain) { where(subdomain: subdomain.downcase) }
  
  def active?
    status == 'active'
  end
  
  def suspended?
    status == 'suspended'
  end
  
  private
  
  def normalize_subdomain
    self.subdomain = subdomain&.downcase&.strip
  end
end
