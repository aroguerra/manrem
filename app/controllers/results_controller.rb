class ResultsController < ApplicationController
  def show
    @simulation = Simulation.find(params[:simulation_id])
    @results = Result.all
    @a = @results.where(simulation_id: @simulation.id).sort_by {|result| [result.agent_name, result.period]}

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
    @a = @results.where(simulation_id: @simulation.id).sort_by {|result| [result.bm_unit_name, result.period]}

    respond_to do |format|
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=items.xlsx"
      }
      format.html { render :showbm }
    end
  end

  def showbmter
    @simulation = Simulation.find(params[:simulation_id])
    @results = BmTerciaryResult.where(simulation_id: Simulation.find(params[:simulation_id]))
    @a = @results.where(simulation_id: @simulation.id).sort_by {|result| [result.bm_unit_name, result.period]}

    # @results.each do |result|
    #   result.ter_need_up.zero? ? @down << result : @up << result
    # end

    respond_to do |format|
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=items.xlsx"
      }
      format.html { render :showbmter }
    end
  end
end
