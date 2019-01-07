FROM ubuntu:16.04
MAINTAINER Nicholas Asimov <nicholas@asimov.me>

ENV USER csgo
ENV STEAMCMD_DIR /steamcmd
ENV SERVER_DIR $STEAMCMD_DIR/csgoserver
ENV SOURCEMOD_PLUGINS_DIR $SERVER_DIR/csgo/addons/sourcemod/plugins

RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install lib32gcc1 curl net-tools lib32stdc++6 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && useradd $USER \
    && mkdir $STEAMCMD_DIR \
    && chown $USER:$USER $STEAMCMD_DIR 
	
RUN chown -R $USER:$USER $STEAMCMD_DIR

USER $USER

# Install SteamCMD
RUN mkdir -p $STEAMCMD_DIR
RUN curl -fsSL http://media.steampowered.com/client/steamcmd_linux.tar.gz | tar -C $STEAMCMD_DIR -xvz

# Create update script
RUN echo "login anonymous \nforce_install_dir $SERVER_DIR \napp_update 740 validate \nquit" > $STEAMCMD_DIR/csgo_ds.txt

# Download CS:GO server using SteamCMD
RUN $STEAMCMD_DIR/steamcmd.sh +runscript csgo_ds.txt

# Install MetaMod
RUN curl -fsSL https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git963-linux.tar.gz  | tar -C $SERVER_DIR/csgo -xvz

# Install SourceMod
RUN curl -fsSL https://sm.alliedmods.net/smdrop/1.9/sourcemod-1.9.0-git6245-linux.tar.gz | tar -C $SERVER_DIR/csgo -xvz

# Install SourceMod plugins
# 1. Automatic plugins updater
RUN curl -fsSL https://bitbucket.org/GoD_Tony/updater/downloads/updater.smx -o $SOURCEMOD_PLUGINS_DIR/updater.smx

#2 Retake plugin
RUN curl -fsSL https://github.com/splewis/csgo-retakes/releases/download/v0.3.4/retakes_0.3.4.zip -o retake.zip \
    && unzip retake.zip -d $SERVER_DIR/csgo \
    && rm -f retake.zip

#2.1 Additional retake plugins
RUN echo "Enabling additional retake plugins" \
    && mv $SOURCEMOD_PLUGINS_DIR/disabled/retakes_standardallocator.smx $SOURCEMOD_PLUGINS_DIR

# 2. PugSetup
# RUN curl -fsSL https://github.com/splewis/csgo-pug-setup/releases/download/2.0.2/pugsetup_2.0.2.zip -o pugsetup.zip \
#    && unzip pugsetup.zip -d $SERVER_DIR/csgo \
#    && rm -f pugsetup.zip

# 2.1 Enable additional PugSetup plguins
# RUN echo "Enabling additional PugSetup plguins" \
#    && mv $SOURCEMOD_PLUGINS_DIR/disabled/practicemode.smx $SOURCEMOD_PLUGINS_DIR \
#    && mv $SOURCEMOD_PLUGINS_DIR/disabled/pugsetup_chatmoney.smx $SOURCEMOD_PLUGINS_DIR \
#    && mv $SOURCEMOD_PLUGINS_DIR/disabled/pugsetup_autokicker.smx $SOURCEMOD_PLUGINS_DIR \
#    && mv $SOURCEMOD_PLUGINS_DIR/disabled/pugsetup_teamlocker.smx $SOURCEMOD_PLUGINS_DIR \
#    && mv $SOURCEMOD_PLUGINS_DIR/disabled/pugsetup_damageprint.smx $SOURCEMOD_PLUGINS_DIR

# Add custom config files
COPY cfg $SERVER_DIR/csgo/cfg/

EXPOSE 27015/udp

WORKDIR $SERVER_DIR

# Default entrypoint runs the server with 128 tickrate and autoupdates
ENTRYPOINT ["./srcds_run", "-game", "csgo", "-tickrate", "128", "-autoupdate", "-steam_dir", "..", "-steamcmd_script", "csgo_ds.txt"]

# Default cmd adds arguments for competetive mode with de_cache a default map.
# WARNING: this will only work as a LAN server. To make it public you must specify GSLT using +sv_setsteamaccount argument.
CMD ["-console", "-usercon", "+game_type", "0", "+game_mode", "1", "+mapgroup", "mg_active", "+map", "de_cache"]
