require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:tenant) { Tenant.create!(name: 'Test Tenant', subdomain: 'test', status: 'active') }
  let(:category) { Category.create!(tenant: tenant, name: 'Electronics', status: 'active') }
  
  describe 'validations' do
    it 'validates presence of required fields' do
      product = Product.new(tenant: tenant, category: category)
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include("can't be blank")
      expect(product.errors[:sku]).to include("can't be blank")
      expect(product.errors[:price]).to include("can't be blank")
    end
    
    it 'validates uniqueness of SKU within tenant scope' do
      Product.create!(
        tenant: tenant, category: category, name: 'iPhone', 
        sku: 'IPHONE-001', price: 999.99, status: 'active'
      )
      duplicate = Product.new(
        tenant: tenant, category: category, name: 'iPhone 2', 
        sku: 'IPHONE-001', price: 1099.99, status: 'active'
      )
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:sku]).to include('has already been taken')
    end
    
    it 'validates price is greater than zero' do
      product = Product.new(
        tenant: tenant, category: category, name: 'Test Product',
        sku: 'TEST-001', price: -10, status: 'active'
      )
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include('must be greater than 0')
    end
    
    it 'validates category belongs to same tenant' do
      other_tenant = Tenant.create!(name: 'Other', subdomain: 'other', status: 'active')
      other_category = Category.create!(tenant: other_tenant, name: 'Other Category', status: 'active')
      
      product = Product.new(
        tenant: tenant, category: other_category, name: 'Test Product',
        sku: 'TEST-001', price: 99.99, status: 'active'
      )
      expect(product).not_to be_valid
      expect(product.errors[:category]).to include('must belong to the same tenant')
    end
  end
  
  describe 'business logic' do
    let(:product) do
      Product.create!(
        tenant: tenant, category: category, name: 'Test Product',
        sku: 'TEST-001', price: 99.99, status: 'active'
      )
    end
    
    it 'formats price correctly' do
      expect(product.formatted_price).to eq('$99.99')
    end
    
    it 'provides search data' do
      search_data = product.search_data
      expect(search_data[:name]).to eq('Test Product')
      expect(search_data[:sku]).to eq('TEST-001')
      expect(search_data[:price]).to eq(99.99)
    end
  end
  
  describe 'slug generation' do
    it 'generates slug from name' do
      product = Product.create!(
        tenant: tenant, category: category, name: 'Apple iPhone 15 Pro',
        sku: 'IPHONE-15-PRO', price: 1199.99, status: 'active'
      )
      expect(product.slug).to eq('apple-iphone-15-pro')
    end
  end
  
  describe 'scopes' do
    let!(:active_product) do
      Product.create!(
        tenant: tenant, category: category, name: 'Active Product',
        sku: 'ACTIVE-001', price: 99.99, status: 'active'
      )
    end
    
    let!(:inactive_product) do
      Product.create!(
        tenant: tenant, category: category, name: 'Inactive Product',
        sku: 'INACTIVE-001', price: 99.99, status: 'inactive'
      )
    end
    
    it 'filters active products' do
      expect(Product.active).to include(active_product)
      expect(Product.active).not_to include(inactive_product)
    end
    
    it 'filters products by tenant' do
      other_tenant = Tenant.create!(name: 'Other', subdomain: 'other', status: 'active')
      other_category = Category.create!(tenant: other_tenant, name: 'Other Category', status: 'active')
      other_product = Product.create!(
        tenant: other_tenant, category: other_category, name: 'Other Product',
        sku: 'OTHER-001', price: 99.99, status: 'active'
      )
      
      expect(Product.for_tenant(tenant)).to include(active_product)
      expect(Product.for_tenant(tenant)).not_to include(other_product)
    end
  end
end
