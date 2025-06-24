class Api::V1::Dashboard::DashboardApiController < ApplicationController
  before_action :authorized
  before_action :require_admin

  def user_count_details
    total_users = User.count
    active_users = User.where(is_active: true).count
    creators = Campaign.where.not(user_id: nil).distinct.count(:user_id)
    admins = User.where(is_admin: true).count

    render json: {
      total_users: total_users,
      active_users: active_users,
      creators: creators,
      admins: admins,
    }, status: :ok
  end

  def get_weekly_campaign_activities
    start_of_week = Time.zone.now.beginning_of_week
    end_of_week = Time.zone.now.end_of_week

    days = %w[Mon Tue Wed Thu Fri Sat Sun]
    data = []

    (start_of_week.to_date..end_of_week.to_date).each_with_index do |date, i|
      campaigns_count = Campaign.where(created_at: date.beginning_of_day..date.end_of_day).count

      daily_donations = Donation.where(created_at: date.beginning_of_day..date.end_of_day)
      donation_sum = daily_donations.sum(:amount)
      unique_donors = daily_donations.select(:user_id).distinct.count

      data << {
        day: days[i],
        campaigns: campaigns_count || 0,
        donation: donation_sum || 0,
        doners: unique_donors || 0,
      }
    end

    render json: data, status: :ok
  end

  def get_category_campaign_details
    categories = Category.includes(:campaigns).all
    total_campaigns = categories.sum { |category| category.campaigns.count }

    category_details = categories.map do |category|
      count = category.campaigns.count
      percent = total_campaigns > 0 ? ((count.to_f / total_campaigns) * 100).round : 0
      {
        name: category.name,
        campaigns_count: percent,
        color: "##{SecureRandom.hex(3)}",
      }
    end

    render json: category_details, status: :ok
  end
end
