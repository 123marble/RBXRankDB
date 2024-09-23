# RBXRankDB
A wrapper to connect [RankDB server](https://github.com/Vivino/rankdb/tree/master) to your ROBLOX games 🌟!


## Why use RBXRankDB?

A limitation of ROBLOX's Ordered Datastore is that it [does not support the retrieval of specific ranks](https://devforum.roblox.com/t/how-to-get-players-rank-in-ordered-datastore-leaderboard/1080297/12?u=123marble). In order to run such queries on large leaderboards in your ROBLOX games, an externally hosted solution such as RankDB is needed.

# Usage


# Contribute
## How do I run the unit tests?
Testing requires Wally, Rojo, and Roblox Studio.
1. Ensure RankDB server is running
2. Add secrets.lua to the project root containing the following so that the tests can authenticate:
```
return {
    url = "<host_url>",
    token = "<jwt_token>"
}
```
3. Install packages with `wally install`
4. Sync `rojo` with `dev.project.json`
5. Run the Roblox Studio place
6. Check output window for test status
