class ResultsController < ApplicationController

  def show
    @results = Result.all
  end

end
