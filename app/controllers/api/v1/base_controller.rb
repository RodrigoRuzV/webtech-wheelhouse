# Lab 10: what every controller of the API shares. It is built on
# ActionController::API, not on ApplicationController: no session, no
# cookies, no flash, no CSRF token and no layouts. A program says who it is
# with a token in a header, and every answer is a JSON document.
module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods

      # Raised by an action when a query parameter has a value the API can't
      # read (for example ?state=lost). Answered with a 400, here, once.
      class InvalidParameter < StandardError; end

      # One shape for every error: { "errors": [ "...", ... ] }.
      # The 404 and the 400 are handled here, once, not in each action.
      rescue_from ActiveRecord::RecordNotFound do |error|
        message = error.model && error.id ? "#{error.model} #{error.id} not found" : "Not found"
        render_errors [ message ], :not_found
      end

      # params.expect found no attributes of the resource in the body (no
      # key, an empty object, or only keys that aren't on the list).
      rescue_from ActionController::ParameterMissing do |error|
        render_errors [ error.message ], :bad_request
      end

      # The body says it is JSON but can't be parsed. Without this, Rails
      # would answer its own 400 page instead of a document.
      rescue_from ActionDispatch::Http::Parameters::ParseError do
        render_errors [ "The body of the request is not valid JSON" ], :bad_request
      end

      rescue_from InvalidParameter do |error|
        render_errors [ error.message ], :bad_request
      end

      private

      # A before_action for the routes that need the token. It runs before
      # the action: without the Authorization header, or with another
      # token, the 401 goes out and the action never runs.
      def authenticate!
        return if authenticate_with_http_token { |token, _options| valid_token?(token) }

        headers["WWW-Authenticate"] = %(Bearer realm="Wheelhouse API")
        render_errors [ "Unauthorized: send a valid token in the Authorization header (Bearer)" ], :unauthorized
      end

      # The token lives in the encrypted credentials (api_token). The
      # comparison takes the same time whatever the token sent: it is not ==.
      def valid_token?(token)
        expected = Rails.application.credentials.api_token
        expected.present? && ActiveSupport::SecurityUtils.secure_compare(token.to_s, expected.to_s)
      end

      def render_errors(messages, status)
        render json: { errors: Array(messages) }, status: status
      end

      # A price travels as a string with two decimals ("45.00"), never as a
      # number: the column is a decimal, and a JSON number becomes a float
      # in the client. See "How a price travels" in docs/api.md.
      def price_string(amount)
        ActiveSupport::NumberHelper.number_to_rounded(amount, precision: 2)
      end
    end
  end
end
