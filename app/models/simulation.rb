class Simulation < ApplicationRecord
  belongs_to :user
  has_many :results
  has_many :bm_secondary_results
end
