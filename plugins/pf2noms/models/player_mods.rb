module AresMUSH
  class Player

    attribute :total_rpp, :type => DataType::Integer, :default => 0
    attribute :available_rpp, :type => DataType::Integer, :default => 0
    attribute :rpp_history, :type => DataType::Array, :default => []
    attribute :rpp_spent_by_char, :type => DataType::Hash, :default => {}


    ##### CLASS METHODS FOR RPP #####

    def self.award_rpp(char, award, reason)
      player = char.player

      # Is character registered?
      return t('alttracker.not_registered') unless player

      # Is the award a valid number?
      # This also thwarts the smartass who tries to award floats.
      award = award.to_i

      return t('pf2noms.not_a_number') if award.zero?

      total_rpp = player.total_rpp + award
      available_rpp = player.available_rpp + award

      # Store the time of the award as epoch time.
      time = Time.now.to_i

      award_history = player.rpp_history

      award_history.unshift [ time, char.name, award, reason ]

      player.rpp_history = award_history
      player.total_rpp = total_rpp
      player.available_rpp = available_rpp

      player.save 
      
      return nil
    end

    def self.spend_rpp(char, spend, reason)
      player = char.player

      # Is character registered?
      return t('alttracker.not_registered') unless player

      # Is the spend a valid number?
      spend = spend.to_i

      return t('pf2noms.not_a_number') if spend.zero?

      # Do they have enough RPP? 

      available_rpp = player.available_rpp - spend

      return t('pf2noms.not_enough_rpp') if available_rpp < 0

      # Store the time of the spend as epoch time.

      time = Time.now.to_i

      spend_history = player.rpp_history

      spend_history.unshift [ time, char.name, -spend, reason ]

      player.rpp_history = spend_history
      player.available_rpp = available_rpp

      # Track how much RPP has been spent on the character.

      char_spend_tracker = player.rpp_spent_by_char[char.name]

      char_spend_tracker = 0 unless char_spend_tracker # Set to 0 if nil

      char_total_spent = char_spend_tracker + spend

      player.rpp_spent_by_char[char.name] = char_total_spent

      player.save

      return nil
    end

    
  end
end