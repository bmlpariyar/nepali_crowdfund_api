class CampaignSearchSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :id, :title, :description, :status, :category, :goal, :raised,
             :backers, :days_left, :created_at, :cover_image, :progress_percentage

  def description
    object.story
  end

  def category
    object.category&.name
  end

  def goal
    object.funding_goal
  end

  def raised
    object.current_amount || 0
  end

  def backers
    object.donations.count
  end

  def days_left
    return 0 if object.deadline <= Time.current
    ((object.deadline - Time.current) / 1.day).ceil
  end

  def status
    if object.current_amount >= object.funding_goal
      "Funded"
    elsif object.deadline <= Time.current
      "Ended"
    else
      "Active"
    end
  end

  def cover_image
    object.cover_image.attached? ? url_for(object.cover_image) : nil
  end

  def progress_percentage
    return 0 if object.funding_goal.zero?
    [(raised.to_f / goal.to_f * 100).round(2), 100].min
  end
end
