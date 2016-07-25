# the controller for requests to get, create, and destroy posts via the API
class Api::V1::PostsController < ApplicationController
  include PostsHelper
  include Api::OpenidConnect::ProtectedResourceEndpoint

  # require token-based authentication for an account with read permission before showing a post
  before_action only: :show do
    require_access_token %w(read)
  end

  # require token-based authentication for an account with both read and write permissions before creating or deleting
  # a post
  before_action only: %i(create destroy) do
    require_access_token %w(read write)
  end

  # returns the JSON for the post with the given ID (may be ID or GUID)
  # does not affect the notifications status of the post
  def show
    post = post_service.find!(params[:id]) # gets the post
    post_json = Api::V1::PostPresenter.full_details(post, current_user)
    render json: post_json # render the json
  end

  def create
    #@status_message = StatusMessageCreationService.new(params, current_user).status_message
    #render json: PostPresenter.new(@status_message, current_user)
  end

  # deletes the post with the given ID, returning a 204 no content
  def destroy
    post_service.destroy(params[:id]) # delete the given post
    render nothing: true, status: 204 # respond with 204
  end

  private

  # returns the post service for this user, creating it if necessary
  def post_service
    @post_service ||= PostService.new(current_user)
  end
end
