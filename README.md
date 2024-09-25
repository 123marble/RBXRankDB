# RBXRankDB
A wrapper to connect [RankDB server](https://github.com/Vivino/rankdb/tree/master) to your ROBLOX games 🌟!


## Why use RBXRankDB?

ROBLOX's Ordered Datastore [does not support the retrieval of entries at specific ranks](https://devforum.roblox.com/t/how-to-get-players-rank-in-ordered-datastore-leaderboard/1080297/12?u=123marble) and is therefore not sufficient for use cases that need to maintain and query large persistent leaderboard data. An externally hosted solution such as RankDB is required and RBXRankDB provides a simple way to interface with your RankDB server.

# Usage
Copy the contents of `src/rbxRankDB` into a module script and require it in your game. Alternatively, [install the package with Wally](https://wally.run/package/123marble-rbx/rbxrankdb). 
```lua
local RankDBClient = require(path.to.rbxRankDB)
local client = RankDBClient.new("<url>", "<token>")
client:createList("TestList")
client:updateElement("TestList", 1, 10, 0, nil) -- listId, elementId, score, prevRank, prevScore

-- returns:
-- {
--     id = 1,
--     prevRank = nil,
--     newRank = 1,
--     prevScore = nil,
--     newScore = 10,
-- }

```

# Contribute
## How do I run the unit tests?
Testing requires Wally, Rojo, and Roblox Studio.
1. Ensure RankDB server is running
2. Add secrets.lua to the project root containing the following so that the tests can authenticate:
```lua
return {
    url = "<host_url>",
    token = "<jwt_token>"
}
```
3. Install packages with `wally install`
4. Sync `rojo` with `dev.project.json`
5. Run the Roblox Studio place
6. Check output window for test status
