require 'csv'

#User.destroy_all
#Agent.destroy_all
# Transaction.destroy_all
# Auction.destroy_all
# Offer.destroy_all

CSV_OPTIONS = {
  col_sep: ';',
  quote_char: '"',
  headers: :first_row,
  header_converters: :symbol
}

CSV.foreach('./db/casestudies.csv', CSV_OPTIONS) do |row|
  casestudy = StudyCase.new(
    name: row[0],
    author: row[1],
    content: row[2],
    excel_url: row[3]
    )
  casestudy.save
end

CSV.foreach('./db/user.csv', CSV_OPTIONS) do |row|
  user = User.new(
    email: row[0],
    name: row[1],
    password: row[2]
    )
  user.save
end

CSV.foreach('./db/agents.csv', CSV_OPTIONS) do |row|
  agent = Agent.new(
    name: row[0],
    category: row[1],
    user_id: row[2]
    )
  agent.save
end

CSV.foreach('./db/offers.csv', CSV_OPTIONS) do |row|
  offer = Offer.new(
    price: row[0],
    energy: row[1],
    period: row[2],
    agent_id:row[3]
    )
  offer.save
end

CSV.foreach('./db/simulations.csv', CSV_OPTIONS) do |row|
  simulation = Simulation.new(
    date: row[0],
    market_type: row[1],
    pricing_mechanism: row[2],
    user_id: row[3]
    )
  simulation.save
end

CSV.foreach('./db/results.csv', CSV_OPTIONS) do |row|
  result = Result.new(
    period: row[0],
    power: row[1],
    traded_power: row[2],
    price: row[3],
    market_price: row[4],
    simulation_id: row[5],
    #agent_id: row[6]
    )
  result.save
end





