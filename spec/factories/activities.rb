FactoryGirl.define do
  factory :activity do
    title { Faker::Book.title }
    start_time { Faker::Time.between(1.day.ago, Time.zone.today) }
    end_time { Faker::Time.between(Time.zone.today, 1.day.from_now) }
  end
end
