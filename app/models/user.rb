class User < ApplicationRecord
  belongs_to :tenant
  
  has_secure_password
  
  validates :email, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :role, presence: true, inclusion: { in: %w[admin manager user] }
  validates :status, presence: true, inclusion: { in: %w[active inactive suspended] }
  validates :password, length: { minimum: 8 }, if: :password_required?
  
  before_validation :normalize_email
  before_create :set_default_values
  
  scope :active, -> { where(status: 'active') }
  scope :by_role, ->(role) { where(role: role) }
  scope :for_tenant, ->(tenant) { where(tenant: tenant) }
  
  def active?
    status == 'active' && tenant&.active?
  end
  
  def admin?
    role == 'admin'
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def generate_jwt_token
    Services::Authentication::JwtService.encode(user_id: id, tenant_id: tenant_id)
  end
  
  private
  
  def normalize_email
    self.email = email&.downcase&.strip
  end
  
  def set_default_values
    self.role ||= 'user'
    self.status ||= 'active'
  end
  
  def password_required?
    new_record? || password.present?
  end
end
