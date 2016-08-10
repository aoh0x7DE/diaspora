# the presenter in charge of rendering polls for the API
# TODO: better comments
class Api::V1::PollPresenter < BasePresenter
  attr_accessor :poll

  def initialize(poll, current_user=nil)
    @poll = poll
    @current_user = current_user
  end

  # returns the information for the given poll
  def self.details(poll, current_user)
    {
      guid: poll.guid,
      participation_count: poll.participation_count, # number of votes already cast
      already_participated: poll.already_participated?(current_user), # whether the current user participated
      question: poll.question, # text of the poll's question
      poll_answers: poll.poll_answers.map{|poll_answer| Api::V1::PollAnswerPresenter.details(poll_answer)}
    }
  end

  # instance methods; currently all are just wrappers for the class methods

  def details
    self.class.details(@poll, @current_user)
  end
end
