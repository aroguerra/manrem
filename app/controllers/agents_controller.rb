class AgentsController < ApplicationController
  def index
    @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")
  end

  def participants
    @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")
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

  def importbm
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
        bm_agent_id: BmAgent.where(name: unit_row[0])[0].id
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
end

