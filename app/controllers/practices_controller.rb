# frozen_string_literal: true

class PracticesController < ApplicationController
  before_action :require_login
  before_action :require_admin_login, except: %i(show)
  before_action :set_course, only: %i(new)
  before_action :set_practice, only: %w(show edit update destroy sort)

  def show
    @category = @practice.category
  end

  def new
    @practice = Practice.new
  end

  def edit
  end

  def create
    @practice = Practice.new(practice_params)

    if @practice.save
      SlackNotification.notify "<#{url_for(current_user)}|#{current_user.login_name}>が<#{url_for(@practice)}|#{@practice.title}>を作成しました。",
        username: "#{current_user.login_name}@bootcamp.fjord.jp",
        icon_url: current_user.avatar_url
      save_ref_books(@practice)
      redirect_to @practice, notice: "プラクティスを作成しました。"
    else
      render :new
    end
  end

  def update
    old_practice = @practice.dup
    @practice.last_updated_user = current_user
    if @practice.update(practice_params)
      text = "<#{url_for(current_user)}|#{current_user.login_name}>が<#{url_for(@practice)}|#{@practice.title}>を編集しました。"
      diff = Diffy::Diff.new(old_practice.all_text + "\n", @practice.all_text + "\n", context: 1).to_s
      SlackNotification.notify "#{text}\n```#{diff}```",
        username: "#{current_user.login_name}@bootcamp.fjord.jp",
        icon_url: current_user.avatar_url
      save_ref_books(@practice)
      redirect_to @practice, notice: "プラクティスを更新しました。"
    else
      render :edit
    end
  end

  private
    def practice_params
      params.require(:practice).permit(
        :title,
        :description,
        :goal,
        :category_id,
        :position,
        :submission,
        :open_product,
        :include_progress,
        :memo,
        reference_books_attributes: [:id, :title, :asin, :_destroy]
      )
    end

    def set_practice
      @practice = Practice.find(params[:id])
    end

    def set_course
      @course = Course.find(params[:course_id]) if params[:course_id]
    end

    def book_search(asin)
      request = Vacuum.new(marketplace: "JP",
        access_key: "AKIAJM4IHXPFQ67OSZCA",
        secret_key: "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",
        partner_tag: "twitter0f1-22")

      response = request.get_items(
        item_ids: [asin],
        resources: ["Images.Primary.Small", "ItemInfo.Title", "ItemInfo.Features", "Offers.Summaries.HighestPrice", "ParentASIN"]
      )
    end

    def save_ref_books(practice)
      practice.reference_books.each do |book|
        res = book_search(book.asin)
        book.page_url = res.dig("ItemsResult", "Items")[0]["DetailPageURL"]
        book.image_url = res.dig("ItemsResult", "Items")[0]["Images"]["Primary"]["Small"]["URL"]
        book.save
      end
    end
end
