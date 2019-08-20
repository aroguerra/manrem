class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home], raise: false

  def home
  end

  def dashboard
    @my_simulations = Simulation.where(user_id: current_user.id)
    @my_simulations_pool = Simulation.where(user_id: current_user.id, market_type: "pool market")
    @my_simulations_pool_asym = Simulation.where(user_id: current_user.id, market_type: "pool market", pricing_mechanism: "assymetrical")
    @my_simulations_pool_sym = Simulation.where(user_id: current_user.id, market_type: "pool market", pricing_mechanism: "symetrical")

    @my_simulations_bm_sec = Simulation.where(user_id: current_user.id, market_type: "balance market", pricing_mechanism: "secondary")
    @my_simulations_bm_ter = Simulation.where(user_id: current_user.id, market_type: "balance market", pricing_mechanism: "terciary")


    @my_agents = Agent.where(user_id: current_user.id)
    @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")

    @my_bm_agents = BmAgent.where(user_id: current_user.id)
    @my_bm_units = BmUnit.where(bm_agent_id: @my_bm_agents)



  end

end
