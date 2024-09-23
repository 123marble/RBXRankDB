
local Util = require(script.Parent.util)

return function()
    local RankDBClient = require(script.Parent.Parent.rbxRankDB)
    local secrets = require(script.Parent.Parent.secrets)

    local client
    beforeEach(function()
        client = RankDBClient.new(secrets.url, secrets.token, true)
    end)

    afterEach(function()
        print("test completed...")
    end)
    
    it("should be passing test", function()
        expect(true).to.be.equal(true)
    end)


end