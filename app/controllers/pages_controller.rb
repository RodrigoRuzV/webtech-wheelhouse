class PagesController < ApplicationController
  def home
  end

  def services
    @jobs = [
      { name: "Tune-up", price: 45 },
      { name: "Brake adjustment", price: 25 },
      { name: "Brake pad replacement", price: 35 },
      { name: "Brake bleed", price: 40 },
      { name: "Chain replacement", price: 30 },
      { name: "Cable replacement", price: 20 },
      { name: "Flat tire repair", price: 15 },
      { name: "Tire replacement", price: 25 },
      { name: "Wheel truing", price: 30 },
      { name: "Spoke replacement", price: 12 },
      { name: "Gear tuning", price: 25 },
      { name: "Bearing service", price: 35 },
      { name: "Frame alignment check", price: 40 },
      { name: "Full overhaul", price: 120 }
    ]
  end

  def visiting
  end

  def about
  end
end
