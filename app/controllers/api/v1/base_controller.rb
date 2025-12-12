module Api
  module V1
    class BaseController < ApplicationController
      # Add common API v1 functionality here

      private

      def pagination_params
        {
          page: params[:page] || 1,
          per_page: [params[:per_page]&.to_i || 25, 100].min
        }
      end

      def log_user_activity
        return unless current_user

        append_info_to_payload do |payload|
          payload[:user_id] = current_user.id
          payload[:ip] = request.remote_ip
        end
      end
    end
  end
end
