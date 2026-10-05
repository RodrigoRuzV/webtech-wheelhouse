# Lab 9: removes one intake photo of a repair, leaving the others in place.
# Reached from the repair's page and its edit page through a button_to with
# method: :delete and Turbo's confirmation; there is no GET route for it.
#
# The photo is looked up through the repair, so the id of a photo of another
# repair is a 404. purge deletes the attachment row and the blob row (with its
# variant records and files), so no row is left behind for that file. A blob
# that is also attached elsewhere (the seed reuses files) is kept, because the
# other attachment still points to it.
class RepairPhotosController < ApplicationController
  def destroy
    repair = Repair.find(params[:repair_id])
    photo = repair.photos.find(params[:id])
    filename = photo.filename.to_s

    photo.purge

    redirect_back_or_to repair, notice: "Photo “#{filename}” was removed.", status: :see_other
  end
end
