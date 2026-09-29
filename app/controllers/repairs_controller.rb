class RepairsController < ApplicationController
  # How many empty lines the form offers. Without JavaScript the form can't
  # grow on its own, so a new repair starts with room for the few services
  # a typical intake has, and every edit adds a couple more; a repair that
  # needs more lines is saved and edited again. Empty lines are ignored on
  # save (reject_if in Repair).
  NEW_REPAIR_BLANK_LINES = 3
  EDIT_REPAIR_BLANK_LINES = 2

  before_action :set_repair, only: %i[show edit update destroy]
  before_action :load_form_choices, only: %i[new edit create update]

  def index
    # Newest first: the counter and the mechanics care about what just
    # came in and what is still moving, not what happened first overall.
    @repairs = Repair.includes(:bike, :customer).newest_first
  end

  def show
    # Already loaded with their services by set_repair.
    @repair_jobs = @repair.repair_jobs
  end

  # Reached from a bike's page as /repairs/new?bike_id=…, so the bike is
  # already chosen. The id is only used to look the bike up.
  def new
    @repair = Repair.new(bike: Bike.find_by(id: params[:bike_id]))
    add_blank_lines(NEW_REPAIR_BLANK_LINES)
  end

  def edit
    add_blank_lines(EDIT_REPAIR_BLANK_LINES)
  end

  def create
    @repair = Repair.new(repair_params)

    if @repair.save
      redirect_to @repair, notice: "Repair for #{@repair.customer.name}'s bike #{@repair.bike.serial_number} was taken in."
    else
      add_blank_lines(NEW_REPAIR_BLANK_LINES)
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @repair.update(repair_params)
      redirect_to @repair, notice: "Repair for #{@repair.customer.name}'s bike #{@repair.bike.serial_number} was updated."
    else
      add_blank_lines(EDIT_REPAIR_BLANK_LINES)
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @repair.destroy
      redirect_to repairs_path, notice: "Repair for #{@repair.customer.name}'s bike #{@repair.bike.serial_number} was deleted.", status: :see_other
    else
      redirect_to @repair, alert: "The repair was not deleted. #{@repair.errors.full_messages.to_sentence}.", status: :see_other
    end
  end

  private

  def set_repair
    @repair = Repair.includes(:bike, :customer, :intake_staff, :mechanic, :returned_by_staff, repair_jobs: :service).find(params[:id])
  end

  # Loaded once per request, so every select on the page (one per line for
  # the services) reuses the same rows instead of querying again.
  def load_form_choices
    @bikes = Bike.by_make_and_model.to_a
    @staff_members = StaffMember.by_role_and_name.to_a
    @mechanics = @staff_members.select(&:mechanic?)
    @services = Service.by_name.to_a
  end

  # Tops the repair up to `count` empty lines (lines with no service yet),
  # without touching the lines the person already filled in.
  def add_blank_lines(count)
    blank = @repair.repair_jobs.to_a.count { |line| line.new_record? && line.service_id.nil? }
    (count - blank).times { @repair.repair_jobs.build }
  end

  def repair_params
    params.expect(repair: [
      :bike_id, :intake_staff_id, :mechanic_id, :status,
      :promised_on, :quoted_at, :finished_at, :returned_at, :returned_by_staff_id,
      repair_jobs_attributes: [ [ :id, :service_id, :price_charged, :_destroy ] ]
    ])
  end
end
