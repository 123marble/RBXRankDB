local HttpService = game:GetService("HttpService")

local RankDBClient = {}
RankDBClient.__index = RankDBClient

export type getElementResult = {
    listId : string,
    id : number,
    score : number,
    tieBreaker : number,
    rank : number,
    extra : string
}

export type updateElementResult = {
    prevRank : number,
    newRank : number,
    prevScore : number,
    newScore : number
}

function RankDBClient.new(baseUrl, jwtToken, ascending : boolean)
    local self = setmetatable({}, RankDBClient)
    self.baseUrl = baseUrl
    self.jwtToken = jwtToken
    self.ascending = ascending
    return self
end

function RankDBClient:request(method, endpoint, body)
    local url = self.baseUrl .. endpoint
    local headers = {
        ["Authorization"] = "Bearer " .. self.jwtToken,
        ["Content-Type"] = "application/json"
    }
    
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
        return HttpService:JSONDecode(response.Body)
    else
        error("HTTP Error: " .. response.StatusCode)
    end
end

function RankDBClient:createList(listId : string, set : string, mergeSize : number, splitSize : number, replace : boolean) : boolean
    local listData = {
        id = listId,
        set = set,
        merge_size = tostring(mergeSize) or "500",
        split_size = tostring(splitSize) or "2000",
        load_index = "true"
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

function RankDBClient:getListLength(listId : string) : number
    local result = self:request("GET", "/lists/" .. listId)
    return tonumber(result.elements)
end

function RankDBClient:deleteList(listId : string)
    return self:request("DELETE", "/lists/" .. listId)
end

function RankDBClient:getElement(listId : string, elementId : string, range : number) : getElementResult
    range = range or 0
    local query = "?range=" .. tostring(range)
    local result = self:request("GET", "/lists/" .. listId .. "/elements/" .. elementId .. query)
    return {
        listId = result.list_id,
        id = result.id,
        score = tonumber(result.score),
        tieBreaker = tonumber(result.tie_breaker),
        extra = result.payload,
        rank = self.ascending and result.from_bottom or result.from_top
    }
end

function RankDBClient:updateElement(listId : string, elementId : string, score : number, tieBreaker : number, range : number, extra : string) : updateElementResult
    local elementData = {
        score = tostring(score),
        tie_breaker = tostring(tieBreaker),
        payload = extra
    }
    range = range or 0
    local query = "?range=" .. tostring(range)
    
    local result = self:request("PUT", "/lists/" .. listId .. "/elements/" .. elementId .. query, elementData)
    return {
        prevRank = self.ascending and result.previous_rank.from_bottom or result.previous_rank.from_top,
        newRank = self.ascending and result.from_bottom or result.from_top,
        prevScore = tonumber(result.previous_rank.score),
        newScore = tonumber(result.score)
    }
end

function RankDBClient:deleteElement(listId : string, elementId : string)
    return self:request("DELETE", "/lists/" .. listId .. "/elements/" .. elementId)
end

function RankDBClient:getElementFromLists(elementId : string, lists : {string}, allInSets : {string}, matchMetadata : {[string]: string}) : {getElementResult}
    local queryParams = "?"
    if lists then
        for _, listId in ipairs(lists) do
            queryParams = queryParams .. "lists=" .. listId .. "&"
        end
    end
    if matchMetadata then
        local metadata = HttpService:JSONEncode(matchMetadata)
        queryParams = queryParams .. "match_metadata=" .. HttpService:UrlEncode(metadata) .. "&"
    end
    if allInSets then
        for _, setName in ipairs(allInSets) do
            queryParams = queryParams .. "all_in_sets=" .. setName .. "&"
        end
    end
    local endpoint = "/xlist/elements/" .. elementId .. queryParams
    local result = self:request("GET", endpoint)
    
    local elements = {}
    for _, element in ipairs(result.success) do
        if element.results then
            local result = element.results[1]
            table.insert(elements, {
                listId = result.list_id,
                id = result.id,
                score = tonumber(result.score),
                tieBreaker = tonumber(result.tie_breaker),
                extra = result.payload,
                rank = self.ascending and result.from_bottom or result.from_top
            })
        end

    end
    
    return elements
end

return RankDBClient
