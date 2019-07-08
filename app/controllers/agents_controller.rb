class AgentsController < ApplicationController


  def index
    @my_buyers = Agent.where(user_id: current_user.id, category: "Buyer")
    @my_sellers = Agent.where(user_id: current_user.id, category: "Seller")
  end

  def import
    xlsx = Roo::Spreadsheet.open(params[:file])
    byebug
  end

end
