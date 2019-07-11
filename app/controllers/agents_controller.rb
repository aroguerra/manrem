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

    buyers_list.each_with_index do |buyer|
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
end
