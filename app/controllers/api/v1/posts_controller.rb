# the controller for requests to get, create, and destroy posts via the API
# TODO: make error cases match the spec once the spec covers them
# TODO: better provisional handling for malformed input on post creation
# TODO: better comments
# TODO: testing
# TODO: change :id to :guid (update all files)
class Api::V1::PostsController < Api::V0::BaseController
  # require token-based authentication for an account with read permission before showing a post
  before_action only: :show do
    require_access_token %w(read)
  end

  # require token-based authentication for an account with both read and write permissions before creating or deleting
  # a post
  before_action only: %i(create destroy) do
    require_access_token %w(read write)
  end

  # responds with the JSON for the post with the given GUID
  # does not affect the notifications status of the post
  def show
    post = current_user.find_visible_shareable_by_id(Post, params[:id], key: :guid) # gets the post
    if post.nil? # could not find a matching post viewable by the current user
      render nothing: true, status: 404 # respond with 404 (provisional; this case currently not covered by the spec)
    else
      render json: Api::V1::PostPresenter.full_details(post, current_user) # render the json
    end
  end

  # creates a new status message for the given parameters and responds with its JSON representation
  # not yet fully tested
  def create
    # translate between the API spec and the creation service
    backend_params = {
      public: params[:public],
      status_message: {
        text: params[:body]
      }
    }
    if params.has_key?(:aspects)
      backend_params[:aspect_ids] = params[:aspects]
    end
    if params.has_key?(:location)
      backend_params[:location_address] = params[:location][:address]
      backend_params[:location_coords] = params[:location][:lat] + ',' + params[:location][:lng]
    end
    # TODO: make poll input parameters match the spec once the spec specifies them
    # provisional input scheme is:
    # {
    #   "poll": {
    #     "question": "Yes or no?",
    #     "poll_answers": ["Yes", "No"]
    #   }
    # }
    if params.has_key?(:poll)
      backend_params[:poll_question] = params[:poll][:question]
      backend_params[:poll_answers] = params[:poll][:poll_answers]
    end
    if params.has_key?(:photos)
      backend_params[:photos] = params[:photos]
    end
    status_message = status_message_creation_service.create(backend_params)
    render json: Api::V1::PostPresenter.full_details(status_message, current_user)
  end

  # deletes the post with the given ID, returning a 204 no content
  def destroy
    post_service.destroy(params[:id]) # delete the given post
    render nothing: true, status: 204 # respond with 204
  rescue # an exception was raised while trying to delete the post
    render nothing: true, status: 403 # respond with 403 forbidden (provisional)
  end

  private

  # returns the post service for this user, creating it if necessary
  def post_service
    @post_service ||= PostService.new(current_user)
  end

  # returns the status message creation service for this user, creating it if necessary
  def status_message_creation_service
    @status_message_creation_service ||= StatusMessageCreationService.new(current_user)
  end
end
