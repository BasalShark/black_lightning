##
# Admin controller for Venue management.
##
class Admin::VenuesController < AdminController
  load_and_authorize_resource

  ##
  # GET /venues
  #
  # GET /venues.json
  ##
  def index
    @venues = Venue.all
    @title = 'Venues'
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @venues }
    end
  end

  ##
  # GET /venues/1
  #
  # GET /venues/1.json
  ##
  def show
    @venue = Venue.find(params[:id])
    @title = @venue.name
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @venue }
    end
  end

  ##
  # GET /venues/new
  #
  # GET /venues/new.json
  ##
  def new
    @venue = Venue.new
    @title = 'New Venue'
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @venue }
    end
  end

  ##
  # GET /venues/1/edit
  ##
  def edit
    @venue = Venue.find(params[:id])
    @title = "Editing #{@venue.name}"
  end

  ##
  # POST /venues
  #
  # POST /venues.json
  ##
  def create
    @venue = Venue.new(venue_params)

    respond_to do |format|
      if @venue.save
        format.html { redirect_to admin_venue_path(@venue), notice: 'Venue was successfully created.' }
        format.json { render json: @venue, status: :created, location: @venue }
      else
        format.html { render 'new' }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  ##
  # PUT /venues/1
  #
  # PUT /venues/1.json
  ##
  def update
    @venue = Venue.find(params[:id])

    respond_to do |format|
      if @venue.update_attributes(venue_params)
        format.html { redirect_to admin_venue_path(@venue), notice: 'Venue was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render 'edit' }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  ##
  # DELETE /venues/1
  #
  # DELETE /venues/1.json
  ##
  def destroy
    @venue = Venue.find(params[:id])
    @venue.destroy

    respond_to do |format|
      format.html { redirect_to admin_venues_url }
      format.json { head :no_content }
    end
  end

  private
  def venue_params
    params.require(:venue).permit(:description, :image, :location, :name, :tagline,
                                  pictures_attributes: [:description, :image])
  end
end
