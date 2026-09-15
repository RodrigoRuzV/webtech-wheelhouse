class RepairsController < ApplicationController
  def index
    # Newest first: the counter and the mechanics care about what just
    # came in and what is still moving, not what happened first overall.
    @repairs = Repair.includes(:bike, :customer).order(created_at: :desc)
  end

  def show
    @repair = Repair.find(params[:id])
    @repair_jobs = @repair.repair_jobs.includes(:service)
  end
end
