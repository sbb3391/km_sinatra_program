require 'carrierwave/orm/activerecord'

class ImageUploader < CarrierWave::Uploader::Base

  storage :file
end

class LineItem < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :product
  has_many :service_terms

  mount_uploader :image, ImageUploader
end
