# qb-recycle
Rrecycle script based on level system


![Screenshot 2023-09-16 113707](https://github.com/uFLOKY/qb-recycle/assets/80961359/3ff4fb0a-950b-4deb-a343-8bcbb2ecbb3f)



* INSTALLATION :

 
1 - Add this to qb-core/server/player

```lua
    if PlayerData.metadata['recycle'] then
        PlayerData.metadata['recycle']["amount"] = PlayerData.metadata['recycle']["amount"] or 0
        PlayerData.metadata['recycle']["grade"] = PlayerData.metadata['recycle']["grade"] or 1
        PlayerData.metadata['recycle']["progress"] = PlayerData.metadata['recycle']["progress"] or 1
    else
        PlayerData.metadata['recycle'] = {
            ["amount"] = 0,
            ["grade"] = 1,
            ["progress"] = 0,
        }
    end
```
2 - start qb-info

3 - start qb-ui

* SORRY NO SUPPORT 


* Do not sell or republish this script
* Do not sell or republish this script
* Do not sell or republish this script
