require "faker"

ActiveRecord::Base.transaction do
  puts "Clearing old records..."
  Campaign.destroy_all
  Category.destroy_all

  puts "Seeding categories..."
  CATEGORY_DATA = [
    ["Medical", "medical"],
    ["Community Projects", "community-projects"],
    ["Arts & Culture", "arts-culture"],
    ["Technology", "technology"],
    ["Environment", "environment"],
    ["Healthcare", "healthcare"],
    ["Education", "education"],
    ["Animal Welfare", "animal-welfare"],
    ["Human Rights", "human-rights"],
    ["Social Justice", "social-justice"],
    ["Climate Action", "climate-action"],
  ]

  categories = CATEGORY_DATA.map do |name, slug|
    Category.create!(name: name, slug: slug)
  end

  category_ids = categories.map(&:id)

  def random_point_in_circle(latitude, longitude, radius_km)
    radius_earth = 6371.0
    u, v = rand, rand

    w = radius_km * Math.sqrt(u)
    t = 2 * Math::PI * v
    x = w * Math.cos(t)
    y = w * Math.sin(t)

    delta_lat = y / radius_earth * (180 / Math::PI)
    delta_lng = x / (radius_earth * Math.cos(latitude * Math::PI / 180)) * (180 / Math::PI)

    [latitude + delta_lat, longitude + delta_lng]
  end

  puts "Seeding campaigns..."
  50.times do |i|
    lat, lng = random_point_in_circle(27.6344, 85.5167, 30)

    Campaign.create!(
      user_id: 1,
      category_id: category_ids.sample,
      title: Faker::Lorem.sentence(word_count: 10).chomp("."),
      story: Faker::Lorem.paragraph_by_chars(number: 800),
      funding_goal: rand(1..50) * 100_000,
      current_amount: 0,
      deadline: Faker::Date.between(from: Date.new(2026, 1, 1), to: Date.new(2030, 12, 31)),
      status: "active",
      slug: "campaign-#{i + 1}-#{Faker::Internet.slug}",
      image_url: nil,
      video_url: nil,
      created_at: Time.current,
      updated_at: Time.current,
      address: Faker::Address.full_address,
      latitude: lat,
      longitude: lng,
    )
    puts "Campaign #{i + 1} seeded successfully!"
  end

  puts "Campaigns seeded successfully!"
end
