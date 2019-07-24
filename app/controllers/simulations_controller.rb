class SimulationsController < ApplicationController
  def index
    @simulations = Simulation.where(user_id: current_user.id).order('date DESC')
    @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")
  end

  def sym
    @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")

    simulation_sym = Simulation.new(
      date: DateTime.now,
      market_type: "pool market",
      pricing_mechanism: "symetrical",
      user_id: current_user.id
    )
    simulation_sym.save

    (1..24).each do |per|
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
        bids << buyer.offers.where(period: per)
      end
      buyers_bids = bids.flatten.sort_by { |bid| bid.price }

      @my_sellers.each do |seller|
        offers << seller.offers.where(period: per)
      end
      sellers_offers = offers.flatten.sort_by { |offer| offer.price }

      demand_power = buyers_bids.sum { |a| a.energy }
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

      #### Set total power accepted#####
      total_power_sold = 0
      demand_accepted > offer_accepted ? total_power_sold = offer_accepted : total_power_sold = demand_accepted

      #### inform buyers if bids were accepted or not
      power = total_power_sold
      buyers_bids.reverse!

      buyers_traded_power = []
      sellers_traded_power = []

     ##############################################################
     ################    BUYERS RESULTS        ####################

      buyers_bids.each do |bid|
        if bid.price >= period_market_price
          if power > bid.energy
            ####criar resultado com traded_power = bid.power####

            result = Result.new(
              period: per,
              power: bid.energy,
              traded_power: bid.energy,
              price: bid.price,
              market_price: period_market_price,
              simulation_id: Simulation.last.id,
              agent_name: Agent.where(id: bid.agent_id)[0].name
            )
            result.save



            buyers_traded_power << bid.energy
            power -= bid.energy
          else
            #### criar resultado com traded_power = power

            result = Result.new(
              period: per,
              power: bid.energy,
              traded_power: power,
              price: bid.price,
              market_price: period_market_price,
              simulation_id: Simulation.last.id,
              agent_name: Agent.where(id: bid.agent_id)[0].name
            )
            result.save

            buyers_traded_power << power
            power = 0
          end
        else
          #### criar resultado com traded_power = 0 (no buy_bolsa)

          result = Result.new(
            period: per,
            power: bid.energy,
            traded_power: 0,
            price: bid.price,
            market_price: period_market_price,
            simulation_id: Simulation.last.id,
            agent_name: Agent.where(id: bid.agent_id)[0].name
          )
          result.save

          buyers_traded_power << 0
        end
      end

      ################################################################
      ####################  SELLERS RESULTS   ########################
      #### inform sellers if offers were accepted or not
      power = total_power_sold
      sellers_offers.each do |offer|
        if offer.price <= period_market_price
          if power > offer.energy
            ####criar resultado com traded_power = bid.power####
            result = Result.new(
              period: per,
              power: offer.energy,
              traded_power: offer.energy,
              price: offer.price,
              market_price: period_market_price,
              simulation_id: Simulation.last.id,
              agent_name: Agent.where(id: offer.agent_id)[0].name
            )
            result.save

            sellers_traded_power << offer.energy
            power -= offer.energy
          else
            #### criar resultado com traded_power = power

            result = Result.new(
              period: per,
              power: offer.energy,
              traded_power: power,
              price: offer.price,
              market_price: period_market_price,
              simulation_id: Simulation.last.id,
              agent_name: Agent.where(id: offer.agent_id)[0].name
            )
            result.save


            sellers_traded_power << power
            power = 0
          end
        else
          #### criar resultado com traded_power = 0 (no buy_bolsa)

          result = Result.new(
            period: per,
            power: offer.energy,
            traded_power: 0,
            price: offer.price,
            market_price: period_market_price,
            simulation_id: Simulation.last.id,
            agent_name: Agent.where(id: offer.agent_id)[0].name
          )
          result.save

          sellers_traded_power << 0
        end
      end
    end
    redirect_to simulation_path
  end

  def asym
    @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")

    simulation_asym = Simulation.new(
      date: DateTime.now,
      market_type: "pool market",
      pricing_mechanism: "assymetrical",
      user_id: current_user.id
    )
    simulation_asym.save

    (1..24).each do |per|
      bids = []
      offers = []
      period_market_price = 0
      ########### get offers and bids by order of price in each period#########
      @my_buyers.each do |buyer|
        bids << buyer.offers.where(period: per)
      end
      buyers_bids = bids.flatten

      @my_sellers.each do |seller|
        offers << seller.offers.where(period: per)
      end
      sellers_offers = offers.flatten.sort_by { |offer| offer.price }

      demand_power = buyers_bids.sum { |a| a.energy }

      # ##############Set market price##############

      accepted_power = 0

      if demand_power > 0
        sellers_offers.each do |offer|
          accepted_power < demand_power ? accepted_power += offer.energy && period_market_price = offer.price : break
        end
      end

      #### Set offers accepted#####
      demand_accepted = 0
      demand_accepted = demand_power
      demand_accepted = accepted_power if demand_power > accepted_power

      offer_accepted = 0
      sellers_offers.each do |offer|
        offer_accepted += offer.energy if offer.price <= period_market_price
      end

      #### Set total power accepted#####
      total_power_sold = 0
      demand_accepted > offer_accepted ? total_power_sold = offer_accepted : total_power_sold = demand_accepted


      #### inform buyers if bids were accepted or not
      power = total_power_sold

      buyers_traded_power = []
      sellers_traded_power = []

      buyers_bids.each do |bid|
        if power > 0
          if power > bid.energy
            ####criar resultado com traded_power = bid.power####
            result = Result.new(
              period: per,
              power: bid.energy,
              traded_power: bid.energy,
              price: bid.price,
              market_price: period_market_price,
              simulation_id: Simulation.last.id,
              agent_name: Agent.where(id: bid.agent_id)[0].name
            )
            result.save


            buyers_traded_power << bid.energy
            power -= bid.energy
          else
            #### criar resultado com traded_power = power
            result = Result.new(
              period: per,
              power: bid.energy,
              traded_power: power,
              price: bid.price,
              market_price: period_market_price,
              simulation_id: Simulation.last.id,
              agent_name: Agent.where(id: bid.agent_id)[0].name
            )
            result.save



            buyers_traded_power << power
            power = 0
          end
        else
          #### criar resultado com traded_power = 0 (no buy_bolsa)

          result = Result.new(
            period: per,
            power: bid.energy,
            traded_power: 0,
            price: bid.price,
            market_price: period_market_price,
            simulation_id: Simulation.last.id,
            agent_name: Agent.where(id: bid.agent_id)[0].name
          )
          result.save


          buyers_traded_power << 0
        end
      end

      #### inform sellers if offers were accepted or not
      power = total_power_sold
      sellers_offers.each do |offer|
        if offer.price <= period_market_price
          if power > offer.energy
            ####criar resultado com traded_power = bid.power####

            result = Result.new(
              period: per,
              power: offer.energy,
              traded_power: offer.energy,
              price: offer.price,
              market_price: period_market_price,
              simulation_id: Simulation.last.id,
              agent_name: Agent.where(id: offer.agent_id)[0].name
            )
            result.save

            sellers_traded_power << offer.energy
            power -= offer.energy
          else
            #### criar resultado com traded_power = power

            result = Result.new(
              period: per,
              power: offer.energy,
              traded_power: power,
              price: offer.price,
              market_price: period_market_price,
              simulation_id: Simulation.last.id,
              agent_name: Agent.where(id: offer.agent_id)[0].name
            )
            result.save



            sellers_traded_power << power
            power = 0
          end
        else
          #### criar resultado com traded_power = 0 (no buy_bolsa)

          result = Result.new(
            period: per,
            power: offer.energy,
            traded_power: 0,
            price: offer.price,
            market_price: period_market_price,
            simulation_id: Simulation.last.id,
            agent_name: Agent.where(id: offer.agent_id)[0].name
          )
          result.save

          sellers_traded_power << 0
        end
      end
    end
    redirect_to simulation_path
  end

  def bmsecondary







  end





end

