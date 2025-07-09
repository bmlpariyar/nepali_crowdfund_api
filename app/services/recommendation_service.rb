class RecommendationService
  NEARBY_RADIUS = 5
  LIMIT_PER_TYPE = 20
  TOTAL_LIMIT = 8

  def initialize(user)
    @user = user
    @profile = user.user_profile
    @excluded_campaign_ids = excluded_campaign_ids
  end

  def generate_recommendations
    recommendations = []

    recommendations += location_based_recommendations
    recommendations += behavior_based_recommendations
    recommendations += funding_goal_based_recommendations
    recommendations += trending_recommendations

    final_recommendations = recommendations.uniq
    apply_business_rules(final_recommendations)

    scored_recommendations = score_recommendations(final_recommendations)
    scored_recommendations.first(TOTAL_LIMIT)
  end

  private

  def location_based_recommendations
    return [] unless location_available?

    Campaign.active
            .near([@profile.latitude, @profile.longitude], NEARBY_RADIUS)
            .where.not(id: @excluded_campaign_ids)
            .limit(LIMIT_PER_TYPE)
  end

  def behavior_based_recommendations
    category_ids = user_preferred_categories
    return [] if category_ids.empty?

    Campaign.active
            .where(category_id: category_ids)
            .where.not(id: @excluded_campaign_ids)
            .limit(LIMIT_PER_TYPE)
  end

  def funding_goal_based_recommendations
    preferred_ranges = user_preferred_funding_ranges
    return [] if preferred_ranges.empty?

    campaigns = []
    preferred_ranges.each do |range|
      range_campaigns = Campaign.active
        .where(funding_goal: range)
        .where.not(id: @excluded_campaign_ids)
        .limit(LIMIT_PER_TYPE / preferred_ranges.count)
      campaigns += range_campaigns
    end
    campaigns
  end

  def trending_recommendations
    Campaign.active
            .joins(:donations)
            .where(donations: { created_at: 1.week.ago.. })
            .group("campaigns.id")
            .having("COUNT(donations.id) >= ?", 5)
            .where.not(id: @excluded_campaign_ids)
            .limit(LIMIT_PER_TYPE)
  end

  def user_preferred_categories
    @user.campaign_views
         .joins(campaign: :category)
         .group("categories.id")
         .order("count(campaign_views.id) DESC")
         .limit(5)
         .pluck("categories.id")
  end

  def user_preferred_funding_ranges
    donation_amounts = @user.donations.pluck(:amount)
    return default_funding_ranges if donation_amounts.empty?

    avg_donation = donation_amounts.sum / donation_amounts.count

    ranges = []

    if avg_donation <= 50
      ranges << (0..1000)
      ranges << (1000..5000)
    elsif avg_donation <= 200
      ranges << (1000..10000)
      ranges << (10000..50000)
    else
      ranges << (10000..100000)
      ranges << (100000..Float::INFINITY)
    end

    ranges
  end

  def default_funding_ranges
    [
      (0..5000),
      (5000..25000),
      (25000..100000),
    ]
  end

  def score_recommendations(campaigns)
    campaigns.map do |campaign|
      score = calculate_campaign_score(campaign)
      { campaign: campaign, score: score }
    end.sort_by { |item| -item[:score] }.map { |item| item[:campaign] }
  end

  def calculate_campaign_score(campaign)
    score = 0

    if location_available? && campaign.latitude && campaign.longitude
      distance = Geocoder::Calculations.distance_between(
        [@profile.latitude, @profile.longitude],
        [campaign.latitude, campaign.longitude]
      )
      score += [50 - distance, 0].max
    end

    # Category preference score
    if user_preferred_categories.include?(campaign.category_id)
      category_rank = user_preferred_categories.index(campaign.category_id) + 1
      score += (10 - category_rank) * 5
    end

    # Funding goal alignment score
    user_preferred_funding_ranges.each_with_index do |range, index|
      if range.include?(campaign.funding_goal)
        score += (3 - index) * 10
        break
      end
    end

    # Recency score
    days_old = (Date.current - campaign.created_at.to_date).to_i
    score += [30 - days_old, 0].max

    progress_percentage = (campaign.current_amount / campaign.funding_goal.to_f) * 100
    if progress_percentage.between?(10, 80)
      score += 20
    elsif progress_percentage.between?(1, 10)
      score += 10
    end

    score
  end

  def apply_business_rules(campaigns)
    donated_campaign_ids = @user.donations.pluck(:campaign_id).uniq
    campaigns.reject! { |campaign| donated_campaign_ids.include?(campaign.id) }

    campaigns.reject! { |campaign| campaign.user_id == @user.id }

    campaigns.reject! { |campaign| campaign.current_amount >= campaign.funding_goal }
  end

  def excluded_campaign_ids
    ids = []
    ids += @user.donations.pluck(:campaign_id)
    ids += @user.campaigns.pluck(:id)
    ids.uniq
  end

  def location_available?
    @profile&.latitude.present? && @profile&.longitude.present?
  end
end
