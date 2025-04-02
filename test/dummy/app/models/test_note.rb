class TestNote < ActiveRecord::Base
  validates :title, presence: true
end
