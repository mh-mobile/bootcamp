# frozen_string_literal: true

class API::QuestionsController < API::BaseController
  include Rails.application.routes.url_helpers
  before_action :require_login
  before_action :set_question, only: %i(show update destroy)
  before_action :set_available_emojis, only: %i(index show)

  def index
    @questions = Question.all
  end

  def show
  end

  def update
    if @question.update(question_params)
      head :ok
    else
      head :bad_request
    end
  end

  def destroy
    @question.destroy!
  end

  private
    def set_question
      @question = Question.find(params[:id])
    end

    def question_params
      params.require(:question).permit(:title, :description, :practice_id)
    end
end
