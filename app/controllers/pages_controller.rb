class PagesController < ApplicationController
  def home
  end

  def services
    @jobs = Service.order(:name)
  end

  def visiting
  end

  def about
  end
end
