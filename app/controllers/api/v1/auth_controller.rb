module Api
  module V1
    class AuthController < ApplicationController
      before_action :set_tenant, only: [:login]
      
      def login
        user = @tenant.users.find_by(email: login_params[:email])
        
        if user&.authenticate(login_params[:password]) && user.active?
          token = user.generate_jwt_token
          render json: {
            message: 'Login successful',
            token: token,
            user: user_data(user)
          }, status: :ok
        else
          render json: { error: 'Invalid credentials or inactive account' }, status: :unauthorized
        end
      end
      
      def logout
        render json: { message: 'Logout successful' }, status: :ok
      end
      
      private
      
      def login_params
        params.require(:auth).permit(:email, :password, :subdomain)
      end
      
      def set_tenant
        subdomain = login_params[:subdomain] || request.headers['X-Tenant-Subdomain']
        @tenant = Tenant.active.by_subdomain(subdomain).first
        
        unless @tenant
          render json: { error: 'Invalid tenant' }, status: :not_found
        end
      end
      
      def user_data(user)
        {
          id: user.id,
          email: user.email,
          full_name: user.full_name,
          role: user.role
        }
      end
    end
  end
end
