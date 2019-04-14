BEGIN {
	total_energy_consumption = 0.0 ;
	
	start_time = 1000 ;
	end_time = 0 ;

	Lowestid = 999999 ;
	Highestid = 0 ;

	sent_packets = 0.0 ;
	received_packets = 0.0 ;

	total_received_bytes = 0.0 ;

	total_delay = 0.0 ;
	maximum_node = 2000 ;
	
	for (i=0; i<maximum_node; i++) {
		node_energy[i] = 0;		
	}

	total_retransmit = 0 ;
	total_drop_packets = 0 ;

	for (i=0; i<maximum_node; i++) {
		retransmit[i] = 0;		
	}
	flag = 0;
	count = 0 ;
}

{
	eventName = $1 ;
	responseTime = $2 ;
	node = $3 ;
	agt = $4 ;
	packet_id = $6 ;
	type = $7 ;
	packet_size = $8 ;
	energy = $13;			
	total_energy = $14;
	idle_energy = $16;	
	sleep_energy = $18; 
	transmit_energy = $20;	
	receive_energy = $22; 
	num_retransmit = $30;

	sub(/^_*/, "", node);
	sub(/_*$/, "", node);

	if($13=="[energy"){
		node_energy[node] = idle_energy + sleep_energy + transmit_energy + transmit_energy + receive_energy ;
	}	

	if(agt=="AGT" && type== "cbr"){
		if(packet_id>Highestid) Highestid = packet_id ;
		if(packet_id<Lowestid) Lowestid = packet_id ;

		if(responseTime<start_time) start_time = responseTime ;
		if(responseTime>end_time) end_time = responseTime ;

		if(eventName=="s"){
			sent_packets += 1 ;
			sent_time[packet_id] = responseTime ;
		}

		if(eventName=="r"){
			received_packets += 1 ;
			total_received_bytes = total_received_bytes + (packet_size-20) ;
			received_time[packet_id] = responseTime ;
			delay_time[packet_id] = received_time[packet_id] - sent_time[packet_id] ;
			total_delay += delay_time[packet_id] ;
		}
	}
	
	if(eventName=="D" && type=="cbr"){
			flag = 1 ;
			total_drop_packets += 1 ;	
	}

	if( (type == "tcp" || type == "ack" )&& agt=="AGT")
	{
		if(packet_id>Highestid) Highestid = packet_id ;
		if(packet_id<Lowestid) Lowestid = packet_id ;

		if(responseTime<start_time) start_time = responseTime ;
		if(responseTime>end_time) end_time = responseTime ;

		if(eventName=="s"){
			sent_packets += 1 ;
			sent_time[packet_id] = responseTime ;
		}

		if(eventName=="r"){
			received_packets += 1 ;
			total_received_bytes = total_received_bytes + (packet_size) ;
			received_time[packet_id] = responseTime ;
			delay_time[packet_id] = received_time[packet_id] - sent_time[packet_id] ;
			total_delay += delay_time[packet_id] ;
		}	
	}

	if(responseTime>end_time) end_time = responseTime ;

	count++ ;

}

END {

	total_time = end_time - start_time ;
	packet_receive_ratio = (received_packets/sent_packets)*100 ;
	if(flag==1){
	packet_drop_ratio = (total_drop_packets/sent_packets)*100 ;
	}
	else{
	packet_drop_ratio = ((sent_packets-received_packets)/sent_packets)*100 ;
	}

	for(i=0; i<maximum_node;i++) {
		total_energy_consumption = total_energy_consumption + node_energy[i];
	}
	
	printf("%.5f\n",total_received_bytes*8/total_time) ;
	printf("%.5f\n",total_delay/received_packets) ;
	printf("%.5f\n",packet_receive_ratio) ;
	printf("%.5f\n",packet_drop_ratio) ;
	printf("%.5f\n",total_energy_consumption) ;
}