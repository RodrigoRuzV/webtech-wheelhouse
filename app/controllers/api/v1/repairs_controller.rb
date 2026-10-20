# Lab 10: the repairs, for the shop's accounting program. Private: every
# action needs the token.
module Api
  module V1
    class RepairsController < BaseController
      before_action :authenticate!

      # GET /api/v1/repairs and GET /api/v1/repairs?state=picked_up
      # Five queries whatever the number of repairs, lines and services:
      # repairs, customers, bikes, repair_jobs and services.
      def index
        repairs = Repair.newest_first.includes(:customer, :bike, repair_jobs: :service)
        repairs = repairs.where(status: requested_state) if params.key?(:state)

        render json: repairs.map { |repair| repair_document(repair) }
      end

      # GET /api/v1/repairs/:id
      def show
        repair = Repair.includes(:customer, :bike, repair_jobs: :service).find(params[:id])
        render json: repair_document(repair)
      end

      private

      # The filter is checked against the enum, so no state name is written
      # here: a state added to the model is accepted, and listed, at once.
      def requested_state
        state = params[:state]
        return state if state.is_a?(String) && Repair.statuses.key?(state)

        raise InvalidParameter, "state must be one of: #{Repair.statuses.keys.join(', ')}"
      end

      # The one shape of a repair. No foreign keys: the bike, the customer
      # and the lines travel inside. Left out on purpose (docs/api.md): the
      # customer's phone, the staff (intake, mechanic, who handed it back),
      # the diagnosis, the photos and the internal timestamps.
      def repair_document(repair)
        {
          id: repair.id,
          state: repair.status,
          dropped_off_on: repair.created_at.to_date.iso8601,
          promised_on: repair.promised_on&.iso8601,
          returned_on: repair.returned_at&.to_date&.iso8601,
          customer_answer: customer_answer(repair),
          overdue: repair.overdue?,
          total: price_string(repair.total),
          customer: { name: repair.customer.name },
          bike: {
            make: repair.bike.make,
            model: repair.bike.model,
            serial_number: repair.bike.serial_number
          },
          lines: repair.repair_jobs.sort_by(&:id).map do |job|
            { service: job.service.name, price_charged: price_string(job.price_charged) }
          end
        }
      end

      # The customer's answer to the quote, as the lifecycle names it
      # (docs/domain-model.md, "Lifecycle"): the customer approves or
      # declines the quote. It is not a column; it is read from the state:
      # - "pending"  — awaiting_approval: the quote was given, no answer yet;
      # - "declined" — declined_pickup_pending, or picked up after a quote
      #                with no work finished;
      # - "approved" — in_progress, or a quoted repair whose work was finished;
      # - null       — no quote was ever needed or given (dropped off,
      #                diagnosing, or a simple same-day job).
      def customer_answer(repair)
        return "pending" if repair.awaiting_approval?
        return "declined" if repair.declined_pickup_pending?
        return nil if repair.quoted_at.nil? || repair.dropped_off? || repair.diagnosing?
        return "approved" if repair.in_progress? || repair.finished_at.present?

        "declined"
      end
    end
  end
end
