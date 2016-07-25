# the presenter in charge of rendering photos for the API
class Api::V1::PhotoPresenter < BasePresenter
  attr_accessor :photo

  def initialize(photo, current_user=nil)
    @photo = photo
    @current_user = current_user
  end

  # returns the dimensions of the given photo
  def self.dimensions(photo)
    {
      height: photo.height,
      width: photo.width
    }
  end

  # returns the URLs for the different sizes of the given photo
  def self.sizes(photo)
    {
      large: photo.url(:scaled_full),
      medium: photo.url(:thumb_medium),
      small: photo.url(:thumb_small)
    }
  end

  # returns information about the given photo
  def self.details(photo)
    {
      guid: photo.guid,
      dimensions: dimensions(photo),
      sizes: sizes(photo)
    }
  end

  # a variant of the details method which leaves out the guid for the posts API
  def self.details_without_guid(photo)
    details(photo).except(:guid)
  end

  # instance methods; currently all are just wrappers for the class methods

  def dimensions
    self.class.dimensions(@photo)
  end

  def sizes
    self.class.sizes(@photo)
  end

  def details
    self.class.details(@photo)
  end

  def details_without_guid
    self.class.detials_without_guid(@photo)
  end
end
