class BmUnit < ApplicationRecord
  belongs_to :bm_agent
  has_many :bm_unit_offers
end
