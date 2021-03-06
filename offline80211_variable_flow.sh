#ns file_name x_grid y_grid speed flow grid/random interval nam trace 
  
#variable nodes
for (( i = 1; i <= 5; i++ )); do
	n='.nam'
	t='.tr'
	c="80211_$i$n"
	d="80211_variable_flow_$i$t"
	echo "Variable flow : 

	802.11 Standard
	"
	ns 80211.tcl 10 2 15 $((i*10)) 10 1 1 $c $d 50 1
	awk -f offline.awk "$d" > "out80211_var_flow_$i.txt"
	count=0
	while IFS='' read -r line || [[ -n "$line" ]]; do
    
    if [ $count -eq 0 ]; then
	   echo "$((20*i))  $line" >> "80211_throughput_var_flow.dat"
	elif [ $count -eq 1 ]; then
	   echo "$((20*i))  $line" >> "80211_endtoend_var_flow.dat"
	elif [ $count -eq 2 ]; then
	   echo "$((20*i))  $line" >> "80211_packet_delivery_var_flow.dat"
	elif [ $count -eq 3 ]; then
	   echo "$((20*i))  $line" >> "80211_packet_drop_var_flow.dat"
	else
	   echo "$((20*i))  $line" >> "80211_energy_var_flow.dat"
	fi
    ((count++))

    done < "out80211_var_flow_$i.txt"
done

xgraph "80211_throughput_var_flow.dat" 
xgraph "80211_endtoend_var_flow.dat" 
xgraph "80211_packet_delivery_var_flow.dat" 
xgraph "80211_packet_drop_var_flow.dat"
xgraph "80211_energy_var_flow.dat"
