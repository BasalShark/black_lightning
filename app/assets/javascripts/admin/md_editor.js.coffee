# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

addHandlers = ->
  jQuery("a[href$=\"preview\"]").on "shown", (e) ->
    id = undefined
    input = undefined
    id = $(e.currentTarget).data("preview-id")
    input = $("#" + id + "_input_field textarea")

    $("#" + id + "_preview").html('<b>Please Wait</b>');

    $.ajax({
      type: 'POST',
      url: '/markdown/preview.json',
      data: JSON.stringify({ input_html: input.val() }),
      success: (data) ->
        preview = $("#" + id + "_preview")
        preview.html(data.rendered_md);
        return
      error: (jqXHR, textStatus, errorThrown) ->
        error_data = JSON.parse(jqXHR.responseText)
        error_html =  """
                      <b>There was an error rendering your kramdown.</b>
                      <pre>#{error_data.error}</pre>
                      """
        $("#" + id + "_preview").html(error_html);
    });


jQuery ->
  addHandlers()

$(document).on "nested:fieldAdded", (event) ->
  new_id = new Date().getTime();

  ###
    Slightly hacky way of making all the ids unique and updating the necessary anchors.
  ###
  jQuery(event.field).find('[id$="_input_field"]').attr('id', new_id + '_input_field');
  jQuery(event.field).find('[href$="_input_field"]').attr('href', '#' + new_id + '_input_field');
  jQuery(event.field).find('[id$="_preview"]').attr('id', new_id + '_preview');
  jQuery(event.field).find('[href$="_preview"]').attr('href', '#' + new_id + '_preview').attr('data-preview-id', new_id);

  addHandlers()