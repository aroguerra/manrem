class SimulationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @simulations = Simulation.where(user_id: current_user.id).order('date DESC')
    @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")
  end

  def sym

    buyers_participants = params[:idb].keys
    sellers_participants = params[:ids].keys

    @my_buyers = buyers_participants.map { |participant| Agent.where(id: participant.to_i)}
    @my_buyers.flatten!
    @my_sellers = sellers_participants.map { |participant| Agent.where(id: participant.to_i)}
    @my_sellers.flatten!

    # @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    # @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")

      #byebug
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
    redirect_to simulations_path
  end

  def asym
    buyers_participants = params[:idb].keys
    sellers_participants = params[:ids].keys

    @my_buyers = buyers_participants.map { |participant| Agent.where(id: participant.to_i) }
    @my_buyers.flatten!
    @my_sellers = sellers_participants.map { |participant| Agent.where(id: participant.to_i) }
    @my_sellers.flatten!

    # @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    # @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")

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
          accepted_power < demand_power ? accepted_power += offer.energy : break
          period_market_price = offer.price
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
    redirect_to simulations_path
  end

  def bmsecondary

    units_participants = params[:idb].keys

    previsions = BmSecondaryNeed.where(user_id: current_user.id)
    bm_units = units_participants.map { |participant| BmUnit.where(id: participant.to_i) }#where participant equals true
    bm_units.flatten!

    simulation_sym = Simulation.new(
      date: DateTime.now,
      market_type: "balance market",
      pricing_mechanism: "secondary",
      user_id: current_user.id
    )
    simulation_sym.save

    sorted_offers = BmUnitOffer.joins(:bm_unit)
                               .select('bm_unit_offers.bm_unit_id,
                                        bm_unit_offers.id,
                                        bm_unit_offers.energy,
                                        bm_unit_offers.energy_down,
                                        bm_unit_offers.period,
                                        bm_unit_offers.price')
                               .order('bm_unit_offers.price ASC')

    # bm_units.each do |unit|
    #   sorted_offers << sorted_offers_all.where(bm_unit_id: unit.id)
    # end

    sorted_offers_aux = sorted_offers
    reserve = sorted_offers

    system_needs_up = previsions.map { |x| (Math.sqrt(x.prevision * 10 + (150 * 150)) - 150).round }
    system_needs_down = system_needs_up.map { |x| (x * (-0.5)).round }

    energy_down = 0
    energy_up = 0
    down_exceed = 0
    up_exceed = 0
    ag = 0
    aux = sorted_offers.first.price
    hour_results = []


    (0..23).each do |per|
     # byebug
      energy_down = 0
      energy_up = 0
      down_exceed = 0
      up_exceed = 0
      ag = 0
      aux = sorted_offers.where(period: per + 1).first.price
      row = []
      offers = []
      offers_aux = []
      reserve = []
      up_sum = 0
      down_sum = 0
      hour_results = []

     # byebug

      sorted_offers.where(period: per + 1).each do |offer|
        row = []
        row << offer.bm_unit_id
        row << offer.energy_down
        row << offer.energy
        row << offer.price
        offers << row
      end

      sorted_offers.where(period: per + 1).each do |offer|
        row = []
        row << offer.bm_unit_id
        row << offer.energy_down
        row << offer.energy
        row << offer.price
        offers_aux << row
      end

      sorted_offers.where(period: per + 1).each do |offer|
        row = []
        row << offer.bm_unit_id
        row << offer.energy_down
        row << offer.energy
        row << offer.price
        reserve << row
      end

      if system_needs_up[per] != 0 && system_needs_down[per] != 0
        catch :done do
          (1..bm_units.count).each do |val1|
            # byebug
            (1..bm_units.count).each do |val2|
              # byebug
              if offers[val2 - 1][3] <= aux && (energy_down > 0.9 * system_needs_down[per] || energy_up < 0.9 * system_needs_up[per])
                # byebug
                aux = offers[val2 - 1][3]
                ag = val2 - 1
              elsif energy_down <= 0.9 * system_needs_down[per] && energy_up >= 0.9 * system_needs_up[per]
                # byebug
                throw :done
              end
            end
            aux = 180

            if energy_up + offers[ag][2] < 0.9 * system_needs_up[per] || energy_down + offers[ag][1] > 0.9 * system_needs_down[per]
              energy_up += offers[ag][2]
              energy_down += offers[ag][1]
              # byebug

              if energy_down > 0.9 * system_needs_down[per] || energy_up < 0.9 * system_needs_up[per]
                if (0.9 * system_needs_down[per] - energy_down) > 0 || (0.9 * system_needs_up[per] - energy_up) < 0
                  if (0.9 * system_needs_down[per] - energy_down) > 0
                    down_exceed == 0 ? offers_aux[ag][1] = offers_aux[ag][1] - (system_needs_down[per] - energy_down) : offers_aux[ag][1] = 0
                  end
                  if (0.9 * system_needs_up[per] - energy_up) < 0
                    up_exceed == 0 ? offers_aux[ag][2] = offers_aux[ag][2] - (system_needs_up[per] - energy_up) : offers_aux[ag][2] = 0
                    up_exceed += 1
                  end
                  # byebug
                  hour_results << offers_aux[ag]
                else
                  # byebug
                  hour_results << reserve[ag]
                end
                # byebug
                offers[ag][3] = 1000
              end
            else
              if (0.9 * system_needs_down[per] - energy_down) < 0
                ####
                # byebug
              else
                offers[ag][1] = 0
              end
              if (0.9 * system_needs_up[per] - energy_up) > 0
                ###
                # byebug
              else
                offers[ag][2] = 0
              end
              # byebug
              hour_results << offers[ag]
              # byebug
              throw :done
            end
           # byebug
            puts "entrou #{per}1"
          end
         # byebug
            puts "entrou #{per}2"

        end
       # byebug
        puts "entrou #{per}3"
        up_sum = hour_results.sum { |x| x[2] }
        down_sum = hour_results.sum { |x| x[1] }
        id_array = []

        hour_results.each do |array|
          id_array << array[0]
          result = BmSecondaryResult.new(
            bm_agent_name: BmAgent.where(id: BmUnit.where(id: array[0])[0].bm_agent_id)[0].name,
            bm_unit_name: BmUnit.where(id: array[0])[0].name,
            period: per,
            power: BmUnitOffer.where(bm_unit_id: array[0], period: per + 1)[0].energy,
            down_traded: array[1],
            power_down: down_sum,
            up_traded: array[2],
            power_up: up_sum,
            price: BmUnitOffer.where(bm_unit_id: array[0], period: per + 1)[0].price,
            market_price: hour_results.last[3],
            system_down_needs: system_needs_down[per],
            system_up_needs: system_needs_up[per],
            simulation_id: Simulation.last.id
          )
          result.save
        end
       # byebug
        bm_units.each do |unit|
          next if id_array.include?(unit.id)
          result = BmSecondaryResult.new(
            bm_agent_name: BmAgent.where(id: BmUnit.where(id: unit.id)[0].bm_agent_id)[0].name,
            bm_unit_name: unit.name,
            period: per,
            power: BmUnitOffer.where(bm_unit_id: unit.id, period: per + 1)[0].energy,
            down_traded: 0,
            power_down: down_sum,
            up_traded: 0,
            power_up: up_sum,
            price: BmUnitOffer.where(bm_unit_id: unit.id, period: per + 1)[0].price,
            market_price: hour_results.last[3],
            system_down_needs: system_needs_down[per],
            system_up_needs: system_needs_up[per],
            simulation_id: Simulation.last.id
          )
          result.save
        end
      end
     # byebug
      puts "entrou #{per}4"
    end
    redirect_to simulations_path
  end

  def bmterciary
    units_participants = params[:idb].keys

    #bm_units = units_participants.map { |participant| BmUnit.where(id: participant.to_i) }#where participant equals true
    #bm_units_test = BmUnit.where(units_participants)
    #bm_units.flatten!

    simulation_sym = Simulation.new(
      date: DateTime.now,
      market_type: "balance market",
      pricing_mechanism: "terciary",
      user_id: current_user.id
    )
    simulation_sym.save

    offers_all = BmUnitOffer.joins(:bm_unit)
                               .select('bm_unit_offers.bm_unit_id,
                                        bm_unit_offers.id,
                                        bm_unit_offers.energy,
                                        bm_unit_offers.energy_down,
                                        bm_unit_offers.period,
                                        bm_unit_offers.price')
                               .order('bm_unit_offers.price ASC')

    sorted_offers = offers_all.where(bm_unit_id: units_participants)
    # bm_units.each do |unit|
    #   sorted_offers << BmUnitOffer.where(bm_unit_id: unit.id)
    #   byebug
    # end
    reserve = sorted_offers

    desvio = 0
    needy = 0
    needysec = 0

    secondary_up = 0
    secondary_down = 0
    terciary_up = 0
    terciary_down = 0

    ter_needs_up = []
    sec_needs_up = []
    ter_needs_down = []
    sec_needs_down = []

    (0..23).each do |per|
      hour_need = BmTerciaryNeed.where(hour: per, user_id: current_user.id)

      secondary_up = 0
      secondary_down = 0
      terciary_up = 0
      terciary_down = 0

      hour_need.each do |need|
        desvio = need.observed_production - need.forecast
        needy = ((-(need.day_ahead_power_pt - (need.portugal_consumption + need.balance_imp_exp) + desvio)) / 4) * 0.9
        needysec = ((-(need.day_ahead_power_pt - (need.portugal_consumption + need.balance_imp_exp) + desvio)) / 4) * 0.1

        needy.positive? ? terciary_up += needy : terciary_down += needy
        needysec.positive? ? secondary_up += needysec : secondary_down += needysec
      end

      ter_needs_up << terciary_up.round(2)
      sec_needs_up << secondary_up.round(2)
      ter_needs_down << terciary_down.round(2)
      sec_needs_down << secondary_down.round(2)
    end




    ter_needs_up.each_with_index do |need, index|

      if sec_needs_up[index] < up_band
        res = sec_needs_up[index]
      if sec_needs_up[index] = up_band
        res = 0
      if sec_needs_up[index] > up_band
        res = up_band



      hour_results = []
      ag = 0
      energy = 0
      aux = sorted_offers.where(period: index + 1).first.price
      row = []
      offers = []
      reserve = []

      sorted_offers.where(period: index + 1).each do |offer|
        row = []
        row << offer.bm_unit_id
        offer.energy.positive? ? row << offer.energy : row << 0
        row << offer.price
        offers << row
      end

      sorted_offers.where(period: index + 1).each do |offer|
        row = []
        row << offer.bm_unit_id
        offer.energy.positive? ? row << offer.energy : row << 0
        row << offer.price
        reserve << row
      end

      #byebug
         #needs up
      catch :done do
        (1..units_participants.count).each do |val1|
           #byebug
          (1..units_participants.count).each do |val2|
            #byebug
            if offers[val2 - 1][2] <= aux && energy < need
              #byebug
              aux = offers[val2 - 1][2]
              ag = val2 - 1
            elsif energy >= need
              #byebug
              throw :done
            end
          end
          aux = 180

          if energy + offers[ag][1] < need
            energy += offers[ag][1]
            hour_results << reserve[ag]
            if energy < need
              offers[ag][2] = 1000
            end
          else
            offers[ag][1] = need - energy
            hour_results << offers[ag]
            throw :done
          end
        end
         byebug
      end
      byebug#results squi
    end
end


result = BmTerciaryResult.new(
            bm_agent_name:
            bm_unit_name:
            period:
            down_traded:
            energy_down:
            energy_down_price:
            market_price_down:
            up_traded:
            energy_up:
            energy_up_price:
            market_price_up:
            total_energy_down:
            total_energy_down:
            ter_needs_down:
            ter_needs_up:
            sec_needs_down:
            sec_needs_up:
            simulation_id: Simulation.last.id
          )
          result.save





        #guardar results
      #needs down
      # ter_needs_down.each_with_index do |need, index|
      #   catch :done do
      #     (1..bm_units.count).each do |val1|
      #       # byebug
      #       (1..bm_units.count).each do |val2|
      #         # byebug
      #         if offers[val2 - 1][3] <= aux && energy < need
      #           # byebug
      #           aux = offers[val2 - 1][3]
      #           ag = val2 - 1
      #         elsif energy >= need
      #           # byebug
      #           throw :done
      #         end
      #       end
      #       aux = 180

      #       if energy + offers[ag][1] < ter_needs_down
      #         energy += offers[ag][1]
      #         hour_results << reserve[ag]
      #         if energy < ter_needs_down
      #           offers[ag][3] = 1000
      #         end
      #       else
      #         offers[ag][3] = ter_needs_down - energy
      #         hour_results << offers[ag]
      #         throw :done
      #       end
      #     end
      #   end
      # end












  def destroy
    @simulation = Simulation.find(params[:id])
    @simulation.destroy

    redirect_to simulations_path
  end
end
