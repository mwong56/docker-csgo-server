## Counter Strike Global Offensive + Docker
CS:GO server in docker with 128 tick enabled by default and with SourceMod and PugSetup pre-installed.

### Docker hub image
No hub image (15 GB resulting image is too big), sorry.

### Gameserver Login Token
GSLT is now required to run CS:GO server. Visit [this page](http://steamcommunity.com/dev/managegameservers) to generate one.

### Custom config files
If you want to use custom config files put them in `cfg` folder. They will be copied while building the image.

### Details:
By default image is build with enabled autoupdate feature.
You can create new Dockerfile based on that image (FROM csgo) and customize it with plugins, configs, CMD and ENTRYPOINT instructions.

```shell
# Build image and tag it as csgo-server
docker build -t csgo-server github.com/NicholasAsimov/docker-csgo-server

# Run image with default options (CMD in Dockerfile)
docker run -d --name CSGO-Server -p 27015:27015 -p 27015:27015/udp csgo-server +sv_setsteamaccount GSLT_TOKEN

# Run image with as Classic Competetive server
docker run -d --name CSGO-Server -p 27015:27015 -p 27015:27015/udp csgo-server -console -usercon +game_type 0 +game_mode 1 +mapgroup mg_active +map de_cache +sv_setsteamaccount GSLT_TOKEN

# Add your SteamID as a SourceMod admin
docker exec -it CSGO_Server sh -c "echo '\"STEAM_1:1:000000\" \"99:z\"' >> ./csgoserver/csgo/addons/sourcemod/configs/admins_simple.ini"
```
