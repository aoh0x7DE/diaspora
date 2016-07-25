# the presenter in charge of rendering polls for the API
class Api::V1::PollAnswerPresenter < BasePresenter
  attr_accessor :poll_answer

  def initialize(poll_answer, current_user=nil)
    @poll_answer = poll_answer
    @current_user = current_user
  end

  # returns information about the given poll answer
  def self.details(poll_answer)
    {
      id: poll_answer.id,
      answer: poll_answer.answer,
      vote_count: poll_answer.vote_count
    }
  end

  # instance methods; currently all are just wrappers for the class methods

  def details
    self.class.details(@poll_answer)
  end
end
