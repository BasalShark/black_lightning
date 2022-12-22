// Converted from CoffeeSript using decaffeinate
$(document).ready(function() {
  jQuery(() => addHandlers());
});

// https://getbootstrap.com/docs/4.6/components/navs/#events see here for how tabs and javascrip work.
const addHandlers = () => $(document).find(".preview-toggle").on("show.bs.tab", function(e) {
  let id = undefined;
  let input = undefined;
  id = $(e.currentTarget).data("preview-id");
  input = $("#" + id + "_input_field textarea");

  $("#" + id + "_preview_placeholder").html('<b>Please Wait. Loading Preview...</b>');

  var token = $('meta[name="csrf-token"]').attr('content');

  return $.ajax({
    type: 'POST',
    url: '/markdown/preview.json',
    data: JSON.stringify({ input_html: encodeURIComponent(input.val()) }),
    beforeSend: function (xhr) {
      xhr.setRequestHeader('X-CSRF-Token', token)
    },
    success(data) {
      const preview = $("#" + id + "_preview_placeholder");
      preview.html(data.rendered_md);
    },
    error(jqXHR, textStatus, errorThrown) {
      const error_data = JSON.parse(jqXHR.responseText);
      const error_html =  `\
<b>There was an error rendering your kramdown.</b>
<pre>${error_data.error}</pre>\
`;
      return $("#" + id + "_preview_placeholder").html(error_html);
    },
    contentType: false,
    processData: false
  });
});

$(document).on("cocoon:after-insert", function(e, insertedItem, originalEvent) {
  const new_id = new Date().getTime();
  console.log('hello?')
  /*
    Slightly hacky way of making all the ids unique and updating the necessary anchors
    BOOTSTRAP NICETOHAVE: This is not called. Fix it and check if md_editor still work properly on dynamic fields (creatives)
  */
  jQuery(insertedItem).find('[id$="_input_field"]').attr('id', new_id + '_input_field');
  jQuery(insertedItem).find('[href$="_input_field"]').attr('href', '#' + new_id + '_input_field');

  jQuery(insertedItem).find('[id$="_preview"]').attr('id', new_id + '_preview');
  jQuery(insertedItem).find('[href$="_preview"]').attr('href', '#' + new_id + '_preview').attr('data-preview-id', new_id);

  jQuery(insertedItem).find('[id$="_preview_placeholder"]').attr('id', new_id + '_preview_placeholder');
  jQuery(insertedItem).find('[href$="_preview_placeholder"]').attr('href', '#' + new_id + '_preview_placeholder');

  return addHandlers();
});
