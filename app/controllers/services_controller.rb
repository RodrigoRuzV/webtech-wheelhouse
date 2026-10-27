class ServicesController < ApplicationController
  # Lab 11: the wall list is the one public part of the site. Its list and
  # the page of each service are open; creating, editing and deleting a
  # service still need a session.
  allow_unauthenticated_access only: %i[index show]

  before_action :set_service, only: %i[show edit update destroy]

  def index
    @services = Service.by_name
  end

  def show
    # The repairs it was charged on are for the staff only: a visitor gets
    # the name and the price, and no customer's name.
    @repair_jobs = authenticated? ? @service.repair_jobs.includes(repair: :customer).newest_first : RepairJob.none
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
