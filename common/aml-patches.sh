ui_print "    Patching existing audio_policy files..."
if [ -f $VEN/etc/audio_output_policy.conf ] && [ -f $SYS/etc/audio_policy.conf ]; then
  for BUFFER in "Speaker" "Wired Headset" "Wired Headphones"; do
    if [ "$(sed -n "/$BUFFER/ {n;/deep_buffer,/ p}" $AMLPATH$SYS/etc/audio_policy.conf)" ] && [ ! "$(sed -n "/$BUFFER/ {n;n;/deep_buffer,/p}" $AMLPATH$SYS/etc/audio_policy.conf)" ]; then
      sed -i "/$BUFFER/ {n;/deep_buffer,/ p}" $AMLPATH$SYS/etc/audio_policy.conf
      sed -ri "/$BUFFER/ {n;n;/deep_buffer,/ s/( *)(.*)/\1<!--\2-->/}" $AMLPATH$SYS/etc/audio_policy.conf
      sed -i "/$BUFFER/{n;s/deep_buffer,//;}" $AMLPATH$SYS/etc/audio_policy.conf
	fi
  done
elif [ ! -f $VEN/etc/audio_output_policy.conf ] && [ -f $SYS/etc/audio_policy.conf ] && [ "$(grep "deep_buffer," $AMLPATH$SYS/etc/audio_policy.conf)" ] && [ ! "$(grep "<!--.*deep_buffer" $AMLPATH$SYS/etc/audio_policy.conf)" ]; then
  sed -ri "/(deep_buffer,|,deep_buffer)/p" $AMLPATH$SYS/etc/audio_policy.conf
  sed -ri '/(deep_buffer,|,deep_buffer)/{n;s/( *)(.*)deep_buffer(.*)/\1<!--\2deep_buffer\3-->/}' $AMLPATH$SYS/etc/audio_policy.conf
  sed -i '/<!--/!{/deep_buffer,/ s/deep_buffer,//g}' $AMLPATH$SYS/etc/audio_policy.conf
  sed -i '/<!--/!{/,deep_buffer/ s/,deep_buffer//g}' $AMLPATH$SYS/etc/audio_policy.conf
else
  for CFG in $SYS/etc/audio_policy.conf $VEN/etc/audio_output_policy.conf $VEN/etc/audio_policy.conf;; do
    if [ -f $CFG ] && [ ! "$(grep '#deep_buffer' $AMLPATH$CFG)" ] && [ "$(grep '^deep_buffer' $AMLPATH$CFG)" ]; then
	  sed -i '/deep_buffer {/,/}/ s/^/#/' $AMLPATH$CFG
    fi
  done
  for FILE in ${POLS}; do
    if [ ! "$(grep "<!--.*deep_buffer" $AMLPATH$FILE)" ]; then
	  sed -i '/deep_buffer {/,/}/ s/deep_buffer/<!--deep_buffer/g; s/}/}-->/g' $AMLPATH$FILE
	fi
  done
fi
