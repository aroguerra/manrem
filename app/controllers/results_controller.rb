class ResultsController < ApplicationController
  def show
    @simulation = Simulation.find(params[:simulation_id])
    @results = Result.all

    respond_to do |format|
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=items.xlsx"
      }
      format.html { render :show }
    end
  end

  def showbm
    @simulation = Simulation.find(params[:simulation_id])
    @results = BmSecondaryResult.all

    respond_to do |format|
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=items.xlsx"
      }
      format.html { render :showbm }
    end
  end
end
