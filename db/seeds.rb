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
