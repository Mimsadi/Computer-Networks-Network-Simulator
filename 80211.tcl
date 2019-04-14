#Setting grid Size
set x_grid 100
set y_grid 100

#Setting grid nodes
set row [lindex $argv 0]
set col [lindex $argv 1]
set speed [lindex $argv 2]
set flow [lindex $argv 3]
set grid [lindex $argv 5]
set nf [lindex $argv 7]
set tf [lindex $argv 8]
set queue [lindex $argv 9]

#Energy parameters
set val(energymodel)    EnergyModel     
set val(initialenergy)  1000            
set val(idlepower) 900e-3			
set val(rxpower) 925e-3			
set val(txpower) 1425e-3			
set val(sleeppower) 300e-3			
set val(transitionpower) 200e-3		
set val(transitiontime) 3
set start_time 10

#Protocols and models for different layers
set val(chan) Channel/WirelessChannel 
set val(prop) Propagation/TwoRayGround 
set val(netif) Phy/WirelessPhy 
set val(mac) Mac/802_11 
set val(ifq) Queue/DropTail/PriQueue 
set val(ll) LL
set val(ant) Antenna/OmniAntenna 
set val(ifqlen) $queue 
set val(rp) DSDV

#packets per second
set interval [lindex $argv 4]

#initialize ns
set ns [new Simulator]

#open trace file
set tr [open $tf w]
$ns trace-all $tr

#open nam file
set nm [open $nf w]
$ns namtrace-all-wireless $nm $x_grid $y_grid

#create topology 
set topo [new Topography]
$topo load_flatgrid $x_grid $y_grid

#open topology file
set topo_file [open 80211topo.txt w]

#create god
set god [create-god [expr $row*$col]]

#node config
$ns node-config  -adhocRouting $val(rp) -llType $val(ll) \
			     -macType $val(mac)  -ifqType $val(ifq) \
			     -ifqLen $val(ifqlen) -antType $val(ant) \
			     -propType $val(prop) -phyType $val(netif) \
			     -channel  [new $val(chan)] -topoInstance $topo \
			     -agentTrace ON -routerTrace OFF\
			     -macTrace ON -movementTrace OFF \
				 -energyModel $val(energymodel) \
				 -idlePower $val(idlepower) \
				 -rxPower $val(rxpower) \
				 -txPower $val(txpower) \
			     -sleepPower $val(sleeppower) \
			     -transitionPower $val(transitionpower) \
				 -transitionTime $val(transitiontime) \
				 -initialEnergy $val(initialenergy)

for {set i 0} {$i<$row*$col} {incr i} {
	set node($i) [$ns node]
}

set x_start [expr $x_grid/($col*2)];
set y_start [expr $y_grid/($row*2)];
set i 0;
while {$i < $row } {
    for {set j 0} {$j < $col } {incr j} {
	set m [expr $i*$col+$j];
	if {$grid == 1} {
		set x_pos [expr $x_start+$j*($x_grid/$col)];
		set y_pos [expr $y_start+$i*($y_grid/$row)];
	} else {
		set x_pos [expr int($x_grid*rand())] ;
		set y_pos [expr int($y_grid*rand())] ;
	}
	$node($m) set X_ $x_pos;
	$node($m) set Y_ $y_pos;
	$node($m) set Z_ 0.0
	puts -nonewline $topo_file "$m x: [$node($m) set X_] y: [$node($m) set Y_] \n"
    }
    incr i;
}; 

if {$grid == 1} {
	puts "GRID topology"
} else {
	puts "RANDOM topology"
}

#set destination
set size [expr $row*$col]
set x_start [expr $x_grid/($col*4)];
set y_start [expr $y_grid/($row*4)];
set i 0;
while {$i < $row } {
    for {set j 0} {$j < $col } {incr j} {
	set m [expr [expr $size-1]-[expr $i*$col+$j]];
	$ns at [expr $i*$j]] "$node($m) setdest [expr $x_start+$j*($x_grid/$col)]  [expr $y_start+$i*($y_grid/$row)] $speed"
    }
    incr i;
}; 
#flow control

for {set i 0} {$i < $flow } {incr i} {
	set src_($i) [new Agent/TCP]
	$src_($i) set class_ $i
	set sink_($i) [new Agent/TCPSink]
	$src_($i) set fid_ $i
	if { [expr $i%2] == 0} {
		$ns color $i Blue
	} else {
		$ns color $i Red
	}
} 
set size [expr $row*$col]
if { $size >= $flow } {
			for {set i 0} {$i < $flow } {incr i} {
				set src_node $i
				set sink_node [expr ($size-1) - $i];
				$ns attach-agent $node([expr $src_node]) $src_($i)
	  			$ns attach-agent $node([expr $sink_node]) $sink_($i)
				puts -nonewline $topo_file "Src: [expr $src_node] Dest: [expr $sink_node]\n"
			} 
		} else {
			for {set i 0} {$i < $flow } {incr i} {
				set src_node $i
				set sink_node [expr $flow - $i];
				$ns attach-agent $node([expr $src_node%$size]) $src_($i)
	  			$ns attach-agent $node([expr $sink_node%$size]) $sink_($i)
				puts -nonewline $topo_file "Src: [expr $src_node%$size] Dest: [expr $sink_node%$size]\n"
			} 
		}

	for {set i 0} {$i < $flow } {incr i} {
	     $ns connect $src_($i) $sink_($i)
	}

	for {set i 0} {$i < $flow } {incr i} {
		set cbr_($i) [new Application/Traffic/CBR]
		$cbr_($i) set packetSize_ 1000
		$cbr_($i) set rate_ 5mb
		$cbr_($i) set interval_ [expr 0.1*$interval]
		$cbr_($i) attach-agent $src_($i)
	}

	for {set i 0} {$i < $flow } {incr i} {
	     $ns at $i "$cbr_($i) start"
	     $ns at 199 "$cbr_($i) stop"
	}

proc finish {} \
{
	global ns tr nm topo_file topo nf tf
	$ns flush-trace
	close $nm
	close $tr
	#exec nam $nf &
	exit 0
}

$ns at 200.993 "finish"
$ns  at 201.0 "$ns nam-end-wireless 200.00"
$ns at 202.00 "$ns halt"

for {set i 0} {$i < $row*$col} { incr i} {
	$ns initial_node_pos $node($i) 10
}

$ns  run





















