module Api
  module V1
    class ProductsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_tenant
      before_action :set_product, only: [:show, :update, :destroy]
      
      def index
        @products = @tenant.products.includes(:category)
        @products = @products.active if params[:active_only] == 'true'
        @products = @products.by_category(params[:category_id]) if params[:category_id].present?
        
        render json: {
          products: @products.map { |product| product_data(product) }
        }
      end
      
      def show
        render json: { product: detailed_product_data(@product) }
      end
      
      def create
        @product = @tenant.products.build(product_params)
        
        if @product.save
          render json: { 
            message: 'Product created successfully',
            product: detailed_product_data(@product)
          }, status: :created
        else
          render json: { 
            error: 'Failed to create product',
            errors: @product.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      def update
        if @product.update(product_params)
          render json: {
            message: 'Product updated successfully',
            product: detailed_product_data(@product)
          }
        else
          render json: {
            error: 'Failed to update product',
            errors: @product.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      def destroy
        if @product.destroy
          render json: { message: 'Product deleted successfully' }
        else
          render json: {
            error: 'Failed to delete product',
            errors: @product.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      def search
        query = params[:q]
        @products = @tenant.products.includes(:category)
        @products = @products.search_by_name(query) if query.present?
        @products = @products.by_category(params[:category_id]) if params[:category_id].present?
        
        render json: {
          products: @products.map { |product| product_data(product) },
          total: @products.size
        }
      end
      
      private
      
      def authenticate_user!
        # This would integrate with JWT authentication from PR #1/#2
        # For now, we'll assume user is authenticated
        true
      end
      
      def set_tenant
        # This would get tenant from authenticated user or subdomain
        @tenant = Tenant.first # Simplified for demo
      end
      
      def set_product
        @product = @tenant.products.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Product not found' }, status: :not_found
      end
      
      def product_params
        params.require(:product).permit(
          :name, :description, :sku, :price, :weight, :status, :category_id
        )
      end
      
      def product_data(product)
        {
          id: product.id,
          name: product.name,
          slug: product.slug,
          sku: product.sku,
          price: product.price,
          formatted_price: product.formatted_price,
          status: product.status,
          category: {
            id: product.category.id,
            name: product.category.name
          }
        }
      end
      
      def detailed_product_data(product)
        product_data(product).merge(
          description: product.description,
          weight: product.weight
        )
      end
    end
  end
end
