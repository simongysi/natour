module Natour
  class Station
    attr_reader :label
    attr_reader :type
    attr_reader :distance

    def initialize(label, type, distance)
      @label = label
      @type = type
      @distance = distance
    end

    include Comparable

    def <=>(other)
      [@label, @type, @distance] <=>
        [other.label, other.type, other.distance]
    end

    def hash
      [@label, @type, @distance].hash
    end

    alias eql? ==
  end
end
