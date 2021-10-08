#!/bin/bash

#this represents the delay to run the loop (better be higher than 0.5 if
#you have a bad cpu

interval=1
DBUS_DEST="org.mpris.MediaPlayer2.spotify"
DBUS_PATH="/org/mpris/MediaPlayer2"
DBUS_MEMB="org.mpris.MediaPlayer2.Player"


function checkDependency {
	if command -v $1 >/dev/null 2>&1 ; then
    		printf ""
	else
    		echo "$1 not found, please install it and then execute the script again"
		echo "and then execute the script again. Thanks"
		exit 1
	fi
}



function sp-metadata {
  # Prints the currently playing track in a parseable format.

  dbus-send                                                                   \
  --print-reply                                  `# We need the reply.`       \
  --dest=$DBUS_DEST                                                             \
  $DBUS_PATH                                                                    \
  org.freedesktop.DBus.Properties.Get                                         \
  string:"$DBUS_MEMB" string:'Metadata'                                         \
  | grep -Ev "^method"                           `# Ignore the first line.`   \
  | grep -Eo '("(.*)")|(\b[0-9][a-zA-Z0-9.]*\b)' `# Filter interesting fiels.`\
  | sed -E '2~2 a|'                              `# Mark odd fields.`         \
  | tr -d '\n'                                   `# Remove all newlines.`     \
  | sed -E 's/\|/\n/g'                           `# Restore newlines.`        \
  | sed -E 's/(xesam:)|(mpris:)//'               `# Remove ns prefixes.`      \
  | sed -E 's/^"//'                              `# Strip leading...`         \
  | sed -E 's/"$//'                              `# ...and trailing quotes.`  \
  | sed -E 's/"+/|/'                             `# Regard "" as seperator.`  \
  | sed -E 's/ +/ /g'                            `# Merge consecutive spaces.`
}



function SetVolume {
	sink_input_id=$(pactl list sink-inputs | grep -B 17 "Spotify" | grep "Sink Input" | cut -c13-)

	pactl set-sink-input-volume "${sink_input_id}" "${1}"%
}

muted=false
previousTitle=""
currentTitle=""


checkDependency playerctl


while true; do
	status=`pidof spotify | wc -l`
	if [[ "$status" != 1 ]]; then
    		echo "Please Start spotify for the script to work"
		exit 1
	else	

        title=$(sp-metadata | awk -F "|" '/^title/  {print $2}')
        artist=$(sp-metadata | awk -F "|" '/^artist/  {print $2}')

        track_type=$(sp-metadata | awk -F "|" '/^trackid/  {print $2}' | awk -F ":" '{print $2}')

        currentTitle=$title

		if [ "$currentTitle" != "$previousTitle" ] && ( [[ "$currentTitle" != "Advertisement" ]] || [[ "$currentTitle" != "Spotify"  ]] || [[ "$track_type" != "ad" ]] ) ; then
			echo "Now playing: ${artist} ${currentTitle}, (${track_type})"
			previousTitle="$currentTitle"
		fi


		( [[ "$currentTitle" = "Advertisement" ]] || [[ "$currentTitle" = "Spotify"  ]] || [[ "$track_type" = "ad" ]] ) && isPlayingAd=true || isPlayingAd=false

		if [ "$muted" = false ] && [ "$isPlayingAd" = true ]; then
			SetVolume 0
			muted=true
			echo "muted ad"
		elif [ "$muted" = true ] && [ "$isPlayingAd" = false ]; then
			sleep 1
			SetVolume 100
			muted=false
		fi
		sleep "$interval"
	fi
done
