# the presenter in charge of rendering posts for the API
# TODO: better comments
class Api::V1::PostPresenter < BasePresenter
  include PostsHelper

  attr_accessor :post

  def initialize(post, current_user=nil)
    @post = post
    @current_user = current_user
  end

  # returns the title for the given post
  def self.title(post)
    post.message.present? ? post.message.title : I18n.t("posts.presenter.title", name: post.author_name)
  end

  # returns the body text of the given post
  def self.body(post)
    post.message.present? ? post.message.plain_text_for_json : post.text
  end

  # returns the basic identifying information for the given post
  def self.basic_details(post)
    {
      guid: post.guid,
      created_at: post.created_at,
      author: Api::V1::UserPresenter.basic_details(post.author)
    }
  end

  # returns all the information needed for the given post's api response
  def self.full_details(post, current_user)
    post_info = { # the hash to be returned, including the fields which will always be present
      guid: post.guid,
      created_at: post.created_at,
      post_type: post.post_type, # the post's type; can be status message or reshare
      title: title(post),
      body: body(post),
      provider_display_name: post.provider_display_name,
      public: post.public,
      nsfw: post.nsfw,
      author: Api::V1::UserPresenter.basic_details(post.author),
      interaction_counters: {
        comments: post.comments_count,
        likes: post.likes_count,
        reshares: post.reshares_count
      }
    }
    # include various optional fields if they are present
    if post.root.present? # if this is a reshare of another post, include information about that post
      post_info[:root] = Api::V1::PostPresenter.basic_details(post.root)
    end
    if post.mentioned_people.present?
      post_info[:mentioned_people] = post.mentioned_people.map{|user| Api::V1::UserPresenter.basic_details(user)}
    end
    if post.photos.present?
      post_info[:photos] = post.photos.map{|photo| Api::V1::PhotoPresenter.details_without_guid(photo)}
    end
    if post.poll.present?
      post_info[:poll] = Api::V1::PollPresenter.details(post.poll, current_user)
    end
    if post.location.present?
      post_info[:location] = post.post_location
    end
    post_info # return the hash
  end

  # instance methods; currently all are just wrappers for the class methods

  def title
    self.class.title(@post)
  end

  def body
    self.class.body(@post)
  end

  def basic_details
    self.class.basic_details(@post)
  end

  def full_details
    self.class.full_details(@post, @current_user)
  end
end
