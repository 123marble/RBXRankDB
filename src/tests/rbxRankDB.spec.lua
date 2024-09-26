
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
        local result = client:updateElement(testListId, {id = 1, score = 10, tieBreaker = 0})
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
        local _ = client:updateElement(testListId, {id = 1, score = 10, tieBreaker = 0})
        local result = client:getElement(testListId, 1)
        local expected = {
            id = 1,
            rank = 1,
            tieBreaker = 0,
            score = 10,
        }
        expect(result).to.be.deepEqual(expected)
    end)

    it("should be able to add multiple elements to list", function()
        local result = client:updateElement(testListId, {id = 1, score = 10, tieBreaker = 0})
        local expected = {
            id = 1,
            prevRank = nil,
            newRank = 1,
            prevScore = nil,
            newScore = 10,
        }
        expect(result).to.be.deepEqual(expected)

        local result = client:updateElement(testListId, {id = 2, score = 2, tieBreaker = 0})
        local expected = {
            id = 2,
            prevRank = nil,
            newRank = 2,
            prevScore = nil,
            newScore = 2,
        }
        expect(result).to.be.deepEqual(expected)

        local result = client:updateElement(testListId, {id = 3, score = 20, tieBreaker = 0})
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
        local _ = client:updateElement(testListId, {id = 1, score = 10, tieBreaker = 0})
        local length = client:getListLength(testListId)
        expect(length).to.be.equal(1)
    end)

    it("length should be correct after adding multiple elements", function()
        local _ = client:updateElement(testListId, {id = 1, score = 1, tieBreaker = 0})
        local _ = client:updateElement(testListId, {id = 2, score = 1, tieBreaker = 0})
        local _ = client:updateElement(testListId, {id = 3, score = 1, tieBreaker = 0})
        local length = client:getListLength(testListId)
        expect(length).to.be.equal(3)
    end)

    it("should be able to update existing element", function()
        local result = client:updateElement(testListId, {id = 1, score = 10, tieBreaker = 0})
        local expected = {
            id = 1,
            prevRank = nil,
            newRank = 1,
            prevScore = nil,
            newScore = 10,
        }
        expect(result).to.be.deepEqual(expected)

        local result = client:updateElement(testListId, {id = 1, score = 1, tieBreaker = 0})
        local expected = {
            id = 1,
            prevRank = 1,
            newRank = 1,
            prevScore = 10,
            newScore = 1,
        }
        expect(result).to.be.deepEqual(expected)
    end)


    it("should be able to update multiple elements in one request", function()
        local elements = {
            {id = 1, score = 10, tieBreaker = 0},
            {id = 2, score = 20, tieBreaker = 0},
            {id = 3, score = 30, tieBreaker = 0},
        }
        local results = client:updateMultiElements(testListId, elements, false)

        local expectedResults = {
            found = {
                {
                    id = 3,
                    prevRank = nil,
                    newRank = 1,
                    prevScore = nil,
                    newScore = 30,
                },
                {
                    id = 2,
                    prevRank = nil,
                    newRank = 2,
                    prevScore = nil,
                    newScore = 20,
                },
                {
                    id = 1,
                    prevRank = nil,
                    newRank = 3,
                    prevScore = nil,
                    newScore = 10,
                },
            },
            notFound = {},
        }

        expect(results).to.be.deepEqual(expectedResults)
    end)

    it("should be able to get multiple elements in one request", function()
        local _ = client:updateElement(testListId, {id = 1, score = 1, tieBreaker = 0})
        local _ = client:updateElement(testListId, {id = 2, score = 2, tieBreaker = 0})
        local _ = client:updateElement(testListId, {id = 3, score = 3, tieBreaker = 0})

        local getResult = client:getMultiElements(testListId, {1,2,3,4})
        local expectedResult = {
            found = {
                {id = 3, rank = 1, score = 3, tieBreaker = 0},
                {id = 2, rank = 2, score = 2, tieBreaker = 0},
                {id = 1, rank = 3, score = 1, tieBreaker = 0},
            },
            notFound = {
                4
            }
        }
        expect(getResult).to.be.deepEqual(expectedResult)

    end)
    
end