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
    pos = 0
    i = 0
    flag_price = false
    flag_end = false
    period_market_price = 0

    ########### get offers and bids by order of price in each period#########
    @my_buyers.each do |buyer|
      bids << buyer.offers.where(period: 1)
    end
    buyers_bids = bids.flatten.sort_by{ |bid| bid.price}

    @my_sellers.each do |seller|
      offers << seller.offers.where(period: 1)
    end
    sellers_offers = offers.flatten.sort_by{ |offer| offer.price }

    demand_power = buyers_bids.sum{ |a| a.energy }
    upper_limit = buyers_bids[0].price
    last_seller_tosold_price = sellers_offers[0].price

    # ##############Set market price##############
    while flag_price == false && flag_end == false
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
        flag_price = true
      end
      if pos < buyers_bids.size - 1
        demand_power -= buyers_bids[pos].energy
        lower_limit = upper_limit
        pos += pos
        upper_limit = buyers_bids[pos].price
      else
        flag_end = true
      end
    end

    #### Set offers accepted#####
    demand_accepted = 0
    buyers_bids.each do |bid|
      demand_accepted += bid.energy if bid.price >= period_market_price
    end

    offer_accepted = 0
    sellers_offers.each do |offer|
      offer_accepted += offer.energy if offer.price <= period_market_price
    end
byebug










     byebug
  end
end
