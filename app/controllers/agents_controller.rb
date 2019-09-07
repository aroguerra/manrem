class AgentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")
  end

  def participants
    @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")
  end

  def participantsbm
    @my_bm_agents = BmAgent.where(user_id: current_user.id)
    @my_bm_units = @my_bm_agents.map { |agent| agent.bm_units }
    @my_bm_units.flatten!
    @my_bm_units_sec = []
    @my_bm_units_ter = []
    @my_bm_units.each do |unit|
      unit.market == "secondary" ? @my_bm_units_sec << unit : @my_bm_units_ter << unit
    end
  end

  def import
    xlsx = Roo::Spreadsheet.open(params[:file])

    Offer.destroy_all
    Agent.destroy_all

    buyers_list = xlsx.column(1).compact.drop(1)
    counter = 3
    ######CREATE BUYERS######

    buyers_list.each do |buyer|
      agent = Agent.new(
        name: buyer,
        category: 'Buyer',
        user_id: current_user.id
      )
      agent.save

      price_row = xlsx.row(counter).drop(2)
      energy_row = xlsx.row(counter + 1).drop(2)

      (1..24).each do |val|
        offer = Offer.new(
          price: price_row[val - 1],
          energy: energy_row[val - 1],
          period: val,
          agent_id: Agent.last.id
        )
        offer.save
      end
      counter += 2
    end
    xlsx.default_sheet = xlsx.sheets.last #change to sellers list

    ######CREATE SELLERS######

    sellers_list = xlsx.column(1).compact.drop(1)
    counter = 3
    sellers_list.each do |seller|
      agent = Agent.new(
        name: seller,
        category: 'Seller',
        user_id: current_user.id
      )
      agent.save

      price_row = xlsx.row(counter).drop(2)
      energy_row = xlsx.row(counter + 1).drop(2)

      (1..24).each do |val|
        offer = Offer.new(
          price: price_row[val - 1],
          energy: energy_row[val - 1],
          period: val,
          agent_id: Agent.last.id
        )
        offer.save
      end
      counter += 2
    end
  end

  def importbmsec
    xlsx = Roo::Spreadsheet.open(params[:file])

    BmUnitOffer.destroy_all
    BmUnit.destroy_all
    BmAgent.destroy_all

    buyers_list = xlsx.column(1).compact.drop(1)
    buyers_list.each do |buyer|
      agent = BmAgent.new(
        name: buyer,
        user_id: current_user.id
      )
      agent.save
    end

    xlsx.default_sheet = xlsx.sheets.second

    counter = 3
    unit_list = xlsx.column(2).compact.drop(1)

    unit_list.each do
      unit_row = xlsx.row(counter)

      unit = BmUnit.new(
        name: unit_row[1],
        category: unit_row[2],
        fuel: unit_row[3],
        bm_agent_id: BmAgent.where(name: unit_row[0])[0].id,
        market: "secondary"
      )
      unit.save

      energy_row = xlsx.row(counter + 1).compact.drop(1)
      price_row = xlsx.row(counter).drop(5)

      (1..24).each do |val|
        offer = BmUnitOffer.new(
          price: price_row[val - 1],
          energy: energy_row[val - 1],
          energy_down: energy_row[val - 1] * -0.5,
          period: val,
          bm_unit_id: BmUnit.last.id
        )
        offer.save
      end
      counter += 2
    end

    xlsx.default_sheet = xlsx.sheets.third

    counter = 3
    unit_list = xlsx.column(2).compact.drop(1)

    unit_list.each do
      unit_row = xlsx.row(counter)

      unit = BmUnit.new(
        name: unit_row[1],
        category: unit_row[2],
        fuel: unit_row[3],
        bm_agent_id: BmAgent.where(name: unit_row[0])[0].id,
        market: "terciary"
      )
      unit.save

      energy_row = xlsx.row(counter + 1).compact.drop(1)
      price_row = xlsx.row(counter).drop(5)

      (1..24).each do |val|
        offer = BmUnitOffer.new(
          price: price_row[val - 1],
          energy: energy_row[val - 1],
          energy_down: energy_row[val - 1] * -0.5,
          period: val,
          bm_unit_id: BmUnit.last.id
        )
        offer.save
      end
      counter += 2
    end
  end

  def importbmter
    xlsx = Roo::Spreadsheet.open(params[:file])

    BmUnitOffer.destroy_all
    BmUnit.destroy_all
    BmAgent.destroy_all

    buyers_list = xlsx.column(1).compact.drop(1)
    buyers_list.each do |buyer|
      agent = BmAgent.new(
        name: buyer,
        user_id: current_user.id
      )
      agent.save
    end

    xlsx.default_sheet = xlsx.sheets.second

    counter = 3
    unit_list = xlsx.column(2).compact.drop(1)

    unit_list.each do
      unit_row = xlsx.row(counter)

      unit = BmUnit.new(
        name: unit_row[1],
        category: unit_row[2],
        fuel: unit_row[3],
        bm_agent_id: BmAgent.where(name: unit_row[0])[0].id,
        market: "terciary"
      )
      unit.save

      energy_row = xlsx.row(counter + 1).compact.drop(1)
      price_row = xlsx.row(counter).drop(5)

      (1..24).each do |val|
        offer = BmUnitOffer.new(
          price: price_row[val - 1],
          energy: energy_row[val - 1],
          energy_down: energy_row[val - 1] * -0.5,
          period: val,
          bm_unit_id: BmUnit.last.id
        )
        offer.save
      end
      counter += 2
    end
  end






  def importsecneed
    xlsx = Roo::Spreadsheet.open(params[:file])
    BmSecondaryNeed.destroy_all

    previsions = xlsx.column(2).drop(1)

    (1..24).each do |val|
      secondary_needs = BmSecondaryNeed.new(
        prevision: previsions[val - 1],
        period: val,
        user_id: current_user.id
      )
      secondary_needs.save
    end
  end

  def importtercneed

    xlsx = Roo::Spreadsheet.open(params[:file])

    BmTerciaryDayAheadPrice.destroy_all
    BmTerciaryNeed.destroy_all

    prices = xlsx.column(2).drop(1)

    (1..24).each do |val|
      bm_terciary_day_ahead_prices = BmTerciaryDayAheadPrice.new(
        price: prices[val - 1].round(2),
        period: val,
        user_id: current_user.id
      )
      bm_terciary_day_ahead_prices.save
    end

    xlsx.default_sheet = xlsx.sheets.second

    (3..98).each do |val|
      bm_terciary_needs = BmTerciaryNeed.new(
        hour: ((val - 3) / 4).floor,
        down_band: xlsx.row(val)[1],
        up_band: xlsx.row(val)[2],
        forecast: xlsx.row(val)[3],
        observed_production: xlsx.row(val)[4],
        portugal_consumption: xlsx.row(val)[5],
        balance_imp_exp: xlsx.row(val)[6],
        day_ahead_power_pt: xlsx.row(val)[7],
        user_id: current_user.id
      )
      bm_terciary_needs.save
    end
  end
end

