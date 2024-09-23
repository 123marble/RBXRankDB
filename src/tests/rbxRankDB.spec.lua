
local Util = require(script.Parent.util)

return function()
    local RankDBClient = require(script.Parent.Parent.rbxRankDB)
    beforeEach(function()
    end)

    afterEach(function()
        print("test completed...")
    end)
    
    it("should be passing test", function()
        expect(true).to.be.equal(true)
    end)


end