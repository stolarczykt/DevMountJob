module Offering
  class Expectation
    def initialize(name, accepted)
      raise ArgumentError if name.nil?
      raise ArgumentError if accepted.nil?
      @name = name
      @accepted = accepted
    end

    def not_satisfied?
      !@accepted
    end
  end
end
