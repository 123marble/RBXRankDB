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

--- @type getMultiElementsResult {found: {getElementResult}, notFound: {number}}
--- @within RankDBClient
export type getMultiElementsResult = {
    found : {getElementResult},
    notFound : {number}
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

--- @type updateMultiElementsResult {found: {updateElementResult}, notFound: {number}}
--- @within RankDBClient
export type updateMultiElementsResult = {
    found : {updateElementResult},
    notFound : {number}
}

--- @type shiftedBoundary {id: number, prevRank: number, newRank: number}
--- @within RankDBClient
export type shiftedBoundary = {
    id : number,
    prevRank : number,
    newRank : number
}

--- @type element {id: number, score: number, tieBreaker: number, extra: {}}?
--- @within RankDBClient
export type element = {
    id : number,
    score : number,
    tieBreaker : number?,
    extra : {}?
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

function RankDBClient:getMultiElements(listId : string, elementIds : {number}) : getMultiElementsResult
    local result = self:request("POST", "/lists/" .. listId .. "/elements/find", {element_ids = elementIds})

    local foundElements = {}
    if result.found then
        for _, element in ipairs(result.found) do
            table.insert(foundElements, {
                id = element.id,
                score = tonumber(element.score),
                tieBreaker = tonumber(element.tie_breaker),
                extra = element.payload,
                rank = (self.ascending and element.from_bottom or element.from_top) + 1
            })
        end
    end

    local notFoundElements = {}
    if result.not_found then
        for _, elementId in ipairs(result.not_found) do
            table.insert(notFoundElements, elementId)
        end
    end

    return {found = foundElements, notFound = notFoundElements}
end

--[=[
Updates an element in a list.
@param listId string -- The ID of the list
@param element element -- The element to update
@return updateElementResult -- The result of the update operation
]=]
function RankDBClient:updateElement(
    listId : string,
    element : element
) : updateElementResult
    local elementData = self:_constructElementBodyFromElement(element)
    local range = 0
    local query = "?range=" .. tostring(range)
    local result = self:request("PUT", "/lists/" .. listId .. "/elements/" .. tostring(element.id) .. query, elementData)
    return self:_constructUpdateElementResult(result)
end

--[=[
Updates multiple elements in a list.
@param listId string -- The ID of the list
@param elements {element} -- The elements to update
@param results boolean? -- Whether to return the results of the update operation (default: true)
@return {updateElementResult} -- The results of the update operation
:::info
This method does not return previous rank or score because the API does not support it.
:::
]=]
function RankDBClient:updateMultiElements(listId : string, elements : {element}, results : boolean?) : updateMultiElementsResult
    results = results or true
    local elementData = {}
    for _, element in ipairs(elements) do
        table.insert(elementData, self:_constructElementBodyFromElement(element))
    end

    local query = results and "?results=true" or "?results=false"
    local result = self:request("PUT", "/lists/" .. listId .. "/elements" .. query, elementData)
    local foundResults = {}
    if result.found then
        for _, updatedElement in ipairs(result.found) do
            table.insert(foundResults, self:_constructUpdateElementResult(updatedElement))
        end
    end

    local notFoundResults = {}
    if result.not_found then
        for _, notFoundElement in ipairs(result.not_found) do
            table.insert(notFoundResults, notFoundElement)
        end
    end

    return {found = foundResults, notFound = notFoundResults}
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

--[=[
Gets a range of elements from a list based on rank.
@param listId string -- The ID of the list
@param rank number -- The starting rank
@param limit number -- The number of elements to retrieve
@return {getElementResult} -- An array of elements in the specified range
]=]
function RankDBClient:getRankRange(listId: string, rank: number, limit: number): {getElementResult}
    local query = string.format("?from_top=%d&limit=%d", rank, limit)
    local result = self:request("GET", "/lists/" .. listId .. "/range" .. query)
    
    local elements = {}
    for _, element in ipairs(result) do
        table.insert(elements, {
            id = element.id,
            score = tonumber(element.score),
            tieBreaker = tonumber(element.tie_breaker),
            extra = element.payload,
            rank = (self.ascending and element.from_bottom or element.from_top) + 1
        })
    end
    
    return elements
end

--[=[
Constructs the element body for API requests from an element object.
@param element element -- The element to construct the body from
@return table -- The constructed element body
]=]
function RankDBClient:_constructElementBodyFromElement(element : element)
    return {
        id = element.id,
        score = element.score,
        tie_breaker = element.tieBreaker,
        payload = element.extra
    }
end

--[=[
Constructs the update element result from the API response.
@param result table -- The API response
@return updateElementResult -- The constructed update element result
]=]
function RankDBClient:_constructUpdateElementResult(result: table): updateElementResult
	local shiftedBoundaries = self:_getShiftedBoundariesFromResult(result)

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

function RankDBClient:_getShiftedBoundariesFromResult(result : table) : {shiftedBoundary}
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
    return shiftedBoundaries
end

return RankDBClient
