#ns file_name x_grid y_grid speed flow grid/random interval nam trace 
  
#variable nodes
for (( i = 1; i < 5; i++ )); do
	n='.nam'
	t='.tr'
	c="80211_variable_nodes_$i$n"
	d="80211_variable_nodes_$i$t"
	echo "Variable Nodes : 

	802.11 Standard
	"
	ns 80211.tcl 10 $((2*i)) 15 20 10 1 1 $c $d 50 1
	awk -f offline.awk "$d" > "out80211_var_node_$i.txt"
	count=0
	while IFS='' read -r line || [[ -n "$line" ]]; do
    
    if [ $count -eq 0 ]; then
	   echo "$((20*i))  $line" >> "throughput_var_node.dat"
	elif [ $count -eq 1 ]; then
	   echo "$((20*i))  $line" >> "endtoend_var_node.dat"
	elif [ $count -eq 2 ]; then
	   echo "$((20*i))  $line" >> "packet_delivery_var_node.dat"
	elif [ $count -eq 3 ]; then
	   echo "$((20*i))  $line" >> "packet_drop_var_node.dat"
	else
	   echo "$((20*i))  $line" >> "energy_var_node.dat"
	fi
    ((count++))

    done < "out80211_var_node_$i.txt"
done

xgraph "throughput_var_node.dat" 
xgraph "endtoend_var_node.dat" 
xgraph "packet_delivery_var_node.dat" 
xgraph "packet_drop_var_node.dat"
xgraph "energy_var_node.dat"
