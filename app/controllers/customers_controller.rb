class CustomersController < ApplicationController
  def index
    @customers = Customer.order(:name)
  end

  def show
    @customer = Customer.find(params[:id])
    @bikes = @customer.bikes.order(:make, :model)
    @repairs = @customer.repairs.includes(:bike).order(created_at: :desc)
  end
end
