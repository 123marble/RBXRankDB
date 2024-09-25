
local Util = require(script.Parent.util)

return function()
    local RankDBClient = require(script.Parent.Parent.rbxRankDB)
    local secrets = require(script.Parent.Parent.secrets)

    local client
    local testListId = "test"
    beforeEach(function()
        expect.extend(Util.GetExpectationExtensions())
        client = RankDBClient.new(secrets.url, secrets.token)
        local _ = client:deleteList(testListId)
        client:createList(testListId)
    end)

    it("should be able to create a list", function()
        local _ = client:deleteList("createdList")
        local result = client:createList("createdList")
        expect(result).to.be.equal(true)
    end)

    it("should get 0 length for empty list", function()
        local length = client:getListLength(testListId)
        expect(length).to.be.equal(0)
    end)
    
    it("should be able to add one element to list", function()
        local result = client:updateElement(testListId, 1, 10, 0, nil)
        local expected = {
            id = 1,
            prevRank = nil,
            newRank = 1,
            prevScore = nil,
            newScore = 10,
        }
        expect(result).to.be.deepEqual(expected)
    end)

    it("should be able to get element from list", function()
        local _ = client:updateElement(testListId, 1, 10, 0, nil)
        local result = client:getElement(testListId, 1, 0)
        local expected = {
            id = 1,
            rank = 1,
            tieBreaker = 0,
            score = 10,
        }
        expect(result).to.be.deepEqual(expected)
    end)

    it("should be able to add multiple elements to list", function()
        local result = client:updateElement(testListId, 1, 10, 0, nil)
        local expected = {
            id = 1,
            prevRank = nil,
            newRank = 1,
            prevScore = nil,
            newScore = 10,
        }
        expect(result).to.be.deepEqual(expected)
        local result = client:updateElement(testListId, 2, 2, 0, nil)
        local expected = {
            id = 2,
            prevRank = nil,
            newRank = 2,
            prevScore = nil,
            newScore = 2,
        }
        expect(result).to.be.deepEqual(expected)

        local result = client:updateElement(testListId, 3, 20, 0, nil)
        result.shiftedBoundaries = nil
        local expected = {
            id = 3,
            prevRank = nil,
            newRank = 1,
            prevScore = nil,
            newScore = 20,
        }
        expect(result).to.be.deepEqual(expected)
    end)

    it("length should be correct after adding 1 element", function()
        local _ = client:updateElement(testListId, 1, 10, 0, nil)
        local length = client:getListLength(testListId)
        expect(length).to.be.equal(1)
    end)

    it("length should be correct after adding multiple elements", function()
        local _ = client:updateElement(testListId, 1, 1, 0, nil)
        local _ = client:updateElement(testListId, 2, 1, 0, nil)
        local _ = client:updateElement(testListId, 3, 1, 0, nil)
        local length = client:getListLength(testListId)
        expect(length).to.be.equal(3)
    end)

    it("should be able to update existing element", function()
        local result = client:updateElement(testListId, 1, 10, 0, nil)
        local expected = {
            id = 1,
            prevRank = nil,
            newRank = 1,
            prevScore = nil,
            newScore = 10,
        }
        expect(result).to.be.deepEqual(expected)

        local result = client:updateElement(testListId, 1, 1, 0, nil)
        local expected = {
            id = 1,
            prevRank = 1,
            newRank = 1,
            prevScore = 10,
            newScore = 1,
        }
        expect(result).to.be.deepEqual(expected)
    end)   
    
end