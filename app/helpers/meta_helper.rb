##
# =Metadata
# The following metadata is set as default on each page:
#
#  <meta name='title' content='Bedlam Theatre'>
#  <meta name='description' content='The Bedlam Theatre is a unique, entirely student run theatre in the heart of Edinburgh.'>
#
# This data can be changed either in the controller or in the view by changing the <tt>@meta</tt> hash.
# (Setting it in the controller with <tt>@title</tt> is preferred).
# Note that <tt>@meta[:title]</tt> will be set to <tt>@title</tt> unless otherwise specified.
#
# For an example, see the shows controller.
#
# ==Facebook metadata
#
# Facebook metadata is included by default in each page so that links will contain the following information:
#
#  <meta name='og:url' content='http://bedlam.local:3000/'>
#  <meta name='og:image' content='http://bedlam.local:3000/assets/BedlamLogoBW.png'>
#  <meta name='og:title' content='Bedlam Theatre'>
#  <meta name='og:description' content='The Bedlam Theatre is a unique, entirely student run theatre in the heart of Edinburgh.'>
#
# Again, this can be changed using the <tt>@meta</tt> hash. <tt>og:title</tt> and <tt>og:description</tt> will be read
# from <tt>@meta[:title]</tt> and <tt>@meta[:description]</tt> if no other values are specified.
#
# More information about facebook opengraph meta tags can be found at
# https://developers.facebook.com/docs/technical-guides/opengraph/built-in-objects/#website.
#
# For an example, see the shows controller.
##

module MetaHelper
  ##
  # Creates the meta data tags.
  ##
  def meta_tags
    @meta[:title] ||= @title ? "#{@title} - Bedlam Theatre" : "Bedlam Theatre"
    @meta[:description] ||= "The Bedlam Theatre is a unique, entirely student run theatre in the heart of Edinburgh."

    # facebook opengraph data:
    @meta["og:url"]         ||= @base_url + request.fullpath
    @meta["og:image"]       ||= @base_url + image_path('BedlamLogoBW.png')
    @meta["og:title"]       ||= @meta[:title]
    @meta["og:description"] ||= @meta[:description]

    @tags = []

    @meta.each do |name, content|
      type = "name"
      type = "property" if name.to_s.starts_with?('og') or name.to_s.starts_with?('fb')

      if content.kind_of?(Array) then
        content.each do |item|
          @tags << "<meta #{type}='#{name}' content='#{ERB::Util.html_escape item}'>"
        end
      else
        @tags << "<meta #{type}='#{name}' content='#{ERB::Util.html_escape content}'>"
      end
    end

    return @tags.join "\n"
  end
end