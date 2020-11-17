module AresMUSH
  module Pf2e

    PROF_LEVEL = {
        untrained=>0,
        trained=>2,
        expert=>4,
        master=>6,
        legendary=>8
      }

    def get_prof_bonus(p=untrained)
      levels = AresMUSH::Pf2e::PROF_LEVEL
      bonus = levels[p]
      return #{bonus}
    end
  end
end
