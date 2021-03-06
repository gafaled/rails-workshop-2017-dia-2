class BoardsController < ApplicationController
  before_action :set_board, only: [:show, :edit, :update, :destroy]

  # GET /boards
  # GET /boards.json
  def index
    @boards = current_user.boards
  end

  # GET /boards/1
  # GET /boards/1.json
  def show
    @lists = @board.lists
  end

  # GET /boards/new
  def new
    @board = Board.new

    begin
      importer = TrelloBoardsImporter.init_for_user(current_user)
      @trello_boards = importer.boards
    rescue Trello::Error
      @trello_importer_error = true
    end
  end

  # GET /boards/1/edit
  def edit
  end

  # POST /boards
  # POST /boards.json
  def create
    @board = current_user.boards.build(board_params)

    respond_to do |format|
      if @board.save
        format.html { redirect_to @board, notice: 'Board was successfully created.' }
        format.json { render :show, status: :created, location: @board }
      else
        format.html { render :new }
        format.json { render json: @board.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /boards/1
  # PATCH/PUT /boards/1.json
  def update
    respond_to do |format|
      if @board.update(board_params)
        format.html { redirect_to @board, notice: 'Board was successfully updated.' }
        format.json { render :show, status: :ok, location: @board }
      else
        format.html { render :edit }
        format.json { render json: @board.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /boards/1
  # DELETE /boards/1.json
  def destroy
    @board.destroy
    respond_to do |format|
      format.html { redirect_to boards_url, notice: 'Board was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    importer = TrelloBoardsImporter.init_for_user(current_user)
    @board = importer.import(trello_board_id_param)

    current_user.boards << @board

    @board.save!

    redirect_to @board, notice: 'Board was successfully updated.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_board
      @board = Board.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def board_params
      params.require(:board).permit(:name, :visibility, :favorite)
    end

    def trello_board_id_param
      params.require(:trello_board_id)
    end
end
