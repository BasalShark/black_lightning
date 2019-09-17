##
# Controller for Admin::EditableBlock. More details can be found there.
##

class Admin::EditableBlocksController < AdminController
  load_and_authorize_resource class: Admin::EditableBlock

  ##
  # GET /admin/editable_blocks
  #
  # GET /admin/editable_blocks.json
  ##
  def index
    @admin_editable_blocks = Admin::EditableBlock.all.group_by(&:group)
    @title = 'Editable Blocks'
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_editable_blocks }
    end
  end

  ##
  # GET /admin/editable_blocks/new
  #
  # GET /admin/editable_blocks/new.json
  ##
  def new
    @admin_editable_block = Admin::EditableBlock.new
    @admin_editable_block.name = params[:name]

    @title = 'New Editable Block'
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_editable_block }
    end
  end

  ##
  # GET /admin/editable_blocks/1/edit
  ##
  def edit
    @admin_editable_block = Admin::EditableBlock.find(params[:id])
    @title = "Edit #{@admin_editable_block.name}"
  end

  ##
  # POST /admin/editable_blocks
  #
  # POST /admin/editable_blocks.json
  ##
  def create
    @admin_editable_block = Admin::EditableBlock.new(editable_block_params)

    respond_to do |format|
      if @admin_editable_block.save
        format.html { redirect_to admin_editable_blocks_url, notice: 'Editable block was successfully created.' }
        format.json { render json: admin_editable_blocks_url, status: :created, location: @admin_editable_block }
      else
        format.html { render 'new' }
        format.json { render json: admin_editable_blocks_url.errors, status: :unprocessable_entity }
      end
    end
  end

  ##
  # PUT /admin/editable_blocks/1
  #
  # PUT /admin/editable_blocks/1.json
  ##
  def update
    @admin_editable_block = Admin::EditableBlock.find(params[:id])

    respond_to do |format|
      if @admin_editable_block.update_attributes(editable_block_params)
        format.html { redirect_to admin_editable_blocks_url, notice: 'Editable block was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render 'edit' }
        format.json { render json: admin_editable_blocks_url.errors, status: :unprocessable_entity }
      end
    end
  end

  ##
  # DELETE /admin/editable_blocks/1
  #
  # DELETE /admin/editable_blocks/1.json
  ##
  def destroy
    @admin_editable_block = Admin::EditableBlock.find(params[:id])
    @admin_editable_block.destroy

    respond_to do |format|
      format.html { redirect_to admin_editable_blocks_url }
      format.json { head :no_content }
    end
  end

  private
  def editable_block_params
    params.require(:admin_editable_block).permit(:content, :name, :admin_page, :group,
                                                 attachments_attributes: [:name, :file])
  end
end
