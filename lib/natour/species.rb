module Natour
  class Species
    attr_reader :name
    attr_reader :name_de

    def initialize(name, name_de)
      @name = name
      @name_de = name_de
    end

    include Comparable

    def <=>(other)
      [@name, @name_de] <=>
        [other.name, other.name_de]
    end

    def hash
      [@name, @name_de].hash
    end

    alias eql? ==
  end
end
