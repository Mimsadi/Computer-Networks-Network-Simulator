#ns file_name x_grid y_grid speed flow grid/random interval nam trace 
  
#variable nodes
for (( i = 1; i < 5; i++ )); do
	n='.nam'
	t='.tr'
	c="802154_variable_nodes_$i$n"
	d="802154_variable_nodes_$i$t"
	echo "Variable Nodes : 

	802.154 Standard
	"
	ns 802154.tcl 10 $((2*i)) 15 50 10 1 1 $c $d 50 1
	awk -f offline.awk "$d" > "out802154_var_node_$i.txt"
	count=0
	while IFS='' read -r line || [[ -n "$line" ]]; do
    
    if [ $count -eq 0 ]; then
	   echo "$((20*i))  $line" >> "802154_throughput_var_node.dat"
	elif [ $count -eq 1 ]; then
	   echo "$((20*i))  $line" >> "802154_endtoend_var_node.dat"
	elif [ $count -eq 2 ]; then
	   echo "$((20*i))  $line" >> "802154_packet_delivery_var_node.dat"
	elif [ $count -eq 3 ]; then
	   echo "$((20*i))  $line" >> "802154_packet_drop_var_node.dat"
	else
	   echo "$((20*i))  $line" >> "802154_energy_var_node.dat"
	fi
    ((count++))

    done < "out802154_var_node_$i.txt"
done

xgraph "802154_throughput_var_node.dat" 
xgraph "802154_endtoend_var_node.dat" 
xgraph "802154_packet_delivery_var_node.dat" 
xgraph "802154_packet_drop_var_node.dat"
xgraph "802154_energy_var_node.dat"
