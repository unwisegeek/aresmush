module AresMUSH
  module Pf2emagic
    class PF2CastCmd
      include CommandHandler

      attr_accessor :charclass, :level, :spell, :target

    end
  end
end
