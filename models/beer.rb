class Beer

    def initialize(name, brewery, type=nil, abv=nil, ibu=nil, description=nil)
        @name = name
        @brewery = brewery
        @type = type
        @abv = abv
        @ibu = ibu
        @description = description
    end

    def name
        @name
    end

    def brewery
        @brewery
    end

    def type
        @type
    end

    def abv
        @abv
    end

    def ibu
        @ibu
    end

    def description
        @description
    end

end
