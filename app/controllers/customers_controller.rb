class CustomersController < ApplicationController
  def index
    @customers = Customer.by_name
  end

  def show
    @customer = Customer.find(params[:id])
    @bikes = @customer.bikes.by_make_and_model
    @repairs = @customer.repairs.includes(:bike).newest_first
  end
end
