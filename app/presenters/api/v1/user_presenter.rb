# the presenter in charge of rendering users for the API
# TODO: additional methods for the Users API
class Api::V1::UserPresenter < BasePresenter
  attr_accessor :user

  def initialize(user, current_user=nil)
    @user = user
    @current_user = current_user
  end

  # returns the basic identifying information for the given user
  def self.basic_details(user)
    {
      guid: user.guid,
      diaspora_id: user.diaspora_handle, # diaspora handle (e.g., user@diasporapod.example.com)
      name: user.name, # display name (e.g., John Doe)
      avatar: user.profile.image_url(:thumb_medium) # URL for the medium-sized version of the user's avatar
    }
  end

  # instance methods; currently all are just wrappers for the class methods

  def basic_details
    self.class.basic_details(@user)
  end
end
