#ns file_name x_grid y_grid speed flow grid/random interval nam trace 
  
#variable nodes
for (( i = 1; i < 5; i++ )); do
	n='.nam'
	t='.tr'
	c="80211_variable_speed_$i$n"
	d="80211_variable_speed_$i$t"
	echo "Variable Speed : 

	802.11 Standard
	"
	ns 80211.tcl 10 2 $((5*i)) 20 10 1 1 $c $d 50 1
	awk -f offline.awk "$d" > "out80211_var_speed_$i.txt"
	count=0
	while IFS='' read -r line || [[ -n "$line" ]]; do
    
    if [ $count -eq 0 ]; then
	   echo "$((20*i))  $line" >> "80211_throughput_var_speed.dat"
	elif [ $count -eq 1 ]; then
	   echo "$((20*i))  $line" >> "80211_endtoend_var_speed.dat"
	elif [ $count -eq 2 ]; then
	   echo "$((20*i))  $line" >> "80211_packet_delivery_var_speed.dat"
	elif [ $count -eq 3 ]; then
	   echo "$((20*i))  $line" >> "80211_packet_drop_var_speed.dat"
	else
	   echo "$((20*i))  $line" >> "80211_energy_var_speed.dat"
	fi
    ((count++))

    done < "out80211_var_speed_$i.txt"
done

xgraph "80211_throughput_var_speed.dat" 
xgraph "80211_endtoend_var_speed.dat" 
xgraph "80211_packet_delivery_var_speed.dat" 
xgraph "80211_packet_drop_var_speed.dat"
xgraph "80211_energy_var_speed.dat"
