# qb-recycle
Rrecycle script based on level system

![Screenshot 2023-09-16 113707](https://github.com/uFLOKY/qb-recycle/assets/80961359/0160b4b6-1beb-4307-8316-f0b187eb8bcd)





* INSTALLATION :

 
1 - Add this to qb-core/server/player

```
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
* Trigger this event to open menu
```
TriggerEvent('qb-recycle:client:openMenu')
```

2 - start qb-info

3 - start qb-ui

4 - start qb-recycle

* SORRY NO SUPPORT 


* Do not sell or republish this script
* Do not sell or republish this script
* Do not sell or republish this script
