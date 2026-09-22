class ServicesController < ApplicationController
  def index
    @services = Service.by_name
  end

  def show
    @service = Service.find(params[:id])
    @repair_jobs = @service.repair_jobs.includes(repair: :customer).newest_first
  end
end
