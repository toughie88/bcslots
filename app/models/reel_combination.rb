class ReelCombination < ActiveRecord::Base
  belongs_to :first,  :class_name =>  'Reel', :foreign_key => 'first_id'
  belongs_to :second, :class_name =>  'Reel', :foreign_key => 'second_id'
  belongs_to :third,  :class_name =>  'Reel', :foreign_key => 'third_id'
  belongs_to :conditional_reel_combination

  after_commit do
    ReelCombination.clear_cache
  end

  def self.weighted_reel_combinations_cache_key
    'weighted_reel_combinations'
  end

  def self.clear_cache
    Rails.cache.delete ReelCombination.reel_combinations_cache_key
    Rails.cache.delete ReelCombination.weighted_reel_combinations_cache_key
  end
  def self.reel_combinations_cache_key
    'reel_combinations'
  end

  def self.weighted_reel_combinations
    Rails.cache.fetch(weighted_reel_combinations_cache_key) do
      reel_combinations
      .collect{|x| [x] * x[:weight]}
      .flatten
    end
  end
  def self.reel_combinations
    Rails.cache.fetch(reel_combinations_cache_key) do
      ReelCombination
      .includes(:conditional_reel_combination)
      .collect do |rc|
        {:weight => rc.conditional_reel_combination.weight,
         :payout => rc.conditional_reel_combination.payout,
         :reels => [rc.first.reel, rc.second.reel, rc.third.reel],
         :id => rc.id
        }
      end
    end
  end
end
