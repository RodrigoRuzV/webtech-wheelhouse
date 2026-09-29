class ServicesController < ApplicationController
  before_action :set_service, only: %i[show edit update destroy]

  def index
    @services = Service.by_name
  end

  def show
    @repair_jobs = @service.repair_jobs.includes(repair: :customer).newest_first
  end

  def new
    @service = Service.new
  end

  def edit
  end

  def create
    @service = Service.new(service_params)

    if @service.save
      redirect_to @service, notice: "#{@service.name} was added to the price list."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @service.update(service_params)
      redirect_to @service, notice: "#{@service.name} was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @service.destroy
      redirect_to services_path, notice: "#{@service.name} was removed from the price list.", status: :see_other
    else
      redirect_to @service, alert: "#{@service.name} was not deleted. #{@service.errors.full_messages.to_sentence}.", status: :see_other
    end
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    params.expect(service: [ :name, :price ])
  end
end
