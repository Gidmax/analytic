class PostcardsController < ApplicationController
  before_action :set_postcard, only: [:show, :edit, :update, :destroy]

  # GET /postcards
  # GET /postcards.json
  def index
    @postcards = Postcard.all
  end

  # GET /postcards/1
  # GET /postcards/1.json
  def show
  end

  # GET /postcards/new
  def new
    @postcard = Postcard.new
  end

  # GET /postcards/1/edit
  def edit
  end

  # POST /postcards
  # POST /postcards.json
  def create
    @postcard = Postcard.new(postcard_params)

    respond_to do |format|
      if @postcard.save
        format.html { redirect_to @postcard, notice: 'Postcard was successfully created.' }
        format.json { render :show, status: :created, location: @postcard }
      else
        format.html { render :new }
        format.json { render json: @postcard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /postcards/1
  # PATCH/PUT /postcards/1.json
  def update
    respond_to do |format|
      if @postcard.update(postcard_params)
        format.html { redirect_to @postcard, notice: 'Postcard was successfully updated.' }
        format.json { render :show, status: :ok, location: @postcard }
      else
        format.html { render :edit }
        format.json { render json: @postcard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /postcards/1
  # DELETE /postcards/1.json
  def destroy
    @postcard.destroy
    respond_to do |format|
      format.html { redirect_to postcards_url, notice: 'Postcard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_postcard
      @postcard = Postcard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def postcard_params
      params.require(:postcard).permit(:title, :desc, :ix, :src)
    end
end
