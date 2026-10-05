class BikesController < ApplicationController
  before_action :set_bike, only: %i[show edit update destroy]
  before_action :load_customers, only: %i[new edit create update]

  def index
    # Alphabetical by make and model: how a mechanic scans the rack for a
    # particular bike, not the order the rows were inserted in.
    @bikes = Bike.includes(:customer).by_make_and_model
  end

  def show
    @repairs = with_photos_and_diagnosis(@bike.repairs.includes(:customer)).newest_first
  end

  # Reached from a customer's page as /bikes/new?customer_id=…, so the
  # owner is already chosen. The id is only used to look the customer up;
  # nothing from params is assigned to the bike here.
  def new
    @bike = Bike.new(customer: Customer.find_by(id: params[:customer_id]))
  end

  def edit
  end

  def create
    @bike = Bike.new(bike_params)

    if @bike.save
      redirect_to @bike, notice: "Bike #{@bike.serial_number} (#{@bike.make} #{@bike.model}) was registered for #{@bike.customer.name}."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @bike.update(bike_params)
      redirect_to @bike, notice: "Bike #{@bike.serial_number} was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @bike.destroy
      redirect_to bikes_path, notice: "Bike #{@bike.serial_number} was deleted.", status: :see_other
    else
      redirect_to @bike, alert: "Bike #{@bike.serial_number} was not deleted. #{@bike.errors.full_messages.to_sentence}.", status: :see_other
    end
  end

  private

  def set_bike
    @bike = Bike.find(params[:id])
  end

  def load_customers
    @customers = Customer.by_name
  end

  def bike_params
    params.expect(bike: [ :customer_id, :make, :model, :serial_number ])
  end
end
