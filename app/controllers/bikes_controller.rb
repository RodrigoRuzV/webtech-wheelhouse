class BikesController < ApplicationController
  def index
    # Alphabetical by make and model: how a mechanic scans the rack for a
    # particular bike, not the order the rows were inserted in.
    @bikes = Bike.includes(:customer).by_make_and_model
  end

  def show
    @bike = Bike.find(params[:id])
    @repairs = @bike.repairs.includes(:customer).newest_first
  end
end
