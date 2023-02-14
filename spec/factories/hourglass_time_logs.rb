FactoryBot.define do
  factory :time_log, class: 'Hourglass::TimeLog' do
    user
    start { faker_between Date.today, Date.today, :morning }
    stop { faker_between Date.today, Date.today, :afternoon }
    factory :time_log_with_comments do
      comments { Faker::Hacker.say_something_smart }
    end
  end
  factory :time_log2, class: 'Hourglass::TimeLog' do
    user
    start { faker_between Date.yesterday, Date.yesterday, :morning }
    stop { faker_between Date.yesterday, Date.yesterday, :afternoon }
    factory :time_log_with_comments2 do
      comments { Faker::Hacker.say_something_smart }
    end
  end
  factory :time_log3, class: 'Hourglass::TimeLog' do
    user
    start { faker_between Date.yesterday.prev_day, Date.yesterday.prev_day, :morning }
    stop { faker_between Date.yesterday.prev_day, Date.yesterday.prev_day, :afternoon }
    factory :time_log_with_comments3 do
      comments { Faker::Hacker.say_something_smart }
    end
  end
end
