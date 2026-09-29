class StaffMembersController < ApplicationController
  before_action :set_staff_member, only: %i[show edit update destroy]

  def index
    # Grouped by role, then alphabetical: the owner looks for "a mechanic"
    # before looking for a specific person.
    @staff_members = StaffMember.by_role_and_name
  end

  def show
    @mechanic_repairs = @staff_member.mechanic_repairs.includes(:bike, :customer).newest_first
  end

  def new
    @staff_member = StaffMember.new
  end

  def edit
  end

  def create
    @staff_member = StaffMember.new(staff_member_params)

    if @staff_member.save
      redirect_to @staff_member, notice: "#{@staff_member.name} joined the staff as #{@staff_member.role}."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @staff_member.update(staff_member_params)
      redirect_to @staff_member, notice: "#{@staff_member.name} was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @staff_member.destroy
      redirect_to staff_members_path, notice: "#{@staff_member.name} was removed from the staff.", status: :see_other
    else
      redirect_to @staff_member, alert: "#{@staff_member.name} was not deleted. #{@staff_member.errors.full_messages.to_sentence}.", status: :see_other
    end
  end

  private

  def set_staff_member
    @staff_member = StaffMember.find(params[:id])
  end

  def staff_member_params
    params.expect(staff_member: [ :name, :role ])
  end
end
