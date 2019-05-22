class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home], raise: false

  def home
  end

  def dashboard
    @my_simulations = Simulation.where(user_id: current_user.id)
    @my_simulations_pool = Simulation.where(user_id: current_user.id, market_type: "pool market")
    @my_simulations_pool_asym = Simulation.where(user_id: current_user.id, market_type: "pool market", pricing_mechanism: "assymetrical")
    @my_simulations_pool_sym = Simulation.where(user_id: current_user.id, market_type: "pool market", pricing_mechanism: "symetrical")


    @my_agents = Agent.where(user_id: current_user.id)
    @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")
  end

end
