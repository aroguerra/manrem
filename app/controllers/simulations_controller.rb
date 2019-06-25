class SimulationsController < ApplicationController

  def index
    @simulations = Simulation.where(user_id: current_user.id).order('date DESC')
    @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")
  end

  def sym
    @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")

    bids = []
    offers = []


    @my_buyers.each do |buyer|
      bids << buyer.offers.where(period: 1)
    end
    buyers_bids = bids.flatten.sort_by{ |bid| bid.price}

    @my_sellers.each do |seller|
      offers << seller.offers.where(period: 1)
    end
    sellers_offers = offers.flatten.sort_by{ |offer| offer.price }

    byebug

  end
end
