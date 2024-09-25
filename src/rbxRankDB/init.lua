local HttpService = game:GetService("HttpService")

local RankDBClient = {}
RankDBClient.__index = RankDBClient

--- @class RankDBClient

--- @type getElementResult {id: number, score: number, tieBreaker: number, rank: number, extra: {}}
--- @within RankDBClient
export type getElementResult = {
    id : number,
    score : number,
    tieBreaker : number,
    rank : number,
    extra : {}
}

--- @type updateElementResult {id: number, prevRank: number, newRank: number, prevScore: number, newScore: number, shiftedBoundaries: {shiftedBoundary}}
--- @within RankDBClient
export type updateElementResult = {
    id : number,
    prevRank : number,
    newRank : number,
    prevScore : number,
    newScore : number,
    shiftedBoundaries : {shiftedBoundary}
}

--- @type shiftedBoundary {id: number, prevRank: number, newRank: number}
--- @within RankDBClient
export type shiftedBoundary = {
    id : number,
    prevRank : number,
    newRank : number
}

--[=[
Creates a new RankDBClient instance.
@param baseUrl string -- The base URL of the RankDB API
@param jwtToken string? -- Optional JWT token for authentication
@return RankDBClient -- A new RankDBClient instance
]=]
function RankDBClient.new(baseUrl : string, jwtToken : string?)
    local self = setmetatable({}, RankDBClient)
    self.baseUrl = baseUrl
    self.jwtToken = jwtToken
    self.ascending = false -- todo: hardcoded for now because shiftedBoundaries does not work with descending. This should be parameterised in future.
    return self
end

--[=[
Sends a request to the RankDB API.
@param method string -- The HTTP method to use
@param endpoint string -- The API endpoint
@param body table? -- Optional request body
@return table -- The response from the API
]=]
function RankDBClient:request(method, endpoint, body)
    local url = self.baseUrl .. endpoint
    local headers = {
        ["Content-Type"] = "application/json"
    }
    if self.jwtToken then
        headers["Authorization"] = "Bearer " .. self.jwtToken
    end
    
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = url,
            Method = method,
            Headers = headers,
            Body = body and HttpService:JSONEncode(body) or nil
        })
    end)
    
    if not success then
        error("Request failed: " .. response)
    end
    
    if response.Success then
        if response.Body == "" then
            return nil
        end
        return HttpService:JSONDecode(response.Body)
    else
        error("HTTP Error: " .. response.StatusCode .. " " .. response.Body)
    end
end

--[=[
Creates a new list in the RankDB.
@param listId string -- The ID of the list to create
@param set string? -- The set to use (default: "default")
@param mergeSize number? -- The merge size (default: 500)
@param splitSize number? -- The split size (default: 2000)
@param replace boolean? -- Whether to replace an existing list (default: false)
@return boolean -- True if the list was created, false if it already exists
]=]
function RankDBClient:createList(
    listId : string,
    set : string?,
    mergeSize : number?,
    splitSize : number?,
    replace : boolean?
) : boolean
    set = set or "default"
    mergeSize = mergeSize or 500
    splitSize = splitSize or 2000
    replace = replace or false
    local listData = {
        id = listId,
        set = set,
        merge_size = mergeSize,
        split_size = splitSize,
        load_index = false
    }
    local query = replace and "?replace=true" or "?replace=false"
    local success, result = pcall(function()
        return self:request("POST", "/lists" .. query, listData)
    end)
    
    if success then
        return true
    else
        if type(result) == "string" and result:match("HTTP Error: 409") then
            return false
        else
            error(tostring(result))
        end
    end
end

--[=[
Gets the length of a list.
@param listId string -- The ID of the list
@return number -- The number of elements in the list
]=]
function RankDBClient:getListLength(listId : string) : number
    local result = self:request("GET", "/lists/" .. listId)
    return tonumber(result.elements)
end

--[=[
Deletes a list from the RankDB.
@param listId string -- The ID of the list to delete
@return boolean -- True if the list was deleted, false if it was not found
]=]
function RankDBClient:deleteList(listId : string)
    return self:request("DELETE", "/lists/" .. listId) and true or false
end

--[=[
Gets an element from a list.
@param listId string -- The ID of the list
@param elementId number -- The ID of the element
@return getElementResult -- The element data
]=]
function RankDBClient:getElement(listId : string, elementId : number) : getElementResult
    local range = 0 -- todo: make this a parameter
    local query = "?range=" .. tostring(range)
    local result = self:request("GET", "/lists/" .. listId .. "/elements/" .. tostring(elementId) .. query)
    return {
        id = result.id,
        score = tonumber(result.score),
        tieBreaker = tonumber(result.tie_breaker),
        extra = result.payload,
        rank = (self.ascending and result.from_bottom or result.from_top) + 1
    }
end

--[=[
Updates an element in a list.
@param listId string -- The ID of the list
@param elementId number -- The ID of the element to update
@param score number -- The new score for the element
@param tieBreaker number? -- Optional tiebreaker value
@param extra table -- Additional data to store with the element
@return updateElementResult -- The result of the update operation
]=]
function RankDBClient:updateElement(
    listId : string,
    elementId : number,
    score : number,
    tieBreaker : number?,
    extra : {}
) : updateElementResult
    tieBreaker = tieBreaker or 0
    local elementData = {
        id = elementId,
        score = score,
        tie_breaker = tieBreaker or nil,
        payload = extra
    }
    local range = 0
    local query = "?range=" .. tostring(range)
    
    local result = self:request("PUT", "/lists/" .. listId .. "/elements/" .. tostring(elementId) .. query, elementData)

    local shiftedBoundaries = {}
    if result.shifted_boundaries then
        for _, boundary in ipairs(result.shifted_boundaries) do
            table.insert(shiftedBoundaries, {
                id = boundary.id,
                prevRank = tonumber(boundary.prev_from_top) + 1, -- todo: shifted boundaries only works with descending
                newRank = tonumber(boundary.new_from_top) + 1,     -- should update rankDB to return correct from_bottom as well in future.
                prevScore = tonumber(boundary.prev_score),
                newScore = tonumber(boundary.new_score)
            })
        end
    end

    local prevRank, prevScore
    if result.previous_rank then
        prevRank = (self.ascending and result.previous_rank.from_bottom or result.previous_rank.from_top) + 1
        prevScore = tonumber(result.previous_rank.score)
    end

    return {
        id = result.id,
        prevRank = prevRank,
        newRank = (self.ascending and result.from_bottom or result.from_top) + 1,
        prevScore = prevScore,
        newScore = tonumber(result.score),
        shiftedBoundaries = #shiftedBoundaries > 0 and shiftedBoundaries or nil
    }
end

--[=[
Deletes an element from a list.
@param listId string -- The ID of the list
@param elementId number -- The ID of the element to delete
@return boolean -- True if the element was deleted, false otherwise
]=]
function RankDBClient:deleteElement(listId : string, elementId : number)
    return self:request("DELETE", "/lists/" .. listId .. "/elements/" .. tostring(elementId))
end

return RankDBClient
