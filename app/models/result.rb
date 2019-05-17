class Result < ApplicationRecord
  belongs_to :simulation
  belongs_to :agent
end
