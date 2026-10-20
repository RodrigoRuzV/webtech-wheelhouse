# Lab 10: the wall list, for the shop's website (public) and for the
# owner's script that adds a service (with the token).
module Api
  module V1
    class ServicesController < BaseController
      before_action :authenticate!, only: :create

      # GET /api/v1/services — two queries whatever the number of services
      # and repairs: the services, and every line that charged them.
      def index
        services = Service.by_name.includes(:repair_jobs)
        render json: services.map { |service| service_document(service) }
      end

      # GET /api/v1/services/:id — find raises, the base controller answers 404.
      def show
        service = Service.includes(:repair_jobs).find(params[:id])
        render json: service_document(service)
      end

      # POST /api/v1/services — body: { "service": { "name": ..., "price": ... } }
      def create
        service = Service.new(service_params)

        if service.save
          render json: service_document(service), status: :created, location: api_v1_service_url(service)
        else
          render_errors service.errors.full_messages, :unprocessable_content
        end
      end

      private

      # Strong parameters: nothing from params reaches the model without
      # going through this list. Any other key is dropped; a body with no
      # service attributes raises ParameterMissing (400, in the base).
      def service_params
        params.expect(service: [ :name, :price ])
      end

      # The one shape of a service, in index, show and create.
      # repairs_count is not a column: on how many repairs the service has
      # been charged, counted from the lines already loaded.
      def service_document(service)
        {
          id: service.id,
          name: service.name,
          price: price_string(service.price),
          repairs_count: service.repair_jobs.map(&:repair_id).uniq.size
        }
      end
    end
  end
end
