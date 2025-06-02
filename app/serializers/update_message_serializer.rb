class UpdateMessageSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :id, :title, :message, :media_urls, :created_at, :updated_at

  def media_urls
    object.media_image.attached? ? url_for(object.media_image) : nil
  end
end
