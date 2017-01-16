module Refinery
  module ImageHelper

    # replace all system images with a thumbnail version of them (handy for all images inside a page part)
    # for example, <%= content_fu(@page.content_for(:body), '96x96#c') %> converts all /system/images to a 96x96 cropped thumbnail
    def content_fu(content, thumbnail)
      content.gsub(%r{<img.+?src=['"](/system/images/.+?)/.+?/>}) do |img|
        begin
          sha = img.match(%r{/system/images/(.+?)/})[1]
          job = Dragonfly::Job.deserialize sha, Dragonfly[:refinery_images]

          image_fu Image.where(:image_uid => job.uid).first, thumbnail
        rescue Dragonfly::Serializer::BadString
          img
        end
      end
    end

    # image_fu is a helper for inserting an image that has been uploaded into a template.
    # Say for example that we had a @model.image (@model having a belongs_to :image relationship)
    # and we wanted to display a thumbnail cropped to 200x200 then we can use image_fu like this:
    # <%= image_fu @model.image, '200x200' %> or with no thumbnail: <%= image_fu @model.image %>
    def image_fu(image, geometry = nil, options={})
      if image.present?
        dimensions = (image.thumbnail_dimensions(geometry) rescue {})

        coverted_image = image.thumbnail(geometry).encode("#{image.image_mime_type.split('/').last}", '-quality 55')

        image_tag(coverted_image.url, {
          :alt => image.alt_tag,
        }.merge(dimensions).merge(options))
      end
    end
  end
end
