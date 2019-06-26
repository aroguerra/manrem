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
    offer_power = 0
    last_seller_price = 0
    lower_limit = 0
    pos
    i = 0

    @my_buyers.each do |buyer|
      bids << buyer.offers.where(period: 1)
    end
    buyers_bids = bids.flatten.sort_by{ |bid| bid.price}

    @my_sellers.each do |seller|
      offers << seller.offers.where(period: 1)
    end
    sellers_offers = offers.flatten.sort_by{ |offer| offer.price }


    demand_power = buyers_bids.sum{|a| a.energy}
    upper_limit = buyers_bids[0].price
    last_seller_tosold_price = sellers_offers[0].price

    sellers_offers.each do |offer|
      offer_power += offer.energy
      last_seller_tosold_price = offer.price
      i += 1
      break if offer_power >= demand_power
    end

    if sellers_offers.size > i + 1
      last_seller_price = sellers_offers[i + 1].price
    else
      last_seller_price = last_seller_tosold_price
    end

    if last_seller_tosold_price <= upper_limit
      if last_seller_tosold_price >= lower_limit
        period_market_price = last_seller_tosold_price
      elsif lower_limit > last_seller_tosold_price
        if lower_limit < last_seller_price
          period_market_price = lower_limit
        else
          period_market_price = last_seller_tosold_price
        end
      end
    elsif
    end





     byebug
  end
end
