module Api
  module V1
    class BaseController < ApplicationController
      # Add common API v1 functionality here

      private

      def pagination_params
        {
          page: (params[:page] || 1).to_i,
          per_page: [(params[:per_page]&.to_i&.nonzero? || 25), 100].min
        }
      end

      def append_info_to_payload(payload)
        super
        if current_user
          payload[:user_id] = current_user.id
          payload[:ip] = request.remote_ip
        end
      end
    end
  end
end
