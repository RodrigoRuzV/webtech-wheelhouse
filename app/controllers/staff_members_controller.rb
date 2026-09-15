class StaffMembersController < ApplicationController
  def index
    # Grouped by role, then alphabetical: the owner looks for "a mechanic"
    # before looking for a specific person.
    @staff_members = StaffMember.order(:role, :name)
  end

  def show
    @staff_member = StaffMember.find(params[:id])
    @mechanic_repairs = @staff_member.mechanic_repairs.includes(:bike, :customer).order(created_at: :desc)
  end
end
