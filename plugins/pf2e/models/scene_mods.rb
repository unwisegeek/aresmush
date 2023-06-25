module AresMUSH
  class Scene < Ohm::Model

    collection :encounters, "AresMUSH::PF2Encounter"

  end
end