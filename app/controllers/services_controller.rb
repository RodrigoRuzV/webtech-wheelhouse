class ServicesController < ApplicationController
  def index
    @services = Service.order(:name)
  end

  def show
    @service = Service.find(params[:id])
    @repair_jobs = @service.repair_jobs.includes(:repair).order(created_at: :desc)
  end
end
