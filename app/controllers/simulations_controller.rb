class SimulationsController < ApplicationController

  def index
    @simulations = Simulation.where(user_id: current_user.id).order('date DESC')
  end
end
