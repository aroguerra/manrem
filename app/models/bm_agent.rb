class BmAgent < ApplicationRecord
  belongs_to :user
  has_many :bm_units
end
