;; NOTE-27-8-2019: Goes well  with only continuous inventory, Have to test only checkouts and the mix of both.

;;
breed [ readers reader ]
;
breed [ checkouts checkout ]
breed [ charts chart ]
;
undirected-link-breed [ rris rri ]
breed [ tags tag ]
breed [ pallets pallet ]
breed [ trucks truck ]
breed [ supervisors supervisor ]

trucks-own [
  pallets-in-truck
  total-pallets
  time-entered-queue
]
pallets-own [
  num-tags-in-pallet
  tags-in-pallet
  still-not-inventoried ; true if pallet is  being inventoried
  ;pallet-distance ; min ( list random normal [2,1] 3 ) or U[ 2 - 1 , 2 + 1 ] metros
  ; also max (list  min (list random-normal 2 0.8 3) 1)
  dx-to-center-of-reader
  dy-to-center-of-reader
  ; my-truck
]

charts-own [
  num-tags-in-chart
  tags-in-chart
  still-not-inventoried ; true if pallet is  being inventoried
  chart-distance ; min ( list random normal [2,1] 3 ) or U[ 2 - 1 , 2 + 1 ] metros
  ; also max (list  min (list random-normal 2 0.8 3) 1)
  time-entered-queue
]

readers-own [ ; we are serving a complete truck, at the moment
  truck-being-served ; current truck occupying the server
  pallet-being-served
  frame frame-size my-tags
  cs ce cc cs-t ce-t cc-t
  TM? LM? contention? collide?
  TM-time LM-time ; LM >= 0.005s, TM <=4s
  efficiency throughput
  num-of-collisions
  ; readers use 2 modes: LM, TM
  next-start-LM-time ; if the reader comes from TM has to be + 0.1s
  next-start-TM-time
  next-completion-time
  ;
  reader-power-tx ; fixed for my simulations 2W EIRP
  reader-power-rx
  ;
  number-of-tag-outages
  reader-height_1_tx ; _1 even frame
  reader-height_1_rx
  reader-height_2_tx ; _2 odd frame
  reader-height_2_rx
  ;reader-height_1 ; h1 even frame
  ;reader-height_2 ; odd frame
  reader-gain-tx-rx ;
  reader-frequency  ; reader carrier frequency
  reader-sensitivity
  reader-read-error
  reader-outage-count
  even-frame? ; to know alternative frames: even h1=1.4 and odd h1= 2.2
  cycle ; count the periodic reading cycles of a block of pallets
  tag-selection-filter ; to select a group of tags, each cycle one different
  ; the number of groups depends on the global interface variable 'num-tag-groups'
  delta ; is the minimum number of contention trials
  ;;
  ;;NOTE:
  ; Review these vars to setup with globals incli_tx_rx and height_tx_rx
  reader_height_1_tx_rx ; vertical (y-direction) shift for the reader. Current value is 0
  inclination_angle_1_tx_rx
  ; see if we can avoid next vars
  inclination_angle_1_tx
  inclination_angle_1_rx
  inclination_angle_2_tx
  inclination_angle_2_rx
  ;END *Note*
  ;
  interf-from-neighbors_LM-linear
  interf-from-neighbors_TM-linear
  ;
  queue-r
]

checkouts-own [ ; we are serving a complete truck, at the moment
  ;truck-being-served ; current truck occupying the server
  ;pallet-being-served
  chart-being-served
  frame frame-size my-tags
  cs ce cc cs-t ce-t cc-t
  TM? LM? contention? collide?
  TM-time LM-time ; LM >= 0.005s, TM <=4s
  efficiency throughput
  num-of-collisions
  ; readers use 2 modes: LM, TM
  next-start-LM-time ; if the reader comes from TM has to be + 0.1s
  next-start-TM-time
  next-completion-time
  ;
  checkout-power-tx ; fixed for my simulations 2W EIRP
  checkout-power-rx
  ;
  number-of-tag-outages

  checkout-height_1_tx ; _1 even frame
  checkout-height_1_rx
  checkout-height_2_tx ; _2 odd frame
  checkout-height_2_rx

  checkout-gain-tx-rx ;
  checkout-frequency  ; reader carrier frequency
  checkout-sensitivity
  checkout-read-error
  reader-outage-count
  even-frame? ; to know alternative frames: even h1=1.4 and odd h1= 2.2
  delta ; is the minimum number of contention trials
  ;
  inclination_angle_1_tx
  inclination_angle_1_rx
  inclination_angle_2_tx
  inclination_angle_2_rx
  ;
  interf-from-neighbors_LM-linear
  interf-from-neighbors_TM-linear
]

tags-own [
  time-entered-queue
  time-entered-service
  my-inventory-slot
  inventoried?
  time-of-inventory
  ;
  distance-to-checkout_1_fw ; there are two readers per docking portal
  distance-to-checkout_1_bw
  distance-to-checkout_2_fw
  distance-to-checkout_2_bw
  distance-to-reader
  ; the postition of the tag in the pallet
  ; relative to pallet-position
  tag-x ; U(-0.75 , 0.75) + pallet-distance gives D of my alculations ; This is my 'D'
  D_1 D_2
  tag-y ; U(0.10, 1.20) This is my 'h2'
  tag-z
  tag-power-rx ; to see if there is a power outage or not
               ; which depends on R that is ( D + (h1+h2)^2 /(2D) )
  tag-outage? ; it can be not powered depends of the position in the pallet
  tag-gain
  tag-gain-fw
  tag-gain-bw
  tag-sensitivity
  q_e_rcn_fw
  shadow_fw
  outage-count-of-this-tag
  ; time-being-inventoried-first
  inventoried-first?
  tag-round-not-located ; count the number of times is NOT located
  ; next a random number given to the tag at creation
  ; the reader must points to them in a round robin fashion by 'tag-selection-filter'
  tag-id-group
  ;;---
  ;;
  azimuthal_angle_1_fw_bw
  alpha_1_fw_bw
  ;; this angle for the half wave dipole tag antenna (to compute directivity gain of tag antenna)
  ;dipole_inclination_angle
  dipole_inclination_angle_fw_bw ;;Note that inclination angle might be related with azimuthal angle of the reader (phi or (phi + 90))
  ;
  in-chart? ; 'true' if it goes in a chart, 'false' otherwise
  ;; (to compute directivity gain of Checkout Tx/Rx antenna)
  azimuthal_angle_1_fw
  azimuthal_angle_1_bw
  azimuthal_angle_2_fw
  azimuthal_angle_2_bw
  alpha_1_fw
  alpha_1_bw
  alpha_2_fw
  alpha_2_bw
  ;; this angle for the half wave dipole tag antenna (to compute directivity gain of tag antenna)
  ;dipole_inclination_angle
  dipole_inclination_angle_fw
  dipole_inclination_angle_bw
]

;__includes ["phiDFSA.nls"]
; show phiDFSA 50 0.02 ; N and T

supervisors-own [
  next-lookup-time
  product-searched ; the tag to lookup, the agent tag
  cf ; count the founds
  cnf ; count the not founds
  ; active?
]

globals [
  xy-file xy-file-chk
  queue-file
  queue-length
  num-of-queue-samples ; 1, 2, ....50
  p-loss-file
  p-loss-list
  time-id-first-file ;to save samples of first id time of tags
  time-samples-count ; to count samples of first id time of tags
  ;
  known-file
  lookup-file
  ;;
  ;
  cycle-file
  ; Q 1..15 ; determine the number of slotSS (K= 2^Q)
  t1S t1C t1E ; times of successful collision and empty slot 1
  tS tC tE    ; times of successful collision and empty any slot in frame 2..2^Q
  min-LM max-TM TM-to-LM-time ; time limits for receiver mode plus the time after TM
  tiny-num
  tau ; propagation time by metre of the reader's signal
  queue ; waiting line
  queue-chk
  arrival-count ; Arrival process (for trucks, for now)
  next-arrival-time
  next-departure-time ; Departure process of pallets
  next-reorganization-time
  next-replenish-time
  ;next-lookup-time ; lookup process
  ; Statistics for average load/usage of queue and servers
  stats-start-time
  total-truck-queue-time
  total-tag-queue-time
  total-tag-service-time
  total-truck-service-time
  total-chart-queue-time
  total-chart-service-time
  ; Statistics for average time-in-queue and time-in-service
  total-time-in-queue
  total-time-in-queue-chk
  total-time-in-system
  total-time-in-system-chk
  total-queue-throughput
  total-queue-throughput-chk
  total-system-throughput
  total-system-throughput-chk
  ; Theoretical measures, computed analytically using classic queueing theory
  expected-utilization
  expected-queue-length
  expected-queue-time
  ; Anonymous procedures
  end-run-task
  arrive-task
  complete-service-task
  complete-service-task-chk
  ; reset-stats-task ; unnecessary for now
  ; plus
  start-LM-task
  start-TM-task
  departure-task
  lookup-task
  reorganization-task
  replenish-task
  ;;;
  ;;variables for BS reporters
  total-system-throughput-sg
  total-pallets-thoughput-sg
  total-tags-inventoried
  ;pallets-in-queue
  average-inv-ratio
  inv-count
  ;tags-in-queue
  reader-utilization-percent
  avg-queue-length
  final-length-queue
  total-num-arrivals
  avg-time-queue-of-tags
  avg-time-in-system-of-tags
  total-simulation-time-sg
  mean-num-collisions-sg
  total-num-of-collisions
  ;; Network
  mean-num-links
  ;;;;;; Link Budgets
  empty-frames-TM
  tags-loose-memory ; counts all tags that losses memory
  ; -----
  polarz-mismatch       ; X ~ 0.5
  pow-tx-coefficient   ; \tau ~ 1
  modulation-factor    ; M ~0.25 indicates the energy reflected by the tag for 0's and 1's
  on-object-gain-penalty ; \Theta ~ 1.2
  path-blockages ; B ~ 1
  fading-factor-fw
  fading-factor-bw
  fading-factor-bw-a ; bistatic collocated
  fading-factor-bw-b ; bistatic dislocated
  ;portal-width ; anchura del portal
  c
  ;
  noise-figure_dB
  noise-density_dBm_Hz
  max-rx-BW
  rician-factor rician-factor_dB
  ;sigma ; std deviation of SHADOWING
  ;
  tags-with-one-outage
  tags-with-two-outage
  radians-to-degrees
  ;
  tag-with-interf-decod-well
  tag-with-interf-decod-bad
  tag-unique-with-errors
  max-num-of-outages
  total-pallets-thoughput
  total-charts-throughput
  total-outages
  ;
  total-offered-load-of-charts
  total-offered-load-of-tags
  total-offered-load-of-tags-sg
  total-offered-load-of-charts-sg
  ;
  warehouse-capacity ; all pallets in warehouse
  total-departures ; counts the num of departures
  total-inventory-cycles ; counts the num of inventory cycles
  total-inventory-cycles-bak
  ;
  total-lookup-errors ; errors of lookup of all supervisors
  total-lookups ; total lookups of all supervisors
  maxnum-fail-inventories ; total rounds of no locating a tag to declare is not known its loc.
  super ; used to compute a monitor in the user interface
  ;
  total-swaps
  diameter-x
  diameter-y
  total-initial-tags
  total-p-arrivals ; number of pallets in an arrival will be a counter
  ;;
  num-known-samples ; to count the number of samles of inventoried-first? tags / total tags ratio
  moments-of-arrivals
  ;
  allreaders-set
  sys-time-file
  ;;
  average-S1 average-S2
  average-efficiency
  ACPR_linear ;Adjacent Channel Power Ratio, in the DRE masc is 30dB
  ;;
  final-known-tag-ratio
  final-mean-efficiency
  fsa-mean-throughput
  fsa-sum-throughput
  ;
  ;to measure the cycle time in which all readers has complete their cycle
  cycle-init-time; (list ) ; save the init times of each cycle
  cycle-end-time
  cycle-time
  ;
  ctc c1 c0 c1-c0 min_cycle max_cycle

]

;to startup
;  setup
;end

to setup-timeconstants
  set t1S 0.00283 set t1C 0.00074 set t1E 0.00046 ; slot 1 of PQuery
  set tS 0.00258 set tC 0.00049 set tE 0.00021 ; slots 2..K of QRep
  set min-LM 0.005 set max-TM 4 set TM-to-LM-time 0 ; time limits for each mode NOW 0, BEFORE 0.1 as standard
  set empty-frames-TM 0.00109 ; time threshold of 3 frames empty and Pquery empty after completition
  set tiny-num 0.000000001 ; 1ns
  set tau 0.000000003 ; 3ns, propagation time by metre of the reader's signal
  set tags-loose-memory 0 ; to count the tags left expire the memory time.
end

to setup-globals
  ;set xy-file "locations200R.txt"
  ;set xy-file "locations20R.txt"
  ;set xy-file "locations50R.txt"
  ;set xy-file "locations1R.txt"
  ;set xy-file "locations3R.txt"
  set xy-file (word "regular" num-readers ".txt")
  set xy-file-chk (word "_checkouts-xy-" num-checkouts ".txt")
  set queue-file (word "queue-length-" num-readers "-" mean-departure-rate "-" mean-tags-per-pallet "-" scenario "-" interference-type "-" time-between-inventories "-" ceiling-to-floor-distance ".txt")
  set num-of-queue-samples 0
  set queue-length (list )
  ;;
  set p-loss-file (word "p-loss-" num-readers "-" mean-departure-rate "-" mean-tags-per-pallet "-" scenario "-" interference-type "-" time-between-inventories "-" ceiling-to-floor-distance "-" behaviorspace-run-number ".txt")
  set p-loss-list (list )
  if file-exists? p-loss-file [ file-delete p-loss-file ]
  ;;
  set time-id-first-file (word "t-id-first-" num-readers "-" mean-departure-rate "-" mean-tags-per-pallet "-" scenario "-" interference-type "-" time-between-inventories "-" ceiling-to-floor-distance "-" behaviorspace-run-number ".txt")
  set time-samples-count 0 ; to count the number of samples in the file
  if file-exists? time-id-first-file [ file-delete time-id-first-file ]
  ;;
  set known-file (word "known-ratio-" num-readers "-" mean-departure-rate "-" mean-tags-per-pallet "-" scenario "-" interference-type "-" time-between-inventories "-" ceiling-to-floor-distance "-" behaviorspace-run-number ".txt")
  if file-exists? known-file [ file-delete known-file ]
  ;;
  set lookup-file (word "lookup-ratio" "-" num-readers "-" mean-departure-rate "-" mean-tags-per-pallet "-" scenario "-" interference-type "-" time-between-inventories "-" ceiling-to-floor-distance "-" behaviorspace-run-number ".txt")
  if file-exists? lookup-file [ file-delete lookup-file ]
  ;;
  set cycle-file (word "cycle-data" "-" num-readers "-" mean-departure-rate "-" mean-tags-per-pallet "-" scenario "-" interference-type "-" time-between-inventories "-" ceiling-to-floor-distance "-" behaviorspace-run-number ".txt")
  if file-exists? cycle-file [ file-delete cycle-file ]
  ;;-
  set sys-time-file (word "sys-time-" num-checkouts "-" num-readers "-" minimum-stock-level "-" time-between-inventories "-" number-of-contention-intervals "-" behaviorspace-run-number ".txt")
  if file-exists? sys-time-file [ file-delete sys-time-file ]
  ;-
  set queue []
  set queue-chk []
  set next-arrival-time 0
  set next-departure-time 0
  set arrival-count 0
  set-default-shape readers "square 2" ; circle
  set-default-shape checkouts "circle 2" ; circle 2
  set-default-shape tags "x"
  set stats-start-time 0
  ; now the globals for the Link budget
  set polarz-mismatch 0.5      ; X ~ 0.5
  set pow-tx-coefficient 1  ; \tau ~ 1
  set modulation-factor 0.25   ; M indicates the energy reflected by the tag for 0's and 1's
  set on-object-gain-penalty 1.2
  set path-blockages 1
  ;set fading-factor-fw 10 ;10 ; 10 for a P(outage >= 0.05 ) con K = 3dB
  ;set fading-factor-bw 1 ;126 ; Monostatic
  ;set fading-factor-bw-a 40 ; Bistatic Collated. Griffin solo dice que es menor q monostatic
  ;set fading-factor-bw-b 32 ; 32 Bistatic Dislocated
  set fading-factor-fw 10
  set fading-factor-bw 10 ; NOT USE
  set fading-factor-bw-a 40
  set fading-factor-bw-b 40 ; NOT USE
  ;set portal-width 5 ; meters or width
  set c 300000000 ; speed of light
  set noise-figure_dB 22
  set noise-density_dBm_Hz -174
  set max-rx-BW 1600000
  set rician-factor_dB 3
  set rician-factor (10 ^ (rician-factor_dB / 10 ) )
  ;set sigma 1.94 ; This is the sigma for shadowing
  set tags-with-one-outage 0
  set tags-with-two-outage 0
  set radians-to-degrees (180 / pi)
  set tag-with-interf-decod-well 0 ; to count when there are 1 tag resolved well from varius
  set tag-with-interf-decod-bad 0 ; to count when there are no a tag resolved well from varius
  set tag-unique-with-errors 0 ; when 1 tag in a slot is bad decod.
  set max-num-of-outages 5 ; before was 5
  ;;;
  set total-offered-load-of-charts 0
  set total-offered-load-of-tags 0
  ;;;
  set warehouse-capacity ifelse-value two-height? [( num-readers * ( num-pallets-by-side ^ 2 ) ) * 2
  ][( num-readers * ( num-pallets-by-side ^ 2 ) )]
    ; number of pallets
  set total-departures 0
  set total-inventory-cycles 0
  set total-inventory-cycles-bak 0
  set total-lookup-errors 0
  set total-lookups 0
  set maxnum-fail-inventories 3 ; before was 10
  set total-swaps 0
  set diameter-x 0 set diameter-y 0
  set total-initial-tags (warehouse-capacity * mean-tags-per-pallet)
  set total-p-arrivals 0 ; number of pallets in an arrival will be a counter
  ;
  set num-known-samples 0
  set moments-of-arrivals 0
  ;
  set inv-count 0 ; to compute inv-ratio averaged
  ;;
  set ACPR_linear 10 ^ (30 / 10) ;30dB
  if (transmitter-power <= 0.1) [set interf-threshold -83]
  if (transmitter-power > 0.1) and (transmitter-power <= 0.5) [set interf-threshold -90]
  if (transmitter-power >= 0.5) [set interf-threshold -96]
  ;
  set cycle-init-time (list )
  set cycle-end-time 0
  ;
  set ctc 0 set c1 0 set c0 0
  set c1-c0 0 set min_cycle 0 set max_cycle 0

end

to setup
  clear-all
  ;random-seed behaviorspace-run-number
  ;random-seed 100
  reset-ticks
  reset-stats
  ;set-scenario-vars
  setup-globals
  setup-timeconstants
  ask patches [ set pcolor blue - 3 ]
  setup-readers
  setup-checkouts
  set allreaders-set (turtle-set readers checkouts)
  setup-supervisors
  setup-tasks
  ;reset-ticks
  reset-stats
  ; now we set de pallets under the reader
  ; with proc arrive for each reader
  setup-tags-under
  ;schedule-arrival
  schedule-departure
  if swap-pallets? and (num-readers > 1) [ schedule-reorganization ]
  ask supervisors [ schedule-lookup ]
  ;schedule-replenish ; only if replenish is in event-queue
end



to setup-supervisors
  create-supervisors num-supervisors [
    set next-lookup-time 0
    set product-searched nobody
    set cf 0
    set cnf 0
    ;set active? true
    set hidden? true
  ]
end

to setup-checkouts
   ifelse new-netw? [
    ifelse random-topology? [
      create-checkouts num-checkouts [
        set color green ; means idle state 'red' is active
        setxy random-xcor random-ycor
        set size 3
        set cs-t 0 set cc-t 0 set ce-t 0
        set TM-time 0 set LM-time 0
        set TM? false
        set LM? false
        set contention? false
        set collide? false
        set num-of-collisions 0
        set frame 0
        set chart-being-served nobody
        set next-completion-time 0
        set checkout-gain-tx-rx 5 ; 7dBi
        set checkout-power-tx 0.8 ; 800 mW, or, 29 dBm
        set checkout-frequency (865700000) ; center frequency of Ch1
        set checkout-read-error 0
        set reader-outage-count 0
        set checkout-height_1_tx height_1_tx; _1 even frame
        set checkout-height_1_rx height_1_rx
        set checkout-height_2_tx height_2_tx ; _2 odd frame
        set checkout-height_2_rx height_2_rx
        ;
        set inclination_angle_1_tx incli_1tx
        set inclination_angle_1_rx incli_1rx
        set inclination_angle_2_tx incli_2tx
        set inclination_angle_2_rx incli_2rx
        ;
        set even-frame? false
        set checkout-sensitivity (10 ^ (reader-sensitivity-g / 10)) / 1000 ;0.1E-10; -80 ;dBm
        set delta 1
      ]
    ] [ spawn-by-row "chk" ]
    write-readers-xy xy-file-chk "chk"
  ] [
    read-readers-xy xy-file-chk "chk" ]
  ;ask checkouts [ create-rris-with other (turtle-set checkouts readers) in-radius interf-rri-radius ]
  ask (turtle-set checkouts readers) [ create-rris-with other (turtle-set checkouts readers) in-radius interf-rri-radius ]
  ;ask rris [ show (10 * link-length) ]
end

to-report temp-in-radius [agentset r]
  report (agentset with [ distance myself <= r ])
end

to-report temp-in-radius-distances
  let l (list )
  let rand-inventory-readers n-of 4 readers
  show [who] of rand-inventory-readers
  ask rand-inventory-readers [ set l lput (distance (checkout 16)) l ]
  report l
end

to setup-readers
   ifelse new-netw? [

    ifelse random-topology? [
      create-readers num-readers [
        set color green ; means idle state 'red' is active
        setxy random-xcor random-ycor
        set size 3
        set cs-t 0 set cc-t 0 set ce-t 0
        set TM-time 0 set LM-time 0
        set TM? false
        set LM? false
        set contention? false
        set collide? false
        set num-of-collisions 0
        set frame 0
        set truck-being-served nobody
        set pallet-being-served nobody
        set next-completion-time 0
        set reader-gain-tx-rx 5 ; 7dBi
        set reader-power-tx transmitter-power ;0.8 ; 800 mW, or, 29 dBm
        set reader-frequency (865700000) ; center frequency of Ch1
        set reader-read-error 0
        set reader-outage-count 0
        set reader_height_1_tx_rx (height_tx_rx)
        ;set reader-height_2 2.0
        set even-frame? false
        set cycle 0
        set tag-selection-filter 0 ; [0..num-tag-groups]
        ;;
        set inclination_angle_1_tx_rx incli_tx_rx
        ;
        set inclination_angle_1_tx incli_tx_rx
        set inclination_angle_1_rx incli_tx_rx
        set inclination_angle_2_tx incli_tx_rx
        set inclination_angle_2_rx incli_tx_rx
        ;
        set reader-sensitivity (10 ^ (reader-sensitivity-g / 10) ) / 1000
        set interf-from-neighbors_TM-linear 0
        set queue-r (list )
        ;
        set reader-height_1_tx ceiling-to-floor-distance; _1 even frame
        set reader-height_1_rx ceiling-to-floor-distance
        set reader-height_2_tx ceiling-to-floor-distance; _2 odd frame
        set reader-height_2_rx ceiling-to-floor-distance
      ]
    ] [ spawn-by-row "read"]

    write-readers-xy xy-file "rd"] [
    read-readers-xy xy-file "rd"]

  ;ask readers [ create-rris-with other readers in-radius (interf-rri-radius / 10) ] ;not correct from version 6.0.3
   ;ask readers [ create-rris-with (temp-in-radius other readers (interf-rri-radius / 10)) ]
end

to set-scenario-vars
  ; each block has [[63 1.862] ]
;  if interference-type = "0" [set min-tag-inclination-angle 4.5]
;  if interference-type = "1" [set min-tag-inclination-angle 3.75]
;  if interference-type = "2" [set min-tag-inclination-angle 2.75]
  ;set tag-in-top? false
  set mean-tags-per-pallet ifelse-value two-height? [126][63]
  set distance-multiplicative 2
  if scenario = "a" [
    set num-readers 2
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 2
    set num-pallets-by-side 4
    set p-height 4
    set two-height? true
    ;set mean-tags-per-pallet 100
  ]
  if scenario = "b" [
    set num-readers 4
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 2
    set num-pallets-by-side 4
    set p-height 2
    set two-height? false
    ;set mean-tags-per-pallet 50
  ]
  if scenario = "c" [
    set num-readers 16
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 4
    set num-pallets-by-side 2
    set p-height 2
    set two-height? false
    ;set mean-tags-per-pallet 50
  ]
  if scenario = "d" [
    set num-readers 64
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 8
    set num-pallets-by-side 1
    set p-height 2
    set two-height? false
    ;set mean-tags-per-pallet 50
  ]
  if scenario = "e" [
    set num-readers 8
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 4
    set num-pallets-by-side 2
    set p-height 4
    set two-height? true
    ;set mean-tags-per-pallet 100
  ]
  if scenario = "f" [
    set num-readers 32
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 8
    set num-pallets-by-side 1
    set p-height 4
    set two-height? true
    ;set mean-tags-per-pallet 100
  ]
  ;;;------------------------
  if scenario = "cycle_10" [
    set num-readers 10
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 5
    set readers-per-column 2
    set num-pallets-by-side 2
    set p-height 2
    set two-height? false
    ;set mean-tags-per-pallet 100
  ]
  if scenario = "cycle_20" [
    set num-readers 20
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 5
    set readers-per-column 4
    set num-pallets-by-side 2
    set p-height 2
    set two-height? false
    ;set mean-tags-per-pallet 100
  ]
  if scenario = "cycle_30" [
    set num-readers 30
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 6
    set readers-per-column 5
    set num-pallets-by-side 2
    set p-height 2
    set two-height? false
    ;set mean-tags-per-pallet 100
  ]
  if scenario = "cycle_40" [
    set num-readers 40
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 8
    set readers-per-column 5
    set num-pallets-by-side 2
    set p-height 2
    set two-height? false
    ;set mean-tags-per-pallet 100
  ]
  if scenario = "cycle_50" [
    set num-readers 50
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 10
    set readers-per-column 5
    set num-pallets-by-side 2
    set p-height 2
    set two-height? false
    ;set mean-tags-per-pallet 100
  ]
  if scenario = "cycle_60" [
    set num-readers 60
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 10
    set readers-per-column 6
    set num-pallets-by-side 2
    set p-height 2
    set two-height? false
    ;set mean-tags-per-pallet 100
  ]
  if scenario = "cycle_70" [
    set num-readers 70
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 10
    set readers-per-column 7
    set num-pallets-by-side 2
    set p-height 2
    set two-height? false
    ;set mean-tags-per-pallet 100
  ]
  if scenario = "cycle_80" [
    set num-readers 80
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 10
    set readers-per-column 8
    set num-pallets-by-side 2
    set p-height 2
    set two-height? false
    ;set mean-tags-per-pallet 100
  ]
  ;;------------------------------------------------
  if scenario = "cycle_90" [
    set num-readers 90
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 10
    set readers-per-column 9
    set num-pallets-by-side 2
    set p-height 2
    set two-height? false
    ;set mean-tags-per-pallet 100
  ]
  if scenario = "cycle_100" [
    set num-readers 100
    set distance-var-x 10
    set distance-var-y 10
    set readers-per-row 10
    set readers-per-column 10
    set num-pallets-by-side 2 ;<<- ojo
    set p-height 2
    set two-height? false
    ;set mean-tags-per-pallet 63
  ]
  ;;------------------------------------------------
  if scenario = "cycle_120" [
    set num-readers 120
    set distance-multiplicative 4
    set distance-var-x 5
    set distance-var-y 5
    set readers-per-row 12
    set readers-per-column 10
    set num-pallets-by-side 1
    set p-height 4
    set two-height? true
    ;set mean-tags-per-pallet 100
  ]
  if scenario = "cycle_140" [
    set num-readers 140
    set distance-multiplicative 4
    set distance-var-x 5
    set distance-var-y 5
    set readers-per-row 14
    set readers-per-column 10
    set num-pallets-by-side 1
    set p-height 4
    set two-height? true
    ;set mean-tags-per-pallet 100
  ]
  if scenario = "cycle_160" [
    set num-readers 160
    set distance-multiplicative 4
    set distance-var-x 5
    set distance-var-y 5
    set readers-per-row 16
    set readers-per-column 10
    set num-pallets-by-side 1
    set p-height 4
    set two-height? true
    ;set mean-tags-per-pallet 100
  ]
  if scenario = "cycle_180" [
    set num-readers 180
    set distance-multiplicative 4
    set distance-var-x 5
    set distance-var-y 5
    set readers-per-row 18
    set readers-per-column 10
    set num-pallets-by-side 1
    set p-height 4
    set two-height? true
    ;set mean-tags-per-pallet 100
  ]
end

to spawn-by-row [ tpe ]
  ; Get a range of coordinate values
;  ifelse close? [
;    set distance-var-x 1 set distance-var-y 1
;    set readers-per-row 20 set readers-per-column 5
;  ] [ ; else FAR
;    set distance-var-x 12 set distance-var-y 22 ; [12 22]
;    set readers-per-row 8 set readers-per-column 5
;  ]
  ;set-scenario-vars
  let half-step 0.5 * distance-var-x
  ;let d-vals ( range ( min-pxcor + half-step ) ( max-pxcor ) distance-var-x )
  let d-vals ( range ( min-pxcor + half-step ) ( min-pxcor + (readers-per-row * distance-var-x)) distance-var-x )
  ;let dc-vals ( range ( min-pycor + half-step ) ( max-pycor ) distance-var-y )
  let dc-vals ( range ( min-pxcor + half-step ) ( min-pycor + (readers-per-column * distance-var-y)) distance-var-y )
  ; Create an empty list to build into
  let possible-coords []

  ; For each possible vertical value, map all horizontal values in order and
  ; combine these into an ordered list starting at the lowest px and py coords

  foreach dc-vals [
    d ->
    set possible-coords ( sentence possible-coords map [ i -> (list i d) ] d-vals )
  ]
  ;let num-checkouts 0
  ; Use the number of readers to sublist the possible coordinates, and
  ; create a turtle at each of the coordinate combinations left.
  let max-positions length possible-coords
  ;if tpe = "read" [
  if max-positions > (num-readers + num-checkouts) [ set max-positions (num-readers + num-checkouts) ]
  if tpe = "read" [
    let use-coords sublist possible-coords num-checkouts max-positions
    foreach use-coords [
      coords ->
      create-readers 1 [
        set color green ; means idle state 'red' is active
        setxy item 0 coords item 1 coords
        ;set shape "dot"
        set size 3
        set cs-t 0 set cc-t 0 set ce-t 0
        set TM-time 0 set LM-time 0
        set TM? false
        set LM? false
        set contention? false
        set collide? false
        set num-of-collisions 0
        set frame 0
        set truck-being-served nobody
        set pallet-being-served nobody
        set next-completion-time 0
        set reader-gain-tx-rx 5 ; 7dBi
        ;;
        set reader-power-tx transmitter-power ;0.8 ; 800 mW, or, 29 dBm
        set reader-frequency (865700000) ; center frequency of Ch1
        set reader-read-error 0
        set reader-outage-count 0
        set reader_height_1_tx_rx (height_tx_rx)
        set even-frame? false
        set cycle 0
        set tag-selection-filter 0 ; [0..num-tag-groups]
        ;;
        set inclination_angle_1_tx_rx incli_tx_rx
        ;
        set inclination_angle_1_tx incli_tx_rx
        set inclination_angle_1_rx incli_tx_rx
        set inclination_angle_2_tx incli_tx_rx
        set inclination_angle_2_rx incli_tx_rx
        ;
        set reader-sensitivity (10 ^ (reader-sensitivity-g / 10) ) / 1000
        set interf-from-neighbors_TM-linear 0
        set queue-r (list )
        set delta number-of-contention-intervals
        ;;
        set reader-height_1_tx ceiling-to-floor-distance; _1 even frame
        set reader-height_1_rx ceiling-to-floor-distance
        set reader-height_2_tx ceiling-to-floor-distance; _2 odd frame
        set reader-height_2_rx ceiling-to-floor-distance
      ] ;create
    ] ; foreach
  ] ; if
  if tpe = "chk" [
    ;if num-checkouts >= 1 [
      let use-coords sublist possible-coords 0 (num-checkouts )
      foreach use-coords [
        coords ->
        create-checkouts 1 [
          set color green ; means idle state 'red' is active
          setxy item 0 coords item 1 coords
          ;set shape "dot"
          set size 3
          set cs-t 0 set cc-t 0 set ce-t 0
          set TM-time 0 set LM-time 0
          set TM? false
          set LM? false
          set contention? false
          set collide? false
          set num-of-collisions 0
          set frame 0
          set chart-being-served nobody
          set next-completion-time 0
          set checkout-gain-tx-rx 5 ; 7dBi
          set checkout-power-tx 0.8 ; 800 mW, or, 29 dBm
          set checkout-frequency (865700000) ; center frequency of Ch1
          set checkout-read-error 0
          set reader-outage-count 0
          set checkout-height_1_tx height_1_tx; _1 even frame
          set checkout-height_1_rx height_1_rx
          set checkout-height_2_tx height_2_tx ; _2 odd frame
          set checkout-height_2_rx height_2_rx
          set even-frame? false
          set checkout-sensitivity (10 ^ (reader-sensitivity-g / 10)) / 1000 ;0.1E-10; -80 ;dBm
          set checkout-read-error 0
          set delta 1
        ] ; create
      ] ; foreach
   ; ];if
  ] ; if chk
end

to write-readers-xy [ fxy p ]
  if file-exists? fxy [ file-delete fxy ]
  file-open fxy
  ifelse p = "rd" [
    ask readers [
      file-write xcor
      file-write ycor ]
    file-close
  ] [
    ask checkouts [
      file-write xcor
      file-write ycor ]
    file-close
  ]
end

to read-readers-xy [ fxy p ]
  if file-exists? fxy [
    file-open fxy
    ifelse p = "rd" [
    while [ not file-at-end? ] [
      create-readers 1 [
        set color green ; means idle state 'red' is active
        setxy file-read file-read
        set size 3
        set cs-t 0 set cc-t 0 set ce-t 0
        set TM-time 0 set LM-time 0
        set TM? false
        set LM? false
        set contention? false
        set collide? false
        set num-of-collisions 0
        set frame 0
        set truck-being-served nobody
        set pallet-being-served nobody
        set next-completion-time 0
        set reader-gain-tx-rx 5 ; 7dBi
        ;;
        set reader-power-tx transmitter-power ;0.8 ; 800 mW, or, 29 dBm
        set reader-frequency (865700000) ; center frequency of Ch1
        set reader-read-error 0
        set reader-outage-count 0
        set reader_height_1_tx_rx (height_tx_rx)
        set even-frame? false
        set cycle 0
        set tag-selection-filter 0 ; [0..num-tag-groups]
        ;;
        set inclination_angle_1_tx_rx incli_tx_rx
        set reader-sensitivity (10 ^ (reader-sensitivity-g / 10) ) / 1000
        set interf-from-neighbors_TM-linear 0
        set queue-r (list )
      ] ;create
    ] ; while
    ] [
      while [ not file-at-end? ] [
        create-checkouts 1 [
          set color green ; means idle state 'red' is active
          setxy file-read file-read
          ;set shape "dot"
          set size 3
          set cs-t 0 set cc-t 0 set ce-t 0
          set TM-time 0 set LM-time 0
          set TM? false
          set LM? false
          set contention? false
          set collide? false
          set num-of-collisions 0
          set frame 0
          set chart-being-served nobody
          set next-completion-time 0
          set checkout-gain-tx-rx 5 ; 7dBi
          set checkout-power-tx 0.8 ; 800 mW, or, 29 dBm
          set checkout-frequency (865700000) ; center frequency of Ch1
          set checkout-read-error 0
          set reader-outage-count 0
          set checkout-height_1_tx height_1_tx; _1 even frame
          set checkout-height_1_rx height_1_rx
          set checkout-height_2_tx height_2_tx ; _2 odd frame
          set checkout-height_2_rx height_2_rx
          set inclination_angle_1_tx incli_1tx
          set inclination_angle_1_rx incli_1rx
          set inclination_angle_2_tx incli_2tx
          set inclination_angle_2_rx incli_2rx
          set even-frame? false
          set checkout-sensitivity (10 ^ (reader-sensitivity-g / 10)) / 1000 ;0.1E-10; -80 ;dBm
          set checkout-read-error 0
          set delta 1
        ] ; create
      ] ;while
    ]

    file-close
  ]
end


to-report random-tween-uniform [ a b ]
     report ( a + random (b - a + 1) )
end

to-report random-tween [ a b ]
     report a + random-float (b - a)
end

to-report frequency [ i lst ]
  report length filter [? -> ? = i] lst
end



;to check-queue-length-and-write
;  ;let len length queue
;  ;if ticks >= (150 * num-of-queue-samples) and (num-of-queue-samples <= 100) [ ; this is for max num iterations of 15000
;  ; a max of 100 samples taken 100 ticks by 100 ticks
;  if ticks >= (100 * num-of-queue-samples) and (num-of-queue-samples <= 100) [ ; this is for max num iterations of 10000
;    ; if each 500 then <= 50; it depends of the max-num-of-iterations this example are 25000
;    let len length queue
;    let pallets-in-queue ( sum map [i -> [total-pallets] of i ] queue ) ; total pallets in queue
;    let tags-in-queue ( sum map [ i -> sum [ [ num-tags-in-pallet ] of pallets-in-truck ] of i ] queue ) ; total tags in queue
;    set queue-length lput (list ticks len pallets-in-queue tags-in-queue ) queue-length
;    set num-of-queue-samples (num-of-queue-samples + 1)
;  ]
;end
;
;to write-queue-file [ f-queue ]
;  if file-exists? f-queue [ file-delete f-queue ]
;  file-open f-queue
;  foreach range ( length queue-length ) [ ? ->
;    file-write ( first item ?  queue-length ) ;the time ticks
;    file-write ( item 1 item ?  queue-length ) ; the length of the queue
;    file-write ( item 2 item ?  queue-length ) ; total pallets in queue
;    file-write ( last item ? queue-length ) ; total tags in queue
;    file-print ""
;  ]
;  file-close
;end


to check-known-samples-and-write
  if ticks >= (25 * num-known-samples) and (num-known-samples <= 20000) [ ; this is for max num iterations of 15000
    write-known-tags-ratio
    set num-known-samples ( num-known-samples + 1 )
  ]
end

;; Sets up anonymous procedures for event queue
to setup-tasks
  set end-run-task [[?ignore] -> end-run]
  ; new
  set arrive-task [[?ignore] -> arrive-chart] ; change 'arrive' to 'arrive-chart' (in each call does 'arrive-task nobody' to create a truck)
  ;
  set start-LM-task [[?reader] -> start-LM ?reader]
  set start-TM-task [[?reader] -> start-TM ?reader]
  set complete-service-task [[?reader] -> complete-service ?reader]
  ;set departure-task [[?ignore] -> departure]
  ;new:
  set complete-service-task-chk [[?checkout] -> complete-service-chk ?checkout]
  ;
  set lookup-task [[?supervisor] -> lookup ?supervisor]
  set reorganization-task [[?ignore] -> reorganization]
  ;set reset-stats-task [[?ignore] -> reset-stats]
  set replenish-task [[?ignore] -> replenish-stands]
end

to go
  set total-inventory-cycles min [ cycle ] of readers
  let condition? ifelse-value stop-by-cycles? [total-inventory-cycles < 400][total-lookups < max-lookups]
  ;ifelse ticks < 5000 [ ;and ( length queue <= 1000) [
  ; ifelse total-inventory-cycles <= max-inventory-cycles [
  ifelse condition? [
    ;check-queue-length-and-write
    check-known-samples-and-write
    ;
    let next-event []
    let event-queue (list (list max-run-time end-run-task nobody)) ; ---OJO do not coment this lline
    ;[[500000 (anonymous command from: procedure SETUP-TASKS: [end-run]) nobody]]
    let next-reader-to-complete next-reader-complete ; reader with min of next-completion-time
    ;show next-reader-to-complete
    ;;;-- All arrivals are in setup proc. No need to schedule more but not in checkouts
    set event-queue (
      fput (list next-arrival-time arrive-task nobody) event-queue )
    ;
    ;;; -- Next the GO of checkouts:
    let next-checkout-to-complete next-checkout-complete
    if (is-turtle? next-checkout-to-complete) [ ; la primera vez no pq es 'nobody'
      set event-queue (fput
        (list
          ([next-completion-time] of next-checkout-to-complete)
          complete-service-task-chk
          next-checkout-to-complete)
        event-queue)
    ]
    let next-checkout-to-start-LM next-checkout-LM
    if (is-turtle? next-checkout-to-start-LM) [
      set event-queue (fput
        (list
          ([next-start-LM-time] of next-checkout-to-start-LM)
          start-LM-task
          next-checkout-to-start-LM)
        event-queue)
    ]
    let next-checkout-to-start-TM next-checkout-TM
    if (is-turtle? next-checkout-to-start-TM) [
      set event-queue (fput
        (list
          ([next-start-TM-time] of next-checkout-to-start-TM)
          start-TM-task
          next-checkout-to-start-TM)
        event-queue)
    ]
    ;;;--
    ;;;-- All arrivals are in setup proc. No need to schedule more
    ;set event-queue (
    ;  fput (list next-arrival-time arrive-task nobody) event-queue )
    ; -- Schedule a departure

    ;;;--
    ; show event-queue
    ; [[0.2196804243547807 (anonymous command from: procedure SETUP-TASKS: [arrive]) nobody] [500000 (anonymous......
    if (is-turtle? next-reader-to-complete) [ ; la primera vez no pq es 'nobody'
      set event-queue (fput
        (list
          ([next-completion-time] of next-reader-to-complete)
          complete-service-task
          next-reader-to-complete)
        event-queue)
    ]
    ;;;;
    let next-reader-to-start-LM next-reader-LM
    if (is-turtle? next-reader-to-start-LM) [
      set event-queue (fput
        (list
          ([next-start-LM-time] of next-reader-to-start-LM)
          start-LM-task
          next-reader-to-start-LM)
        event-queue)
    ]
    let next-reader-to-start-TM next-reader-TM
    if (is-turtle? next-reader-to-start-TM) [
      set event-queue (fput
        (list
          ([next-start-TM-time] of next-reader-to-start-TM)
          start-TM-task
          next-reader-to-start-TM)
        event-queue)
    ]
    ;;;-------------
    ; set event-queue (
    ;   fput (list next-departure-time departure-task nobody) event-queue )
    ;;;-------------
    set event-queue (
       fput (list next-replenish-time replenish-task nobody) event-queue )
    ;
    ;;;
    if swap-pallets? and (num-readers > 1) [
      set event-queue (
         fput (list next-reorganization-time reorganization-task nobody) event-queue )
    ]
    ;
    let next-supervisor-to-lookup next-supervisor
    set super next-supervisor-to-lookup
;    ask next-supervisor-to-lookup [
;      if next-lookup-time < (3 * 60) [ set next-lookup-time ( next-lookup-time + 180 + random-float 30 ) ]
;    ]
    if (is-turtle? next-supervisor-to-lookup)  [
      set event-queue (fput
        (list
          ([next-lookup-time] of next-supervisor-to-lookup)
          lookup-task
          next-supervisor-to-lookup)
        event-queue)
    ]
    ;show event-queue
;    if not empty? event-queue [
;      set event-queue (sort-by [[?1 ?2] -> first ?1 < first ?2] event-queue)
;      ; show event-queue
;      set next-event (first event-queue)
;      update-usage-stats (first next-event) ; the time of the next event;
;      set next-event (but-first next-event) ; the procedure of the next event
;      ; print (word "next-event = " next-event " and Ticks = " ticks)
;      ;[(anonymous command from: procedure SETUP-TASKS: [arrive]) nobody]
;      (run (first next-event) (last next-event))
;      ;update-plots
;    ]
    if not empty? event-queue [
      set event-queue (sort-by [[?1 ?2] -> first ?1 < first ?2] event-queue)
      ; show event-queue
      set next-event (first event-queue)
      if ((first next-event) >= 0) [
      update-usage-stats (first next-event) ; the time of the next event;
      set next-event (but-first next-event) ; the procedure of the next event
      ; print (word "next-event = " next-event " and Ticks = " ticks)
      ;[(anonymous command from: procedure SETUP-TASKS: [arrive]) nobody]
      if ((first next-event) != 0) [
      ;show next-event
      ;show first next-event
      (run (first next-event) (last next-event))
        ]
      ;update-plots
      ]
    ]
  ] [
    make-final-results ; to set names to final reporters
    ;write-queue-file (queue-file)
    ;write-p-loss-file (p-loss-file)
    file-close-all
    stop
  ]
end

;; Selection of optimal frame size for a population of tags
;; See article Vales-Alonso 2014
;; "Analytical Computation of the mean number of Tag Id..."
to-report var-frame-size
  ;; using Letter Vales
  ; let tgs count my-tags with [ not inventoried? and (tag-id-group = [tag-selection-filter] of myself) ]
  ;
;  let tgs ifelse-value (is-checkout? self) [
;    count my-tags with [ not inventoried?]
;  ][
;    count my-tags with [ not inventoried? and (tag-id-group = [tag-selection-filter] of myself) ]
;  ]
  let tgs count my-tags with [ not inventoried?]
  ;; using Chen2 algorithm (Web-Tzu CHEN, 2006)
  ;let tgs max (list 2 ((frame-size - 1) * (cs / (max (list 1 ce)))) )
  ;let tgs mean-tags-per-pallet - cs
  let k 0
  ifelse tgs < 2 [ set k 1 ][
        ifelse  tgs < 4 [ set k 2 ][
          ifelse tgs < 7 [ set k 4 ][
            ifelse tgs < 12 [ set k 8 ][
              ifelse tgs < 23 [ set k 16 ][
                ifelse tgs < 45 [ set k 32 ][
                  ifelse tgs < 90 [ set k 64 ][
                    ifelse tgs < 178 [ set k 128 ][
                      ifelse tgs < 356 [ set k 256 ][
                        ifelse tgs < 711 [ set k 512 ][
                          ifelse tgs < 1421 [ set k 1024 ][
                            ifelse tgs < 2840 [ set k 2048 ][
                              ifelse tgs < 5679 [ set k 4096 ][
                                ifelse tgs < 11358 [ set k 8192 ][
                                  ifelse tgs < 22714 [ set k 2 ^ 14 ][
                                    set k 2 ^ 15 ]
      ]]]]]]]]]]]]]]
  ;print "k= " show (list count my-tags tgs k )
  ;print "n= " show (list ce frame-size ((frame-size - 1) * (cs / (max (list 1 ce))))  )
  ;show k
  report k ; the size of the frame
end

to setup-inventory-in-frame ; Q
  ifelse size-of-frame = "SFSA" [
    set frame-size 2 ^ Q ; number of timeslots
  ] [ if size-of-frame = "DFSA" [ set frame-size var-frame-size ]
  ]
    let fs frame-size
    ask my-tags with [ inventoried? = false ] [
      set my-inventory-slot random fs + 1
    ]
end

to-report my-FSA
  let reading-time 0
  set cs 0 set cc 0 set ce 0
  setup-inventory-in-frame
  while [ TM? = true ] [
    let time-of-one-frame ( one-frame-inventory reading-time )
    set reading-time (reading-time + time-of-one-frame)
    ;show reading-time
    let my-inventoried-tags my-tags with [ inventoried? ]
    ask my-inventoried-tags with [ ((ticks + reading-time) - time-of-inventory) >= max-time-of-tag-powered] [
      set inventoried? false
      ;show time-of-inventory
      set tags-loose-memory (tags-loose-memory + count (my-inventoried-tags with [ ((ticks + reading-time) - time-of-inventory) >= max-time-of-tag-powered]))
      ;print "too much time"
    ]
    ifelse ( reading-time >= max-TM ) [
      ask my-inventoried-tags with [ time-of-inventory > ( ticks + max-TM ) ] [ set inventoried? false ]
      set TM? false
      set reading-time max-TM
      ;print "max-TM = 4s reached"
    ] [
    setup-inventory-in-frame
    set cc-t (cc + cc-t)
    set cs-t (cs + cs-t)
    set ce-t (ce + ce-t)
    if TM? [ set frame frame + 1 ]
    ]
  ] ; while
  set TM? true ; need to ask in complete-service proc.<------
  set TM-time (reading-time + TM-time)
  set efficiency ifelse-value ((cs-t + cc-t + ce-t) > 0) [cs-t / (cs-t + cc-t + ce-t)][0]
  set throughput ifelse-value ((TM-time + LM-time) > 0) [cs-t / (TM-time + LM-time)][0]
  report reading-time
end



to-report one-frame-inventory [ reading-time ]
  let frame-time 0 let s 0
  set ce 0 set cs 0 set cc 0
  ;let tagson my-tags with [ (inventoried? = false) and (tag-id-group = [tag-selection-filter] of myself) ] ;show tagson
  let tagson my-tags with [ (inventoried? = false)]
;  let tagson ifelse-value (is-checkout? self) [
;    my-tags with [ (inventoried? = false) ]
;  ][
;    my-tags with [ (inventoried? = false) and (tag-id-group = [tag-selection-filter] of myself) ]
;  ]
  ;
  ifelse any? tagson [   ;show but-first range  (frame-size + 1)
    ask tagson [ set tag-outage? false ]
    ;let tagsoff (turtle-set )

    foreach but-first range ( frame-size + 1 ) [ [ ?slot ] ->
      set tagson tagson with [ tag-outage? = false ] ; not inventoried and with not outage
      ;ask tagson [ compute-power-rec-in-tag reading-time frame-time ]
      let contending-tags tagson with [ ( my-inventory-slot = ?slot ) and ( tag-outage? = false ) ]
      ;ask (tagson  with [ ( my-inventory-slot = ?slot ) ]) [ compute-power-rec-in-tag reading-time frame-time ]
      ;let contending-tags tagson with [ tag-outage? = false ]
      ifelse any? contending-tags [
        set s count contending-tags
        ask contending-tags [ compute-power-rec-in-tag reading-time frame-time ]
        ;set contending-tags (contending-tags with  [not tag-outage?] ;<<<-----OJO
      ] [set s 0 ]
      ;show (list ?slot s)

      if ?slot = 1 [

        if s = 0 [ set frame-time t1E set ce 1 ]

        if s >= 1 [
          let tags-powers (list )
          ask contending-tags with [not tag-outage?] [
            set tags-powers lput (list self compute-power-rec-in-reader ) tags-powers
          ]
          let tag-of-max-power-in-reader (compute-SNIR-prob-error tags-powers reading-time frame-time)
          set frame-time frame-time + ( account-this-slot-time contending-tags tag-of-max-power-in-reader ?slot )
        ]
      ] ; if ?slot = 1

      if ?slot > 1 [
        if s = 0 [ set frame-time (tE + frame-time) set ce ce + 1 ]

        if s >= 1 [
          let tags-powers (list )
          ask contending-tags with [not tag-outage?] [
            set tags-powers lput (list self compute-power-rec-in-reader ) tags-powers
          ]
          let tag-of-max-power-in-reader (compute-SNIR-prob-error tags-powers reading-time frame-time)
          set frame-time frame-time + ( account-this-slot-time contending-tags tag-of-max-power-in-reader ?slot )
        ]

      ] ; if ?slot > 1

      if s = 1 and any? contending-tags with [not inventoried?] [
        set tag-unique-with-errors tag-unique-with-errors + 1
        ;print " Unique with errors"
      ]
      ifelse (s > 1) and (any? contending-tags with [inventoried? and not tag-outage? ]) [
        set tag-with-interf-decod-well ( tag-with-interf-decod-well + 1 )
        ;print "1 from a froup decod. with Success"
      ] [
        set tag-with-interf-decod-bad ( tag-with-interf-decod-bad + 1 )
        ;print "more than 1 and Error"
      ]

    ] ; foreach

  ] [
    ;foreach but-first range ( frame-size + 1 ) [ [ ?slot ] ->
    foreach but-first range ( 4 + 1 ) [ [ ?slot ] ->
      if ?slot = 1 [ set frame-time t1E set ce 1 ]
      if ?slot > 1 [ set frame-time (tE + frame-time) set ce (ce + 1) ]
      set TM? false ; commented because the only condition to stop is 'T'
    ]
  ]
  ;show frame-time
  ifelse even-frame? [ set even-frame? false ] [ set even-frame? true ]
  report frame-time
end

to-report account-this-slot-time [ ctnd-tags tag-of-max-power-rx slot ]
  ;print " tags-and-powers " show tags-and-powers
  let time-of-slot 0
  ifelse (all? ctnd-tags [ tag-outage? ]) [
    ifelse (slot = 1) [ set time-of-slot t1E ] [ set time-of-slot tE ]
    set ce (ce + 1)
  ] [
    ifelse not is-agent? tag-of-max-power-rx [
      ifelse (slot = 1) [ set time-of-slot t1E ] [ set time-of-slot tE ]
    ] [
      ifelse ([ inventoried? ] of tag-of-max-power-rx ) [
        ifelse (slot = 1) [ set time-of-slot t1S ] [ set time-of-slot tS ]
        set cs (cs + 1)
      ] [
        ifelse (slot = 1) [ set time-of-slot t1C ] [ set time-of-slot tC ]
        set cc (cc + 1)
      ]
    ]
  ]

  report time-of-slot
end

to-report compute-reader-gain-tx [ this-tag ]
  let alpha 45 let phi 45
  ask this-tag [
      set alpha alpha_1_fw_bw
      set phi azimuthal_angle_1_fw_bw
  ] ; ask
  ;;
  ;show (list alpha phi [(list tag-x tag-y tag-z)] of this-tag)
  ;show (word "reader-gain= " (3.136 * ( (tan alpha) * (sin ( 90 * (cos alpha) * (sin phi) ) ) ) ^ 2))
  report 3.136 * ( (tan alpha) * (sin ( 90 * (cos alpha) * (sin phi) ) ) ) ^ 2
end


; this a tags context procedure
; used to compute tag-power-rx of all tagson with tag-outage? false
; Note: "the outages" I can read with two readers both sides of the gate because I do not know the number of tags in pallet
; or I could put a new variable in the tag to indicate that the tag has have already an outage then put the tag as inventaried to pass the reding but
; register how many tags has have outage.
to compute-power-rec-in-tag [ reading-time frame-time ]
  ;let freq [ reader-frequency ] of myself
  let freq ifelse-value in-chart? [[ checkout-frequency ] of myself] [[ reader-frequency ] of myself]
  ;let D ( tag-x + ( [ pallet-distance ] of ( [ pallet-being-served ] of myself ) ) )
  let D 2 let distance-to-r 2.5
  if in-chart? [
    let current-r-height 1.5 ;let D 2 let distance-to-r 2.5
    ifelse [ even-frame? ] of myself [
      set current-r-height ([ checkout-height_1_tx ] of myself )
      set D D_1
      set distance-to-r  distance-to-checkout_1_fw
    ] [
      set current-r-height ([ checkout-height_2_tx ] of myself )
      set D D_2
      set distance-to-r  distance-to-checkout_2_fw
    ]
  ]
;
;  ; let H ( sqrt( 1 - (4 * ([ reader-height ] of myself ) * tag-y ) / ( (D ^ 2) + (( ([ reader-height ] of myself ) + tag-y ) ) ^ 2) ) )
;  ; let theta 2 * pi / (c / freq ) * ( sqrt( ( (D ^ 2) + (( ([ reader-height ] of myself ) + tag-y ) ) ^ 2 ) - sqrt( ( (D ^ 2) + (( ([ reader-height ] of myself ) - tag-y ) ) ^ 2) ) ) )
;  let H ( sqrt( 1 - (4 * current-r-height * tag-y ) / ( (D ^ 2) + (( current-r-height + tag-y ) ) ^ 2) ) )
;  let theta 2 * pi / (c / freq ) * ( sqrt( ( (D ^ 2) + (( current-r-height + tag-y ) ) ^ 2 ) - sqrt( ( (D ^ 2) + (( current-r-height - tag-y ) ) ^ 2) ) ) )
;  set q_e  ( (H ^ 2) * ( sin (theta * radians-to-degrees) ) ^ 2 ) + (( 1 - H * cos (theta * radians-to-degrees) ) ^ 2) ;show (list H theta q_e)
  set q_e_rcn_fw ( compute-rician-fading ( sqrt 3 ) ( 1 / sqrt 2 ) )
  ; SHADOWING parameter
  set shadow_fw ( 10 ^ (-1 * ( random-normal 0 sigma ) / 10 ) )
  ;;
  ;
  let this-tag self
  ifelse (is-checkout? myself) [
    ask myself [ set checkout-gain-tx-rx ( compute-reader-gain-tx this-tag ) ]
  ][
    ask myself [ set reader-gain-tx-rx ( compute-reader-gain-tx this-tag ) ]
  ]
  ;
  ;;-----Rician only-------
  let tag-power-rx-linear 0
  ifelse in-chart? [
     set tag-power-rx-linear ( ([ checkout-power-tx * checkout-gain-tx-rx * ((c / checkout-frequency) ^ 2) ] of myself ) * tag-gain * polarz-mismatch * pow-tx-coefficient )  /
      (( ( 4 * pi * distance-to-r ) ^ 2) * on-object-gain-penalty * path-blockages * fading-factor-fw ) * ( q_e_rcn_fw * shadow_fw )
  ] [
    set tag-power-rx-linear ( ([ reader-power-tx * reader-gain-tx-rx * ((c / reader-frequency) ^ 2) ] of myself ) * tag-gain * polarz-mismatch * pow-tx-coefficient )  /
      (( ( 4 * pi * distance-to-reader ) ^ 2) * on-object-gain-penalty * path-blockages * fading-factor-fw ) * ( q_e_rcn_fw * shadow_fw )
  ]
  ;let tag-power-rx-linear ( ([ reader-power-tx * reader-gain-tx-rx * ((c / reader-frequency) ^ 2) ] of myself ) * tag-gain * polarz-mismatch * pow-tx-coefficient )  /
  ;   (( ( 4 * pi * distance-to-reader ) ^ 2) * on-object-gain-penalty * path-blockages * fading-factor-fw ) * ( q_e_rcn_fw * shadow_fw )
  ;;
  ;show (list tag-power-rx-linear fading-factor-fw q_e_rcn_fw  shadow_fw)
  ;print (word "distance to reader: " distance-to-reader)
  set tag-power-rx (ifelse-value (tag-power-rx-linear > 0) [ ( 10 * log (1000 * tag-power-rx-linear) 10 ) ] [ -100 ])
  ;show tag-power-rx
  ifelse ( tag-power-rx < tag-sensitivity ) [
    set tag-outage? true
    ;print "outage"
    ifelse outage-count-of-this-tag < max-num-of-outages [
      set outage-count-of-this-tag (outage-count-of-this-tag + 1)
      ;show outage-count-of-this-tag
      set tags-with-one-outage ( tags-with-one-outage + 1) ; this is global var
    ] [
      ;show outage-count-of-this-tag ;print " invent with outage"
      set inventoried? true
      ; set time-of-inventory random-tween (ticks + reading-time) (ticks + reading-time + frame-time)
      set time-of-inventory (ticks + reading-time + frame-time)
      set tags-with-two-outage ( tags-with-two-outage + 1) ; this is global var
    ]
  ] [ if tag-outage? [ set tag-outage? not tag-outage? ] ] ; or simply set tag-outage? false
end

; tag context procedure
to-report compute-power-rec-in-reader
  let D 2 let distance-to-r 2.5 let distance-to-r_f 2.5
  if in-chart? [
    let current-r-height 1.5 ;let D 2 let distance-to-r 2.5 let distance-to-r_f 2.5
    ifelse [ even-frame? ] of myself [
      set current-r-height ([ checkout-height_1_rx ] of myself )
      set D D_2
      set distance-to-r  distance-to-checkout_1_bw
      set distance-to-r_f distance-to-checkout_1_fw
    ] [
      set current-r-height ([ checkout-height_2_rx ] of myself )
      set D D_1
      set distance-to-r  distance-to-checkout_2_bw
      set distance-to-r_f distance-to-checkout_2_fw
    ]
  ]
  ;;
  let shadow_bw ( 10 ^ (-1 * ( random-normal 0 (sigma ) ) / 10 ) )
  let q_e_rcn_bw ( compute-rician-fading ( sqrt 3 ) ( 1 / sqrt 2 ) )
  ; use of fading-factor-bw because Monostatic is assumed
  ;let reader-power-rx-linear ( ([ reader-power-tx * (reader-gain-tx-rx ^ 2) * (c / reader-frequency) ^ 4 ] of myself ) * (tag-gain ^ 2) * (polarz-mismatch ^ 2) * modulation-factor ) /
  ;  ( ( 4 * pi * distance-to-reader ) ^ 4 * ( on-object-gain-penalty ^ 2) * (path-blockages ^ 2) * fading-factor-bw-a ) * ( ( q_e_rcn_fw * q_e_rcn_bw ) * shadow_fw * shadow_bw ) ; loss-by-rician-fading-fw * loss-by-rician-fading-bw
  ;show (list shadow_bw reader-power-rx-linear (10 * log (1000 * reader-power-rx-linear) 10) )
  let reader-power-rx-linear 0
  let checkout-power-rx-linear 0
  ifelse in-chart? [
    set checkout-power-rx-linear ( ([ checkout-power-tx * (checkout-gain-tx-rx ^ 2) * (c / checkout-frequency) ^ 4 ] of myself ) * (tag-gain ^ 2) * (polarz-mismatch ^ 2) * modulation-factor ) /
    ( ( 4 * pi ) ^ 4 * (distance-to-r_f ^ 2)* (distance-to-r ^ 2) * ( on-object-gain-penalty ^ 2) * (path-blockages ^ 2) * fading-factor-bw ) * ( ( q_e_rcn_fw * q_e_rcn_bw ) * shadow_fw * shadow_bw ) ; loss-by-rician-fading-fw * loss-by-rician-fading-bw
    ask myself [ set checkout-power-rx ifelse-value (checkout-power-rx-linear > 0) [ 10 * log (1000 * checkout-power-rx-linear) 10 ][-1000]  ]
  ] [
    set reader-power-rx-linear ( ([ reader-power-tx * (reader-gain-tx-rx ^ 2) * (c / reader-frequency) ^ 4 ] of myself ) * (tag-gain ^ 2) * (polarz-mismatch ^ 2) * modulation-factor ) /
      ( ( 4 * pi * distance-to-reader ) ^ 4 * ( on-object-gain-penalty ^ 2) * (path-blockages ^ 2) * fading-factor-bw-a ) * ( ( q_e_rcn_fw * q_e_rcn_bw ) * shadow_fw * shadow_bw ) ; loss-by-rician-fading-fw * loss-by-rician-fading-bw
    ask myself [ set reader-power-rx ifelse-value (reader-power-rx-linear > 0) [ 10 * log (1000 * reader-power-rx-linear) 10 ][-1000] ]
  ]

  ;set reader-power-rx-linear ((10 ^ (-0.6)) / 1000 )
; ask myself [
;    set reader-power-rx ifelse-value (reader-power-rx-linear > 0) [( 10 * log (1000 * reader-power-rx-linear) 10 )][-1000]
;  ]
  report ifelse-value in-chart? [checkout-power-rx-linear][reader-power-rx-linear]
end

; reader context
to-report compute-SNIR-prob-error [ tags-powers reading-time frame-time ]
  let sstvt 0
  ifelse is-checkout? self [ set sstvt checkout-sensitivity ] [ set sstvt reader-sensitivity ]
  ;if not empty? ( filter [ p -> last p < reader-sensitivity ] tags-powers ) [ set reader-outage-count reader-outage-count + 1 ]
  if not empty? ( filter [ p -> last p < sstvt ] tags-powers ) [ set reader-outage-count reader-outage-count + 1 ]
  ;set tags-powers ( filter [ p -> last p >= reader-sensitivity ] tags-powers )
  set tags-powers ( filter [ p -> last p >= sstvt ] tags-powers )
  let tag-of-max-power nobody
  ;let tags-powers-interference (list ) let powers-interference (list )
  ;let tag-of-max-power nobody
  ;print "1 t" show tags-powers
  if not empty? tags-powers [
    set tags-powers sort-by [ [ ?1 ?2 ] -> item 1 ?1 > item 1 ?2 ] tags-powers
    ;set tags-powers-ordered tags-powers
    ;print "2 t" show tags-powers
    set tag-of-max-power first first tags-powers
    let max-power last ( first tags-powers )
    let N_dBm -97.3210263056549 ;-116.87
    ;let N_dBm -116.87
    let N_linear ((10 ^ (N_dBm / 10)) / 1000) ;B=200E3, 3.6MHz
    ; let SNR ( ( 10 * log (1000 * max-power) 10 ) - ( noise-figure_dB + (10 * (log max-rx-BW 10 ) ) + noise-density_dBm_Hz ) )
    ; let SNR_linear (10 ^ (SNR / 10))
    let SNR_linear (max-power / N_linear)
    let SNIR SNR_linear


    ;let CIR ifelse-value (interf-from-neighbors_TM-linear > 0) [ max-power / (interf-from-neighbors_TM-linear / ACPR_linear)] [max-power]
    let CIR ifelse-value (interf-from-neighbors_TM-linear > 0) [ max-power / (interf-from-neighbors_TM-linear / ACPR_linear)] [0]
    ;;
    ;let tags-powers-interference (list ) let powers-interference (list )
    if length tags-powers > 1 [
      let tags-powers-interference but-first tags-powers
      let powers-interference map [ p -> last p ] tags-powers-interference
      set CIR ifelse-value (sum powers-interference > 0) [( max-power / ( sum powers-interference + (interf-from-neighbors_TM-linear / ACPR_linear) ) ) ] [CIR]

    ]
    ;set SNIR ifelse-value (max-power > 0 ) [ ( 1 / ( ( 1 / SNR_linear) + (1 / CIR ) ) ) ] [ 0 ]
    set SNIR ifelse-value (max-power > 0 ) [ ( 1 / ( ( 1 / SNR_linear) + (ifelse-value CIR > 0 [(1 / CIR )][ 0 ])     ) ) ] [ 0 ]
    ;
    ;show tag-of-max-power
    ;show (word "[maxPow,mPdBm]= " (list max-power (10 * log (1000 * max-power) 10)) " , [SNR_lin,SNR_dB]= " (list SNR_linear (10 * log (1 * SNR_linear) 10)) " , CIR= " CIR ", [SNIR, SNIR_dB]= " (list SNIR (10 * log SNIR 10)) )

    let BER (1 + rician-factor) / ( 2 + 2 * rician-factor + SNIR ) * exp (-3 * SNIR / ( 2 + rician-factor + SNIR ) ) ;print "BER=" show BER
    ;let M 8
    ;let BER ifelse-value SNIR > 0 [1 / (2 * M * SNIR)][1]
    ;let prob-error 0; ( 1 - ( 1 - BER) ^ 6)
    let prob-error ( 1 - ( 1 - BER) ^ 40)
    ;; Now differenciate between checkouts and continuous
    ;; checkouts
    ifelse is-checkout? self [
      ifelse prob-error <= random-float 1  [ ;and  length tags-powers = 1
      ask tag-of-max-power [
        ;print "inventoried"
        set inventoried? true
        ;set tag-outage? false
        set time-of-inventory random-tween (ticks + reading-time) (ticks + reading-time + frame-time)
      ]
      ] [ set checkout-read-error (checkout-read-error + 1) ]
    ] [ ; continuous
      ifelse prob-error <= random-float 1  [ ;and  length tags-powers = 1
        ask tag-of-max-power [
          ;print "inventoried"
          set inventoried? true
          set tag-round-not-located 0
          ; set time-of-inventory random-tween (ticks + reading-time) (ticks + reading-time + frame-time)
          set time-of-inventory (ticks + reading-time + frame-time)
          if not inventoried-first? [
            set inventoried-first? true
;            if time-samples-count <= 100000 [
;              ;show (list time-of-inventory time-entered-service (time-of-inventory - time-entered-service) )
;              file-open time-id-first-file
;              file-write (time-of-inventory - time-entered-service) file-print ""
;              file-close
;              set time-samples-count (time-samples-count + 1)
;            ] ;if
          ] ; if not inventoried-first
        ];ask tag-of-max-power
      ] [ ;error of reading
          set reader-read-error (reader-read-error + 1)
      ]
    ] ;continuous
    ;;

  ]
  report tag-of-max-power
end

; this is the function to compute a realization of the rician pdf
; parameter s: s^2 is the LOS energy received
; parameter sgm: 2*sgm^2 is the NLOS energy received
; => K = 3
to-report compute-rician-fading [ s sgm ]
  let x ( random-normal 0 1 )  + s
  let y ( random-normal 0 1 )
  report sqrt( (x ^ 2 ) + ( y ^ 2 ) )
end

;; Samples from the exponential distribution to schedule the time of the next
;; truck arrival in the system.
to schedule-arrival
  set next-arrival-time (ticks + random-exponential (1 / mean-arrival-rate))
end

to schedule-departure
  set next-departure-time (ticks + random-exponential (1 / mean-departure-rate))
end

to schedule-lookup
  set next-lookup-time (ticks + random-exponential (1 / mean-lookup-rate))
  if next-lookup-time < (3 * 60) [ set next-lookup-time ( next-lookup-time + 180 + random-float 30 ) ]
end

to schedule-reorganization
  set next-reorganization-time (ticks + random-exponential (1 / mean-reorganization-rate))
end

to schedule-replenish
  set next-replenish-time ticks + time-between-inventories ;(ticks + random-exponential (1 / mean-reorganization-rate))
end


;;
;; reorganize pallets exchanging between TWO random readers
; is an observer procedure
to reorganization
  ;print "I am SWAPPING"
  ;print (word "total tags before swap = " count tags)
  let num-changes-in-reorg (random (num-pallets-by-side ^ 2 - 1) + 1) ; the num of pallets to change
  ;let i 1
  repeat num-changes-in-reorg [
    ;print (word "i = " i) set i (i + 1)
    let p1 nobody let p2 nobody let t1 nobody let t2 nobody
    let my-pallets n-of 2 pallets; with [ is-agentset? tags-in-pallet ]
    ;print (word "my-pallets = "  [who] of my-pallets)
    ask one-of my-pallets [
      set p1 self
      set p2 other my-pallets
      ;print (word "p1= " p1 ", p2= " p2)
      set t1 [tags-in-pallet] of p1
      set t2 (turtle-set [tags-in-pallet] of p2)
      ;print (word "t1= " t1 ", t2= " t2)
      ask (turtle-set t1 t2) [
        set inventoried-first? false
        set inventoried? false
        set tag-round-not-located 0
      ]
    ]
    ask p1 [ set tags-in-pallet t2 ]
    ask p2 [ set tags-in-pallet t1 ]
    ;print "my-tags = "
    ask readers [
      set my-tags (turtle-set [ tags-in-pallet ] of pallet-being-served)
      ;print (word "reader " [who] of self ", my-tags = " my-tags)
    ]
  ] ; repeat
  ;print (word "total tags after swap = " count tags)
  set total-swaps (total-swaps + 1)
  schedule-reorganization
end

;;
; is an observer procedure
to departure
  ; generate an order of pallets
  ; 20% max of whadrehouse capacity
  ; print "ESTOY EN DEPARTURE :-) " ;-----
  ; print (word "total tags before departure = " count tags)
  ; let order-amount ceiling (( random max-order-percent + 1 ) * warehouse-capacity / 100)
  ; it will be the number of pallets in a departure. Each departure will be each 30 minutes by meanrandom
  ;let order-amount (random-tween-uniform 10 30)
  ;let move-p-men 1
  ; The shipping rate is about 8pallets per 10 minutes (0.8p per minute)
  ;;--
  let move-p-men ceiling ( warehouse-capacity / 100 ) ;(loading (move-p-men) trucks in parallel ) "/200 BEFORE"
  ;let order-amount 8 * move-p-men ;pallets * 3 men (loading move-p-men trucks in parallel )
  let order-amount ifelse-value two-height? [8 * move-p-men] [16 * move-p-men] ;pallets * 3 men (loading move-p-men trucks in parallel )
  ;;--
  ;let order-amount ceiling min (list 33 (warehouse-capacity / 5)) ; or 13 or 33 pallets
  let pallets-with-tags (pallets with [ is-agentset? tags-in-pallet ])
  let pallets-with-tags-selected nobody
  ifelse is-agentset? pallets-with-tags and (count pallets-with-tags >= order-amount ) [
    set pallets-with-tags-selected ( n-of order-amount pallets-with-tags )
  ] [ set pallets-with-tags-selected nobody ]
  ; show [who] of pallets-with-tags-selected ;-----
  ; Next I could make an 'ask' of each pallet better e.g. if I want to control the position of each pallet in the group
  let total-tags-selected sum [ num-tags-in-pallet ] of pallets-with-tags-selected
  ; print (word "total-tags-selected = " total-tags-selected) ;-----
  ;let total-tags-singulated sum [ count tags-in-pallet with [
  ;  inventoried? and not(outage-count-of-this-tag < max-num-of-outages) ] ] of pallets-with-tags-selected
  let total-tags-singulated 0
  ask pallets-with-tags-selected [ set total-tags-singulated (count tags-in-pallet with [inventoried-first?] + total-tags-singulated) ]
  ;let total-tags-singulated sum [ count tags-in-pallet with [ inventoried-first? ] of pallets-with-tags-selected
  ; print (word "total-tags-singulated = " total-tags-singulated) ;-----
  let total-tags-not-singulated (total-tags-selected - total-tags-singulated)
  let p-loss (total-tags-not-singulated / total-tags-selected)

  ; p-loss-list has 6 items in each sub-list [[...]...] and max length 1000 sublists
;  if total-departures <= 1000 [
;    ;set p-loss-list lput (list ticks total-departures order-amount total-tags-not-singulated total-tags-singulated p-loss ) p-loss-list
;    ; I will write this list at the end of the simulation IF WORKS the other way I will change and write during simulation opening and closing
    file-open p-loss-file
    ;file-write (list ticks total-departures order-amount total-tags-not-singulated total-tags-singulated p-loss ) file-print ""
    file-write ticks file-write total-departures file-write order-amount
    file-write total-tags-not-singulated file-write total-tags-singulated file-write p-loss
    file-print ""
    file-close
;    ;print (word "Loss probability = " p-loss) ;-----
;  ]
  ask pallets-with-tags-selected [
    ask tags-in-pallet [ die ]
    set tags-in-pallet nobody
    set still-not-inventoried true
  ]
  set total-departures (total-departures + 1)
  schedule-departure
  ;
  ; Now, after departure we have less pallets and we have to check if we are below Minimum Stock Level (MSL)
  set pallets-with-tags (pallets with [ is-agentset? tags-in-pallet ])
  ; print (word "total pallets with tags after departure = " (count pallets-with-tags) " and, Stock_Limit = " (warehouse-capacity * minimum-stock-level / 100)) ;-----
  let below-stock? ( count pallets-with-tags < warehouse-capacity * minimum-stock-level  / 100 )
  if below-stock? [
    set moments-of-arrivals ( moments-of-arrivals + 1 )
    ; we must backorder to restablish full warehouse capacity
    ; consist in put new tags in the pallets with no tags
    ; let empty-pallets pallets with [ not is-agentset? tags-in-pallet ]
    ;setup-tags ( pallets with [ not is-agentset? tags-in-pallet ] ) nobody
    let readers-with-empty-pallets (readers with [ any? pallet-being-served with [not is-agentset? tags-in-pallet] ])
    set total-p-arrivals ( total-p-arrivals + count ( pallets with [ not is-agentset? tags-in-pallet] ) )
    ; print "BELOW-STOCK : "
    ; print (word "pallets empty = " (pallets with [not is-agentset? tags-in-pallet]) ", " "readers with empty = " readers-with-empty-pallets) ;-----
    if any? readers-with-empty-pallets [
      ask readers-with-empty-pallets [
        let new-tags ( setup-tags ( pallet-being-served with [not is-agentset? tags-in-pallet] )  nobody ) ;( truck-being-served )
        set my-tags (turtle-set [ tags-in-pallet ] of pallet-being-served)
        ;let new-tags my-tags with [not inventoried-first?]
        ask new-tags [
          set time-entered-service ticks
        ] ;<<--we should measure some parameters
        set total-queue-throughput (total-queue-throughput + (count new-tags))
        ; move ahead the completion time for the new incoming tags
        if ticks < next-completion-time [
          let k my-FSA
          set next-completion-time ( ticks + k + empty-frames-TM )
        ]
      ] ; ask

    ] ; if any?


  ]
  ;
  ; print (word "total tags after departure = " count tags)
end

to lookup [ ?supervisor ]
  if any? tags [
    let product one-of tags
    let error? 0
    ask ?supervisor [ set product-searched  product ] ; exist in the warehouse
    ifelse [ inventoried-first? ] of product [
      ; means is already located
      ask ?supervisor [ set cf cf + 1 ]
      set error? 0
    ] [
      ; means not located
      ask ?supervisor [ set cnf cnf + 1 ]
      set total-lookup-errors ( total-lookup-errors + 1 )
      set error? 1
      ; tag-round-not-located must be put to 0 if inventoried-first?
    ]
    set total-lookups ( total-lookups + 1 )
    file-open lookup-file
    file-write error? file-write ticks file-write ([who] of ?supervisor) file-write ([tag-x] of product) file-write ([tag-y] of product) file-write ([tag-z] of product)
    file-write ([distance-to-reader] of product) file-write total-lookups file-write total-lookup-errors file-write diameter-x file-write diameter-y
    file-write ceiling-to-floor-distance file-print ""
    file-close
  ]
  ask ?supervisor [ schedule-lookup ]
end

;; Generates the random number of pallets per truck
;; and tags per pallet
to-report generate-number [ s ]
  report ifelse-value (s = "tags") [
    ;max (list 1 random-poisson mean-tags-per-pallet)
    ;random-tween-uniform 100 1000
    ;50
    min (list 200 max (list 1 random-poisson exp random-normal 2.32 1.29 ) )
  ] [
    ;max (list 1 random-poisson mean-pallets-per-truck)
    1
  ]
end

;; Creates a new truck agent, adds it to the queue, and attempts to start
;; service. We create a truck with pallets and the tags on each pallet.
to arrive-chart
;  let current-truck nobody
;  create-trucks 1 [
;    set color brown
;    set current-truck self
;    set queue (lput self queue)
;    set time-entered-queue ticks
;    set total-pallets generate-number "pallets"
;    set shape "truck"
;    set size 2
;    set hidden? true
;    ;
;    set total-offered-load-of-pallets ( total-offered-load-of-pallets + total-pallets )
;  ]
;  let pallets-of-this-truck []
  let total-charts 1
  set total-offered-load-of-charts ( total-offered-load-of-charts + total-charts )
  let base-point (portal-width / 2)
  create-charts 1  [
    set num-tags-in-chart generate-number "tags"
    ;if num-tags-in-pallet > 200 [print num-tags-in-pallet ]
    ;set pallets-of-this-truck (lput self pallets-of-this-truck)
    set chart-distance base-point + (random-tween -0.15 0.15 )
    ;set pallet-distance 2
    set hidden? true
    set shape "fish"
    set size 2
    set time-entered-queue ticks
	  set still-not-inventoried true
    set queue-chk (lput self queue-chk)
    ;
    set total-offered-load-of-tags ( total-offered-load-of-tags + num-tags-in-chart )
  ]
;  ask current-truck [
;    set pallets-in-truck (turtle-set pallets-of-this-truck)
;    set total-pallets count pallets-in-truck
;  ]
;  foreach pallets-of-this-truck [ [pallet?] ->
;    let list-of-tags []
;    create-tags ([num-tags-in-pallet] of pallet?) [
;      set list-of-tags (lput self list-of-tags)
;      set inventoried? false
;      set time-entered-queue ticks
;      set hidden? true
;    ]
;    ask pallet? [ set tags-in-pallet (turtle-set list-of-tags) ]
;  ]
  set arrival-count (arrival-count + 1)
  schedule-arrival
  begin-service-chk
end


;; Creates a new truck agent, adds it to the queue, and attempts to start
;; service. We create a truck with pallets and the tags on each pallet.
to arrive [r?]
  let current-truck nobody
  create-trucks 1 [
    set color brown
    set current-truck self
    ;set queue (lput self queue)
    let l self
    ask r? [set queue-r (lput l queue-r)]
    set time-entered-queue ticks
    ;set total-pallets generate-number "pallets"
    set total-pallets ( num-pallets-by-side * num-pallets-by-side )
    ; set shape "truck"
    set shape "box"
    set size 2
    set hidden? true
  ]
  let pallets-of-this-truck []
  ;let base-point (portal-width / 2)
  let coords-pallets (list )
  let thr-min 0 let thr-max 0
  let lx-pallets (list ) let ly-pallets (list )
  ; num-pallets-by-side is ODD?
  if ( num-pallets-by-side mod 2 != 0 ) [
    set thr-min floor ( num-pallets-by-side / 2 )
    set thr-max ceiling ( num-pallets-by-side / 2 )
    set lx-pallets map [i -> precision i 1](range (-1 * p-width * thr-min) (p-width * thr-max) p-width)
    set ly-pallets map [i -> precision i 1](range (-1 * p-depth * thr-min) (p-depth * thr-max) p-depth)
  ]
  if ( num-pallets-by-side mod 2 = 0 ) [
    set thr-min floor ( (num-pallets-by-side - 1) / 2 )
    set thr-max ceiling ( (num-pallets-by-side + 1) / 2 )
    set lx-pallets map [i -> precision (i - p-width / 2) 1](range (-1 * p-width * thr-min) (p-width * thr-max) p-width)
    set ly-pallets map [i -> precision (i - p-depth / 2) 1](range (-1 * p-depth * thr-min) (p-depth * thr-max) p-depth)
  ]
  ;print (word "min-max-lx-pallets = " ( list min lx-pallets max lx-pallets ) )
  ;print (word "min-max-ly-pallets = " ( list min ly-pallets max ly-pallets ) )
  set diameter-x precision ((max lx-pallets + ( p-width / 2 )) * 2) 2
  set diameter-y precision ((max ly-pallets + ( p-depth / 2 )) * 2) 2
  ;show ( list diameter-x diameter-y )
  foreach lx-pallets [ [a] -> foreach ly-pallets [ [b] -> set coords-pallets (lput (list a b) coords-pallets ) ] ]
  ;show coords-pallets
  create-pallets [ total-pallets ] of current-truck  [
    set num-tags-in-pallet mean-tags-per-pallet ;generate-number "tags"
    set pallets-of-this-truck (lput self pallets-of-this-truck)
    ; (in this case) This is the height of the ceiling where reader is intalled = 3.5m ceiling-to-floor
    ;set pallet-distance 3.5 ; base-point + (random-tween -0.4 0.4 )
    set hidden? true
	  set still-not-inventoried true
    ; next to indicate diplacement of group of pallets
    ; give a position cordinate's to each pallet as they are created
    set dx-to-center-of-reader (first (first coords-pallets)) ;0
    set dy-to-center-of-reader (last (first coords-pallets)) ;0
    set coords-pallets butfirst coords-pallets
    ;set my-truck current-truck
  ]

  ask current-truck [
    set pallets-in-truck (turtle-set pallets-of-this-truck)
    ;set total-pallets count pallets-in-truck
  ]
  ;show [(list dx-to-center-of-reader dx-to-center-of-reader who )] of [pallets-in-truck] of current-truck
  set arrival-count (arrival-count + 1)
  ;schedule-arrival
  ; if stp = '0' then next-start-LM-time = ticks + TM-to-LM-time
  ; else next-start-LM-time = ticks + TM-to-LM-time + time-between-inventories
  begin-service "0" ; 0 is stp means is the first time proc begin-service
end


;; Create the tags for each reader
;; we make this as an 'arrive' of a truck
;; This proc called at start in SETUP proc.
to setup-tags-under
  foreach sort readers [ r? ->
    ;write "arrive"
    arrive r?
  ]
;  ask readers [
;    arrive
;  ]
end



; We call this proc from begin-service() OJO--> DEPARTURE is DIFFERENT
to-report setup-tags [ ?pallet ?truck]
  foreach sort ?pallet [ [?p] ->
    let list-of-tags []
    ;ask ?p [if is-agentset? tags-in-pallet [ask tags-in-pallet [die]]]
    hatch-tags ([num-tags-in-pallet] of ?p) [
      set list-of-tags (lput self list-of-tags)
      set inventoried? false
      set time-entered-queue ticks
      ; set time-entered-queue ifelse-value is-agent? ?truck [
      ;  [time-entered-queue ] of ?truck ] [ ticks ]
      set hidden? true
      ; x total-pallets if several pallets
      ; show (list ([ dx-to-center-of-reader ] of ?p) ([ dy-to-center-of-reader ] of ?p ) )
      set tag-x (random-tween (-1 * (p-width / 2)) (p-width / 2) ) + [ dx-to-center-of-reader ] of ?p
      set tag-y (random-tween (-1 * (p-depth / 2)) (p-depth / 2) ) + [ dy-to-center-of-reader ] of ?p
      set tag-z (random-tween p-base p-height )
      ;show (word "coords= " (list tag-x tag-y tag-z ( ceiling-to-floor-distance - tag-z )  ) )
      set distance-to-reader sqrt ( ( ( tag-x ) ^ 2 + ( tag-y ) ^ 2 ) + ( ceiling-to-floor-distance - tag-z ) ^ 2 )
      ; show distance-to-reader
      ;
      set azimuthal_angle_1_fw_bw ( 90 - acos ((ceiling-to-floor-distance - tag-z) / distance-to-reader) )
      set alpha_1_fw_bw (90 + [inclination_angle_1_tx_rx] of myself - asin ( ([reader_height_1_tx_rx] of myself - tag-y ) / distance-to-reader ) )
      ;let alpha alpha_1_fw_bw     let phi azimuthal_angle_1_fw_bw
      ;show (word "alpha= " alpha "phi= " phi)
      ;show (word "reader-gain= " (3.136 * ( (tan alpha) * (sin ( 90 * (cos alpha) * (sin phi) ) ) ) ^ 2))
      ;
      set tag-sensitivity min-power-to-feed-tag-IC
      set tag-outage? false
      ;
      ;set tag-gain 1.621810097 ; 2.1 dBi
      let azit azimuthal_angle_1_fw_bw
      ;--
      ;let tag-inclination-angle-list (list (azit - 90) azit (azit + 90) (azit + 180) )
      ;set dipole_inclination_angle_fw_bw (one-of tag-inclination-angle-list )
      ;
      ;show (word "azith= " azit "(x,y)= " sqrt ((tag-x ^ 2) + (tag-y ^ 2)) )

      set dipole_inclination_angle_fw_bw ifelse-value tag-in-top? [azit][random-tween (min-tag-inclination-angle) (90)]
      ;set dipole_inclination_angle_fw_bw 90
      if dipole_inclination_angle_fw_bw = 0 or dipole_inclination_angle_fw_bw = 180 [set dipole_inclination_angle_fw_bw (dipole_inclination_angle_fw_bw + 1e-6)]
      ;--
      ;set dipole_inclination_angle_fw_bw random 45 + 46
      set tag-gain precision (1.621810097 * ((cos (90 * cos (dipole_inclination_angle_fw_bw + 1E-10)) / (sin (dipole_inclination_angle_fw_bw + 1E-10))) ^ 2))  8 ;linear value
      ;show (word "azit= " azit " , gain= " tag-gain)
      ;
      set outage-count-of-this-tag 0
      ;set time-being-inventoried-first 0
      set inventoried-first? false ; still not inventoried
      set tag-id-group (random num-tag-groups )
      set in-chart? false
    ]
    ask ?p [ set tags-in-pallet (turtle-set list-of-tags) ]
  ] ; foreach
  report (turtle-set [ tags-in-pallet ] of ?pallet)
end

; reset the tags in each cycle of the current reader
to setup-tags-change [ ?pallet ?truck]
  ask ?pallet [
    if any? tags-in-pallet [
      ask tags-in-pallet [
        set inventoried? false
        set outage-count-of-this-tag 0
        set tag-outage? false
        set in-chart? false
      ]
    ] ;if
  ]
end


;; If there are trucks in the queue, and at least one reader is idle, starts
;; service on the first truck in the queue, using a randomly selected
;; idle server.
;; -->Besides, for each pallet in the truck, generate a complete-service event with
;; a time computed making the inventory of that particular pallet
;; But first we have to plan an event time to start LM
to begin-service [ stp ]
  ;
  let available-readers (readers with [(not is-agent? truck-being-served) ]); or (not is-agent? pallet-being-served) ])
  ;if (not empty? queue and any? available-readers) [ ; OJO
  if (any? available-readers with [not empty? queue-r]) [ ; OJO
    let next-reader nobody let next-truck nobody
    ask one-of available-readers with [not empty? queue-r] [
      set next-reader self
      set next-truck first queue-r
      set queue-r (but-first queue-r)
    ]


    ;set queue (but-first queue)
    ask next-truck [
      move-to next-reader
      set hidden? false
    ]
    ask next-reader [
      ;show filter [? -> first ? = cycle ] cycle-init-time
      if empty? filter [? -> first ? = cycle] cycle-init-time [
      ;if all? other readers [cycle < next-cycle] [
        set cycle-init-time lput (list ([cycle] of self) ticks) cycle-init-time
        ;print cycle-init-time
      ]
      ;
      set truck-being-served next-truck ; task variable owned by reader
      ;set pallet-being-served one-of [ pallets-in-truck ] of next-truck
      set pallet-being-served [ pallets-in-truck ] of next-truck
      ;ask pallet-being-served [ set pallet-distance (random-tween 1 3 ) ]
      set color red
      ; In this traffic case 'pallet-being-served' are all pallets
      ;setup-tags ( pallet-being-served )  ( truck-being-served )
      ;let pallet-with-tags-this-reader pallet-being-served with [is-agentset? tags-in-pallet]
      ifelse stp = "0" [ ; first tag creation
        set my-tags ( setup-tags ( [pallets-in-truck] of truck-being-served )  ( truck-being-served ) )
        ask my-tags [ set time-entered-service ticks ]
      ] [
        setup-tags-change ( pallet-being-served with [is-agentset? tags-in-pallet] )  ( truck-being-served )
      ]
      ; I believe next line is not needed
      set my-tags (turtle-set [ tags-in-pallet ] of pallet-being-served)
      ;
      ; ask my-tags [ set time-entered-service ticks ] ;<<--we should measure some parameters
      if any? my-tags [
        set total-time-in-queue  ; OJO
          (total-time-in-queue + (one-of [time-entered-service - time-entered-queue] of my-tags))
        set total-queue-throughput (total-queue-throughput + (count my-tags))
      ]

      set next-start-LM-time ifelse-value (stp = "1") [
        ;time-between-inventories is a global 10s or more
        ; TM-to-LM-time is 100ms
        (ticks + time-between-inventories)
        ;(cycle * time-between-inventories)
      ] [ ticks + TM-to-LM-time ]
    ]
  ]
 ; next look if there is any ready reader to start LM
 ; to see if there is a pallet to inventory.
  let readers-empty-queue-r (available-readers with [empty? queue-r])
 if any? readers-empty-queue-r [
    ask one-of readers-empty-queue-r [
      set next-start-LM-time ifelse-value (stp = "1") [
        (ticks + time-between-inventories)
        ;(cycle * time-between-inventories)
      ] [ ticks + TM-to-LM-time ]
    ]
 ]

  ;; in portal simulator here we look for readers with truck but no pallet to assing one
end


to setup-tags-distances-chk
  ifelse dislocated? [ ; See labels in Fig. of block
    set distance-to-checkout_1_fw sqrt ( (([ checkout-height_1_tx ] of myself - tag-y ) ^ 2) + (D_1 ^ 2) + (tag-z ^ 2) )
    set distance-to-checkout_1_bw sqrt ( (([ checkout-height_1_rx ] of myself - tag-y ) ^ 2) + (D_2 ^ 2) + (tag-z ^ 2) )
    set distance-to-checkout_2_fw sqrt ( (([ checkout-height_2_tx ] of myself - tag-y ) ^ 2) + (D_2 ^ 2) + (tag-z ^ 2) )
    set distance-to-checkout_2_bw sqrt ( (([ checkout-height_2_rx ] of myself - tag-y ) ^ 2) + (D_1 ^ 2) + (tag-z ^ 2) )
  ] [
    set distance-to-checkout_1_fw sqrt ( (([ checkout-height_1_tx ] of myself - tag-y ) ^ 2) + (D_1 ^ 2) + (tag-z ^ 2) )
    set distance-to-checkout_1_bw sqrt ( (([ checkout-height_1_rx ] of myself - tag-y ) ^ 2) + (D_1 ^ 2) + (tag-z ^ 2) )
    set distance-to-checkout_2_fw sqrt ( (([ checkout-height_2_tx ] of myself - tag-y ) ^ 2) + (D_2 ^ 2) + (tag-z ^ 2) )
    set distance-to-checkout_2_bw sqrt ( (([ checkout-height_2_rx ] of myself - tag-y ) ^ 2) + (D_2 ^ 2) + (tag-z ^ 2) )
  ]
  ;show (list distance-to-reader_1_fw distance-to-reader_1_bw distance-to-reader_2_fw distance-to-reader_2_bw)
end

to setup-tags-angles-chk [ ?cart ]
  ifelse dislocated? [ ; See labels in Fig. of block
    set azimuthal_angle_1_fw (90 - acos (( tag-x + [ chart-distance ] of ?cart ) / distance-to-checkout_1_fw ) )
    set azimuthal_angle_1_bw (90 - acos (( tag-x + ( portal-width - [ chart-distance ] of ?cart ) ) / distance-to-checkout_1_bw ) )
    set alpha_1_fw ([inclination_angle_1_tx] of myself + asin ( ([ checkout-height_1_tx ] of myself - tag-y ) / distance-to-checkout_1_fw ) )
    set alpha_1_bw ([inclination_angle_1_rx] of myself + asin ( ([ checkout-height_1_rx ] of myself - tag-y ) / distance-to-checkout_1_bw ) )
    if alpha_1_fw = 90 or alpha_1_fw = 270 [set alpha_1_fw (alpha_1_fw + 1e-6)]
    if alpha_1_bw = 90 or alpha_1_bw = 270 [set alpha_1_bw (alpha_1_bw + 1e-6)]
    ;
    set azimuthal_angle_2_bw (90 - acos (( tag-x + [ chart-distance ] of ?cart ) / distance-to-checkout_2_bw ) )
    set azimuthal_angle_2_fw (90 - acos (( tag-x + ( portal-width - [ chart-distance ] of ?cart ) ) / distance-to-checkout_2_fw ) )
    set alpha_2_bw ([inclination_angle_2_rx] of myself + asin ( ([ checkout-height_2_rx ] of myself - tag-y ) / distance-to-checkout_2_bw ) )
    set alpha_2_fw ([inclination_angle_2_tx] of myself + asin ( ([ checkout-height_2_tx ] of myself - tag-y ) / distance-to-checkout_2_fw ) )
    if alpha_2_fw = 90 or alpha_2_fw = 270 [set alpha_1_fw (alpha_1_fw + 1e-6)]
    if alpha_2_bw = 90 or alpha_2_bw = 270 [set alpha_1_bw (alpha_1_bw + 1e-6)]
  ] [
    set azimuthal_angle_1_fw (90 - acos (( tag-x + [ chart-distance ] of ?cart ) / distance-to-checkout_1_fw ) )
    set azimuthal_angle_1_bw azimuthal_angle_1_fw
    set alpha_1_fw ([inclination_angle_1_tx] of myself + asin ( ([ checkout-height_1_tx ] of myself - tag-y ) / distance-to-checkout_1_fw ) )
    set alpha_1_bw alpha_1_fw
    if alpha_1_fw = 90 or alpha_1_fw = 270 [set alpha_1_fw (alpha_1_fw + 1e-6)]
    if alpha_1_bw = 90 or alpha_1_bw = 270 [set alpha_1_bw (alpha_1_bw + 1e-6)]
    ;
    set azimuthal_angle_2_fw (90 - acos (( tag-x + ( portal-width - [ chart-distance ] of ?cart ) ) / distance-to-checkout_2_fw ) )
    set azimuthal_angle_2_bw azimuthal_angle_2_fw
    set alpha_2_fw ([inclination_angle_2_tx] of myself + asin ( ([ checkout-height_2_tx ] of myself - tag-y ) / distance-to-checkout_2_fw ) )
    set alpha_2_bw alpha_2_fw
    if alpha_2_fw = 90 or alpha_2_fw = 270 [set alpha_1_fw (alpha_1_fw + 1e-6)]
    if alpha_2_bw = 90 or alpha_2_bw = 270 [set alpha_1_bw (alpha_1_bw + 1e-6)]
  ]
end

to setup-tags-chart [ ?chart ]
  let tags-of-this-chart nobody
  ;show (word "num-in-chart = " ([num-tags-in-chart] of ?chart) " , tot = " (count tags with [not in-chart?]) )
  if any? tags with [not in-chart?] and ( ([num-tags-in-chart] of ?chart) < (count tags with [not in-chart?]) ) [

    set tags-of-this-chart n-of ([num-tags-in-chart] of ?chart) (tags with [ not in-chart? ])
    ask readers [
      let mt my-tags
      if any? tags-of-this-chart with  [ member? self mt ] [
      ;if member? tags-of-this-chart my-tags [
        ask pallet-being-served [
          let tp tags-in-pallet
          if any? tags-of-this-chart with [member? self tp ] [
          ;if member? tags-of-this-chart tags-in-pallet [
            ; remove tags-of-this-chart from tags-in-pallet
            set tags-in-pallet tags-in-pallet with [ not member? self tags-of-this-chart ]
          ]
          set num-tags-in-pallet count tags-in-pallet
        ]
        set my-tags my-tags with [ not member? self tags-of-this-chart ]
      ] ;if any? ...
    ]; ask readers
    ; compute the ratio of already located tags
    let no-singled-out-ratio (count tags-of-this-chart with [not inventoried-first?]) / (count tags-of-this-chart)
    file-open p-loss-file
    file-write ticks file-write no-singled-out-ratio file-write (count tags-of-this-chart) file-print ""
    file-close
    ; next, setup the tags-of-this-chart in the chart
    ask tags-of-this-chart [
      set inventoried? false
      set time-entered-queue [ time-entered-queue ] of ?chart
      set hidden? true
      set tag-x (random-tween -0.29 0.29 )
      set tag-y ( random-tween 0.42 0.9525 )
      set tag-z ( random-tween -0.43 0.43 )
      set D_1 sqrt ( ( tag-x + [ chart-distance ] of ?chart ) ^ 2 + ( tag-z ^ 2 ) )
      set D_2 sqrt ( ( tag-x + ( portal-width - [ chart-distance ] of ?chart ) ) ^ 2 + (tag-z ^ 2 ) )
      setup-tags-distances-chk
      setup-tags-angles-chk (?chart)
      ;show (list D_1 D_2 distance-to-reader_1 distance-to-reader_2 )
      set tag-sensitivity min-power-to-feed-tag-IC
      set tag-outage? false
      ;set tag-gain-fw 1.621810097 ; 2.1 dBi
    ;set tag-gain-bw 1.621810097 ; 2.1 dBi
    ;set dipole_inclination_angle_fw random 45 + 46 ;random 360 + 1 ; to get a random integer angle [0:360]
    ;set dipole_inclination_angle_fw random 360 + 1
    set dipole_inclination_angle_fw random-tween (min-tag-inclination-angle) (90)
    if dipole_inclination_angle_fw = 0 or dipole_inclination_angle_fw = 180 [set dipole_inclination_angle_fw (dipole_inclination_angle_fw + 1e-6)]
    ;green
    set tag-gain-fw precision (1.621810097 * ((cos (90 * cos (dipole_inclination_angle_fw + 1E-10)) / (sin (dipole_inclination_angle_fw + 1E-10))) ^ 2))  8 ;linear value
    ifelse dislocated? [
      ;set dipole_inclination_angle_bw random 45 + 46 ;random 360 + 1
      ;set dipole_inclination_angle_bw  random 360 + 1
      set dipole_inclination_angle_bw random-tween (min-tag-inclination-angle) (90)
      if dipole_inclination_angle_bw = 0 or dipole_inclination_angle_bw = 180 [set dipole_inclination_angle_bw (dipole_inclination_angle_bw + 1e-6)]
      set tag-gain-bw precision (1.621810097 *  ((cos (90 * cos (dipole_inclination_angle_bw + 1E-10)) / (sin (dipole_inclination_angle_bw + 1E-10))) ^ 2))  8 ;linear value
    ] [
      set tag-gain-bw tag-gain-fw
    ]
    ;
      set outage-count-of-this-tag 0
      set in-chart? true
    ] ;ask tags-of-this-chart
    ask ?chart [ set tags-in-chart tags-of-this-chart ]

  ]
  ;[
    ; replenish if necessary (part comes from 'departure')
  ;replenish-stands ; commented because y want to schedule this task by a period of inventory
  ;]
end

to replenish-stands
  if (count tags with [not in-chart?]) <= ( (minimum-stock-level / 100) * total-initial-tags ) [
      set moments-of-arrivals ( moments-of-arrivals + 1 )
      let pallets-to-refill (pallets with [ count tags-in-pallet < mean-tags-per-pallet ])
      if any? pallets-to-refill [
        ask pallets-to-refill [
          hatch-tags ( mean-tags-per-pallet - ([count tags-in-pallet] of self) ) [
            set inventoried? false
            set time-entered-queue ticks
            set time-entered-service ticks
            set hidden? true
            set tag-x (random-tween (-1 * (p-width / 2)) (p-width / 2) ) + [ dx-to-center-of-reader ] of myself
            set tag-y (random-tween (-1 * (p-depth / 2)) (p-depth / 2) ) + [ dy-to-center-of-reader ] of myself
            set tag-z (random-tween p-base p-height )
            set distance-to-reader sqrt ( ( ( tag-x ) ^ 2 + ( tag-y ) ^ 2 ) + ( ceiling-to-floor-distance - tag-z ) ^ 2 )
            set tag-sensitivity min-power-to-feed-tag-IC
            set tag-outage? false
            set tag-gain 1.621810097 ; 2.1 dBi
            set outage-count-of-this-tag 0
            set inventoried-first? false ; still not inventoried
            set tag-id-group (random num-tag-groups )
            set in-chart? false
            ; update pallet and reader
            ;let me self
            ask myself [
              set num-tags-in-pallet (num-tags-in-pallet + 1)
              set tags-in-pallet (turtle-set tags-in-pallet myself)
            ] ;ask myself (ref to pallet-to-refill

            let this-pallet myself
            ask readers [
              if member? this-pallet pallet-being-served [
                set my-tags (turtle-set my-tags myself)
                if ticks < next-completion-time [
                  let k my-FSA
                  set next-completion-time ( ticks + k + empty-frames-TM )
                ]
              ]
            ]

          ] ;hatch
          set total-queue-throughput (total-queue-throughput + ( mean-tags-per-pallet - ([count tags-in-pallet] of self) ))
        ] ; ask pallets-to-refill
      ] ; if pallets-to-refill
    ] ; if count
  schedule-replenish ; only if replenish is included in event-queue
end

;to setup-tags-chart [ ?chart ]
;  let list-of-tags []
;  hatch-tags ([num-tags-in-chart] of ?chart) [
;    set list-of-tags (lput self list-of-tags)
;    set inventoried? false
;    set time-entered-queue [ time-entered-queue ] of ?chart
;    set hidden? true
;    ;set tag-x   0
;    ;set tag-x (random-tween -0.20 0.20 )
;    set tag-x (random-tween -0.29 0.29 )
;    ;set tag-y   0.5
;    ;set tag-y (random-tween 0.3 0.6 )
;    set tag-y ( random-tween 0.42 0.9525 )
;    set tag-z ( random-tween -0.43 0.43 )
;    set D_1 sqrt ( ( tag-x + [ chart-distance ] of ?chart ) ^ 2 + ( tag-z ^ 2 ) )
;    set D_2 sqrt ( ( tag-x + ( portal-width - [ chart-distance ] of ?chart ) ) ^ 2 + (tag-z ^ 2 ) )
;    setup-tags-distances-chk
;    ;show (list D_1 D_2 distance-to-reader_1 distance-to-reader_2 )
;    set tag-sensitivity min-power-to-feed-tag-IC
;    set tag-outage? false
;    set tag-gain 1.621810097 ; 2.1 dBi
;    set outage-count-of-this-tag 0
;    set in-chart? true
;  ]
;  ask ?chart [ set tags-in-chart (turtle-set list-of-tags) ]
;end


;; -->Besides, for each pallet in the truck, generate a complete-service event with
;; a time computed making the inventory of that particular pallet
;; But first we have to plan an event time to start LM
;; JUST WITH CHARTS:
to begin-service-chk
  let available-checkouts (checkouts with [not is-agent? chart-being-served])
  if (not empty? queue-chk and any? available-checkouts) [ ; OJO
    let next-chart (first queue-chk)
    let next-checkout one-of available-checkouts
    set queue-chk (but-first queue-chk)
    ask next-chart [
      move-to next-checkout
      set hidden? false ]
    ask next-checkout [
      set chart-being-served next-chart ; task variable owned by server
      ;set pallet-being-served one-of [ pallets-in-truck ] of next-truck
      ;ask pallet-being-served [ set pallet-distance (random-tween 1 3 ) ]
      set color red
      setup-tags-chart ( chart-being-served )  ;( truck-being-served )
      set my-tags [ tags-in-chart ] of chart-being-served
      ;show my-tags
      ask my-tags [ set time-entered-service ticks ] ;<<--we should measure some parameters
      set total-time-in-queue-chk  ; OJO
        (total-time-in-queue-chk + (one-of [time-entered-service - time-entered-queue] of my-tags))
      set total-queue-throughput-chk (total-queue-throughput-chk + (count my-tags))
      set next-start-LM-time ticks
    ]
  ]
 ; next look if there is any ready reader to start LM
 ; to see if there is a pallet to inventory.
 if empty? queue and any? available-checkouts [
    ask one-of available-checkouts [
      set next-start-LM-time ticks
    ]
 ]

  ;; there could be other readers prepared to receive a new pallet
  ;; and generate event time to start LM
;  let ready-readers ( readers with [ is-agent? truck-being-served and (not is-agent? pallet-being-served) ] )
;  if any? ready-readers [
;    ;let next-ready-reader one-of ready-readers ;
;    ask one-of ready-readers [
;      ; still-not inventoried should probably take it out from code <-- Ojo
;      let not-inventoried-pallets-in-truck ([pallets-in-truck with [still-not-inventoried = true] ] of truck-being-served)
;      if any? not-inventoried-pallets-in-truck [
;        set pallet-being-served  one-of not-inventoried-pallets-in-truck
;        ask pallet-being-served [ set pallet-distance (random-tween 1 3 ) ]
;        ;set color red
;        setup-tags ( pallet-being-served )  ( truck-being-served )
;        set my-tags ([ tags-in-pallet ] of pallet-being-served)
;        ask my-tags [ set time-entered-service ticks ]
;        set total-time-in-queue  ; OJO
;          (total-time-in-queue + (one-of [time-entered-service - time-entered-queue] of my-tags))
;        set total-queue-throughput (total-queue-throughput + (count my-tags))
;        set next-start-LM-time ticks + TM-to-LM-time
;        ; if more than one all going to start at the same time => random (0,5ms) in 11 steps
;      ] ; else [ all pallets are read and the reader must be free for more trucks
;    ] ;ask
;  ]
end


to-report random11steps [ minLM ]
  let step random 11 + 1
  let step-value (minLM / 11)
  report step * step-value
end


to-report compute-reader-gain-interf [ other-reader D height-diff distance-to-r ]
  ;set distance-to-r (distance-to-r * 10)
  ;show distance-to-r
  ;
  ;let phi asin ( abs ( (ycor - min-pycor) - ([ycor] of other-reader - min-pycor) ) / (distance myself) )
  ;set phi 90 - phi
  ;
  let alpha 90 let phi 90
  ifelse (is-reader? self and is-reader? myself) [
    set alpha inclination_angle_1_tx_rx + 90 - asin ( (D / 2) / ((distance-to-r / 2) ) ) ;+ 90
    set phi alpha
  ][
    set phi asin ( abs ( (ycor - min-pycor) - ([ycor] of other-reader - min-pycor) ) / (distance-to-r / distance-multiplicative) )
    set phi 90 - phi
    ; ojo - esta formula depende de los tipos de reader/checkout
    set alpha ifelse-value even-frame? [inclination_angle_1_tx + asin ( height-diff / distance-to-r )  ][ inclination_angle_2_tx + asin ( height-diff / distance-to-r ) ]
  ]
  if alpha = 90 or alpha = 270 [set alpha (alpha + 1e-6)]
  ;show (word "[self,other-reader]= " (list self other-reader) " , phi= " phi " , alpha = " alpha " , gain= " (3.136 * ( (tan alpha) * (sin ( 90 * (cos alpha) * (sin phi) ) ) ) ^ 2) )

  report 3.136 * ( (tan alpha) * (sin ( 90 * (cos alpha) * (sin phi) ) ) ) ^ 2
end

;; compute the interf power received from other TM? readers
;; context of the other readers
to-report compute-interf-power
  ;let x-pos xcor let y-pos ycor
  let current-r-height ifelse-value (is-checkout? self) [
    ifelse-value ([even-frame?] of self) [checkout-height_1_tx][checkout-height_2_tx]
  ][
    ceiling-to-floor-distance   ;reader-height_1_tx_rx ; 1.5
  ]

  let D (distance myself) ; distance to myself
  set D (D * distance-multiplicative)
  let height-of-myself ifelse-value (is-checkout? myself) [
    ifelse-value ([even-frame?] of myself) [[checkout-height_1_tx] of myself][[checkout-height_2_tx] of myself]
  ][
    ceiling-to-floor-distance
  ]
  ;Next the distance between readers
  let distance-to-r ifelse-value (is-reader? self and is-reader? myself)[
    (2 * sqrt ( ceiling-to-floor-distance ^ 2 + (D / 2) ^ 2 ) )
  ][
    sqrt ( ( current-r-height - height-of-myself ) ^ 2 + (D ^ 2) )
  ]
  ;let distance-to-r (2 * sqrt ( ceiling-to-floor-distance ^ 2 + (D / 2) ^ 2 ) )
  ;;
  ;;
  let H ( sqrt( 1 - (4 * current-r-height * height-of-myself ) / ( (D ^ 2) + (( current-r-height + height-of-myself ) ) ^ 2) ) )
  let theta 2 * pi / (c / ifelse-value (is-checkout? self) [checkout-frequency] [reader-frequency] ) * ( sqrt((D ^ 2) + ( current-r-height + height-of-myself  ) ^ 2 ) - sqrt( ( (D ^ 2) + ( current-r-height - height-of-myself ) ^ 2) ) )
  let q_e  ( (H ^ 2) * ( sin (theta * radians-to-degrees) ) ^ 2 ) + (( 1 - H * cos (theta * radians-to-degrees) ) ^ 2)
  ;show (word "distance-to-r= " distance-to-r " , H= " H " , theta= " theta " , q_e= " q_e )
  ; SHADOWING parameter
  let shadow ( 10 ^ (-1 * ( random-normal 0 sigma ) / 10 ) )
  ;

  let reader-gain-tx-interf ( compute-reader-gain-interf myself D (abs ( current-r-height - height-of-myself )) distance-to-r )
  let this-reader self
  let reader-gain-rx-interf reader-gain-tx-interf
  ask myself [ set reader-gain-rx-interf ( compute-reader-gain-interf this-reader  D (abs ( current-r-height - height-of-myself )) distance-to-r ) ]
  ;
  ;;-----Rician only-------
  ;let tag-power-rx-linear ( ([ reader-power-tx * reader-gain-tx-rx * ((c / reader-frequency) ^ 2) ] of myself ) * tag-gain * polarz-mismatch * pow-tx-coefficient )  /
  ;    (( ( 4 * pi * distance-to-r ) ^ 2) * on-object-gain-penalty * path-blockages * fading-factor-fw ) * ( q_e_rcn_fw * shadow_fw ); loss-by-rician-fading-fw
  ;;-----Rician only-------
  let fresnel 1
  ;;------Two Rays Model (No Rician fading) --------
  let r2r-power-rx-linear ifelse-value (is-reader? self) [
    (  reader-power-tx * (reader-gain-tx-interf * reader-gain-rx-interf) * ((c / reader-frequency) ^ 2)   )  /
      (( ( 4 * pi * distance-to-r ) ^ 2) ) * ( q_e * shadow * fresnel ) ;/ ACPR_linear ;
  ][
    (  checkout-power-tx * (reader-gain-tx-interf * reader-gain-rx-interf) * ((c / checkout-frequency) ^ 2)   )  /
      (( ( 4 * pi * distance-to-r ) ^ 2) ) * ( q_e * shadow * fresnel ) ;/ ACPR_linear ;
  ]
  let r2r-power-rx  ifelse-value (r2r-power-rx-linear > 0) [( 10 * log (1000 * r2r-power-rx-linear) 10 ) ] [ -1E10 ]
  ;show (word "agent-1 = " (list myself [ (list LM? TM?)] of myself) " , agent-2 = " (list self [ (list LM? TM?)] of self )
  ;  "read-gain-tx= " reader-gain-tx-interf " , read-gain-rx= " reader-gain-rx-interf " , [pw, pw-lin] = " (list r2r-power-rx-linear r2r-power-rx ))

  if (r2r-power-rx > interf-threshold) [; there would be interferences
    create-rris-with (turtle-set myself)
    ;ifelse LM? [ask my-rris [set color white] ] [ ask my-rris [set color green] ]
    ask my-rris with [[LM?] of other-end ][set color white]
    ask my-rris with [[TM?] of other-end ][set color green ]
    ;if (self = reader 6 or self = reader 11) and (myself = reader 11 or myself = reader 6) [show (list myself self r2r-power-rx) ]
  ]
  ;if (r2r-power-rx <= interf-threshold) [; no interf
  ;  show (word "NO interf, interf Power = " (list r2r-power-rx r2r-power-rx-linear) )
  ;]
  report r2r-power-rx-linear
end

;; The reader start listening the channel
;; if another reader uses the channel, then it has to wait a random time [.05s 0.1s]
;; and try again.
to start-LM [ ?reader ]
  ask ?reader [
    ;print "AQUI0" show self
    if collide? [set collide? false ]
    ask my-rris [ die ]
    ;let TM-neighbors other readers with [TM?]
    let TM-neighbors other allreaders-set with [TM?]
    if interference-type = "0" [set TM-neighbors no-turtles ]
    if interference-type = "1" [
      set TM-neighbors (temp-in-radius TM-neighbors (interf-rri-radius / distance-multiplicative))
    ]
    ifelse not any? TM-neighbors [
      set next-start-TM-time (next-start-LM-time + min-LM)
      ;set contention? false
      ;print "AQUI1"
      set LM? true
    ] [ ; Compute the INTERF of TM-neighbors
        let interf-power-list (list )
        ask TM-neighbors [
          set interf-power-list lput (compute-interf-power ) interf-power-list
        ];ask

        set interf-from-neighbors_LM-linear (sum interf-power-list)
        let interf-threshold-linear (10 ^ (interf-threshold / 10) ) / 1000
        ifelse (not empty? interf-power-list) and ((max interf-power-list) > interf-threshold-linear) [
          ;; Detects the channel occupied
          ;; if not, change start LM to random time between 50 to 100 ms
          set next-start-LM-time (next-start-LM-time + random-tween 0.05 0.1 )
          ;set contention? true
          set LM? false
        ] [
          ;print "AQUI2"
          set next-start-TM-time (next-start-LM-time + min-LM)
          set LM? true
        ] ; ifelse (not empty? interf-power-list)

    ] ; ifelse not any? TM-neighbors
  ] ;ask ?reader
end

;to start-TM [ ?reader ]
;  ask ?reader [
;    set TM? true
;    set LM? false
;    set interf-from-neighbors_TM-linear 0
;    ;ask my-rris with [[color = white] of other-end ][die]
;    if contention? [ set contention? false ]
;    ask my-rris with [[TM?] of other-end ] [ die ]
;    let interf-threshold-linear (10 ^ (interf-threshold / 10) ) / 1000
;    let TM-neighbors other readers with [TM?]
;    if (interference-type = "0") [set TM-neighbors no-turtles]
;    if (interference-type = "1") and (any? TM-neighbors)[
;      set TM-neighbors (temp-in-radius TM-neighbors (interf-rri-radius / distance-multiplicative))
;      ;print "1"
;      ;show [who] of TM-neighbors
;    ]
;    ;print "rest"
;    ;show [who] of TM-neighbors
;
;    ifelse not any? TM-neighbors or (interference-type = "0") [
;      ; Reader can transmit
;      ;print (word "tx_reader_no_neigh_TM " ?reader)
;      ;set TM? true
;      set interf-from-neighbors_TM-linear 0
;      let k my-FSA
;      ;show (list k count my-tags with [inventoried? and outage-count-of-this-tag < 2] count my-tags ); <<------OJO "Not Remove"
;      ;set next-completion-time (ticks + k ) ;my-FSA)
;      set next-completion-time ( ticks + k + empty-frames-TM )
;      set LM-time (LM-time + (ticks - next-start-LM-time))
;    ] [
;      if interference-type = "2" or interference-type = "1" [
;        ;print "TM 1 o 2"
;
;        ; Collision or Contention but depending on times and interf signal level
;        ; let start with interf signal levels:
;        let interf-power-list (list )
;        let readers-over-threshold (turtle-set )
;        ask TM-neighbors [
;          set interf-power-list lput (compute-interf-power ) interf-power-list
;          if (last interf-power-list > interf-threshold-linear) [ set readers-over-threshold (turtle-set readers-over-threshold self) ]
;          ;set readers-over-threshold (turtle-set readers-over-threshold self)
;        ];ask
;        ;set interf-from-neighbors_TM-linear (sum [interf-power-list] of readers-over-threshold)
;        set interf-from-neighbors_TM-linear (sum interf-power-list)
;        ;show (word "[linear, dBm] = " (list interf-from-neighbors_TM-linear ( 10 * log (1000 * interf-from-neighbors_TM-linear) 10 )) )
;
;        ifelse any? readers-over-threshold [
;          ;show (word " OVER THRES= " [who] of readers-over-threshold)
;          let readers-with-RRI readers-over-threshold with [
;             next-start-TM-time < ([next-start-TM-time] of myself) and
;                 ;([next-start-TM-time] of myself) - next-start-TM-time <= (distance myself) * 10 * tau ]
;                 ([next-start-TM-time] of myself) - next-start-TM-time <= (distance myself) * distance-multiplicative * tau ]
;          ifelse any? readers-with-RRI [
;            ;;print "collision" ;;;---------<<<<<<<<
;            manage-collision readers-with-RRI ] [ manage-contention ]
;
;        ][
;          ;print " BELOW Threshold -> READ!!"
;          let k my-FSA
;          ;show (list k count my-tags with [inventoried? and outage-count-of-this-tag < 2] count my-tags ); <<------OJO "Not Remove"
;          ;set next-completion-time (ticks + k ) ;my-FSA)
;          set next-completion-time ( ticks + k + empty-frames-TM )
;          set LM-time (LM-time + (ticks - next-start-LM-time))
;        ]
;        ;show (word (list "Interf and inter readers= " interf-from-neighbors_TM-linear ([who] of readers-over-threshold)))
;
;
;      ] ; if  interference-type = "2" or interference-type = "1"
;;      [
;;        ; Not any reader over TM threshold then reader can transmit
;;        ;print (word "tx_reader_no_neigh_dB " ?reader)
;;        ;set TM? true
;;        set interf-from-neighbors_TM-linear 0
;;        let k my-FSA
;;        ;show (list k count my-tags with [inventoried? and outage-count-of-this-tag < 2] count my-tags ); <<------OJO "Not Remove"
;;        ;set next-completion-time (ticks + k ) ;my-FSA)
;;        set next-completion-time ( ticks + k + empty-frames-TM )
;;        set LM-time (LM-time + (ticks - next-start-LM-time))
;;      ]
;
;    ]
;
;
;  ]
;
;end


to start-TM [ ?reader ]
  ask ?reader [
    set TM? true
    set LM? false
    set interf-from-neighbors_TM-linear 0
    ;ask my-rris with [[color = white] of other-end ][die]
    if contention? [ set contention? false ]
    ask my-rris with [[TM?] of other-end ] [ die ]
    let interf-threshold-linear (10 ^ (interf-threshold / 10) ) / 1000
    ;let TM-neighbors other readers with [TM?]
    let TM-neighbors other allreaders-set with [TM?]
    ;
    if (interference-type = "0") [set TM-neighbors no-turtles] ; this implies a channel for each reader
    ;
    if (interference-type = "1") and (any? TM-neighbors)[
      set TM-neighbors (temp-in-radius TM-neighbors (interf-rri-radius / distance-multiplicative))
      ;print "1"
      ;show [who] of TM-neighbors
    ]
    ;print "rest"
    ;show [who] of TM-neighbors

    ifelse not any? TM-neighbors [;or (interference-type = "0") [
      ; Reader can transmit
      ;print (word "tx_reader_no_neigh_TM " ?reader)
      ;set TM? true
      set interf-from-neighbors_TM-linear 0
      let k my-FSA
      ;show (list k count my-tags with [inventoried? and outage-count-of-this-tag < 2] count my-tags ); <<------OJO "Not Remove"
      ;set next-completion-time (ticks + k ) ;my-FSA)
      set next-completion-time ( ticks + k + empty-frames-TM )
      set LM-time (LM-time + (ticks - next-start-LM-time))
    ] [
      ;if interference-type = "2" or interference-type = "1" [
        ;print "TM 1 o 2"

        ; Collision or Contention but depending on times and interf signal level
        ; let start with interf signal levels:
        let interf-power-list (list )
        let readers-over-threshold (turtle-set )
        ask TM-neighbors [
          set interf-power-list lput (compute-interf-power ) interf-power-list
          if (last interf-power-list > interf-threshold-linear) [ set readers-over-threshold (turtle-set readers-over-threshold self) ]
          ;set readers-over-threshold (turtle-set readers-over-threshold self)
        ];ask
        ;set interf-from-neighbors_TM-linear (sum [interf-power-list] of readers-over-threshold)
      set interf-from-neighbors_TM-linear ifelse-value (interference-type = "0") [0] [(sum interf-power-list)]
        ;show (word "[linear, dBm] = " (list interf-from-neighbors_TM-linear ( 10 * log (1000 * interf-from-neighbors_TM-linear) 10 )) )

        ifelse any? readers-over-threshold [
          ;show (word " OVER THRES= " [who] of readers-over-threshold)
          let readers-with-RRI readers-over-threshold with [
             next-start-TM-time < ([next-start-TM-time] of myself) and
                 ;([next-start-TM-time] of myself) - next-start-TM-time <= (distance myself) * 10 * tau ]
                 ([next-start-TM-time] of myself) - next-start-TM-time <= (distance myself) * distance-multiplicative * tau ]
          ifelse any? readers-with-RRI [
            ;;print "collision" ;;;---------<<<<<<<<
            manage-collision readers-with-RRI ] [ manage-contention ]

        ][
          ;print " BELOW Threshold -> READ!!"
          let k my-FSA
          ;show (list k count my-tags with [inventoried? and outage-count-of-this-tag < 2] count my-tags ); <<------OJO "Not Remove"
          ;set next-completion-time (ticks + k ) ;my-FSA)
          set next-completion-time ( ticks + k + empty-frames-TM )
          set LM-time (LM-time + (ticks - next-start-LM-time))
        ]
        ;show (word (list "Interf and inter readers= " interf-from-neighbors_TM-linear ([who] of readers-over-threshold)))


      ;] if

    ]


  ]

end


;; other readers has started TM before and we collide
;; must re-schedule the time to start TM and increment collisions
to manage-collision [ rdr-with-rri ]
  set next-completion-time 0
  set TM? false set LM? false set collide? true
  ;if collide? [ set collide? false ]
  set collide? true
  ;set next-start-LM-time ( ticks + TM-to-LM-time + random-tween 0.05 0.1 )
  set next-start-LM-time ( ticks + TM-to-LM-time )
  ask my-tags [ set inventoried? false ] ; repeat the inventory from 0
  set num-of-collisions (num-of-collisions + 1)
  ;set collide? false
  ; Other readers note the collision after the propagation back to themselves
  ;if any? rdr-with-rri [
  if (is-agentset? rdr-with-rri) or (is-agent? rdr-with-rri) [
    ask rdr-with-rri [
      ;set next-completion-time ticks + ((distance myself) * 10 * tau)
      set next-start-LM-time ( ticks + ((distance myself) * distance-multiplicative * tau) + TM-to-LM-time )
      ;set num-of-collisions (num-of-collisions + 1)
      ; When they reach the completion-time
      ; they have to start the inventory of all tags on the pallet.
      ; However, more accurate is to die the tags inventoried
      ask my-tags [ set inventoried? false ]
      set collide? true
    ]
  ]
end

;; another reader have owned the channel
;; during my LM-time or just at the current time
;; and actual reader must re-schedule another LM-time
to manage-contention
  ask my-rris with [ [ TM? ] of other-end ] [ set color yellow ]
  set next-start-TM-time ( ticks + random11steps min-LM )
  ;ask my-tags [ set inventoried? false ]
  set TM? false
  set contention? true
end

; inspect reader 0 inspect truck 1 inspect pallet 5 inspect tag 100
to write-known-tags-ratio
  ;; Get the tags invenotoried vs all tags and write in a file
  ;if total-inventory-cycles <= 100000 [
    let pallets-with-tags (pallets with [ is-agentset? tags-in-pallet ])
    let total-tags sum [ num-tags-in-pallet ] of pallets-with-tags
    ;let total-tags-singulated sum [ count tags-in-pallet with [
    ;  inventoried? and not(outage-count-of-this-tag < max-num-of-outages) ] ] of pallets-with-tags
    ;
    let total-tags-singulated count tags with [ inventoried-first? ]
    ; show (list pallets-with-tags total-tags total-tags-singulated ) ;------
; if total-inventory-cycles <= 100000 [
    let kr ifelse-value (total-tags > 0)[total-tags-singulated / total-tags][0]
    file-open known-file
    file-write ticks
    file-write ( kr ) file-print ""
    file-close
    ;set total-inventory-cycles (total-inventory-cycles + 1)
  ;] ;if
end



to reset-truck [ truck? r?]
  ask truck? [
    set color brown
    let t self
    ask r? [set queue-r (fput t queue-r)]
    set time-entered-queue ticks
  ]
  ask pallets-in-truck [ set still-not-inventoried true ]
  ;ask ( turtle-set [ tags-in-pallet ] of pallets-in-truck ) [ set inventoried? false ]
end


;;
;; Updates time-in-system statistics, removes current pallet or truck agent, returns
;; the server to the idle state, and attempts to start service on another
;; pallet or truck.
to complete-service [ ?reader ]
  ; write-known-tags-ratio
  ask ?reader [
    ;print "complete" show self
    ifelse not collide? [
      ;if not any? [not inventoried?] of my-tags [
      let one-tag one-of my-tags
      if is-agent? one-tag [
        set total-time-in-system (total-time-in-system + ticks
          - [time-entered-queue] of one-tag) ; [time-entered-queue] of one-of my-tags
        ;set total-system-throughput (total-system-throughput + count my-tags) ; this is from before the including outages of tags
        let tagson ( my-tags with [ (outage-count-of-this-tag >= max-num-of-outages) ] )
        if any? tagson [
          set total-outages ( total-outages + count tagson ) ;my-tags with [ (outage-count-of-this-tag >= max-num-of-outages) ] )
          ;
          ask tagson [ ; State machine of tags where reader does not singulate during 10 times
            set tag-round-not-located ( tag-round-not-located + 1 )
            ;print "tag-round-not-located"
            if ( tag-round-not-located = maxnum-fail-inventories ) [
              set inventoried-first? false
              ; this tag is not located any more
              ;print "state 3 to 1!"
            ] ; loc is not known
          ]
          ;
        ]
        set total-system-throughput (total-system-throughput + count ( my-tags with [ inventoried? and (outage-count-of-this-tag < max-num-of-outages) ] ) )
        set total-pallets-thoughput (total-pallets-thoughput + 1)

      ]
        ;ask my-tags [ die ]
        ;set my-tags nobody
        ;ask pallet-being-served [ die ]
        ;set pallet-being-served nobody
        ask my-rris [ set color 5 ] ;default color of link
        ask truck-being-served [
          ;ifelse not any? pallets-in-truck [ ; with [ still-not-inventoried = true ] NOT NECCESSARY B THEY DIE
            ask myself [
              set truck-being-served nobody
              set color green
              ;set next-completion-time 0
              ;set next-start-LM-time (ticks + time-between-inventories )
           ]
            reset-truck  self myself;[ truck-being-served ] of myself
        ] ; ask truck-
      ;] ;if tagson
    ] [
        ; have to repeat the inventory of actual pallet
        print "COLLIDE"
        manage-collision nobody ; with myself
      ] ; ifelse (not collide)

    set TM? false
    ;
    ask my-rris [ die ]
    ;set next-start-LM-time (ticks + time-between-inventories )
    ;
    let change? empty? filter [? -> ? <= cycle ] [cycle] of other readers
    set cycle (cycle + 1)
    ;
    if change? [
      let init-time-of-this-cycle last first (filter [? -> first ? = (cycle - 1) ] cycle-init-time)
      set cycle-time (ticks - init-time-of-this-cycle)
      ;show (word "cycle-time= " cycle-time " , [who cycle]= " [(list who cycle)] of self)
      set min_cycle (min [cycle] of readers)
      set max_cycle (max [cycle] of readers)
      file-open cycle-file
      file-write (cycle - 1) ;ticks init-time-of-this-cycle cycle-time (min [cycle] of readers) (max [cycle] of readers)
      file-write ( ticks )
      file-write init-time-of-this-cycle
      file-write cycle-time
      file-write min_cycle
      file-write max_cycle
      file-print ""
      file-close
      ;
      set ctc cycle
      set c1 ticks
      set c0  init-time-of-this-cycle
      set c1-c0 cycle-time

    ]
    ;
    set next-start-LM-time ( cycle * time-between-inventories )
    set tag-selection-filter ( tag-selection-filter + 1 )
    ; next the selection come back to the first group of tags
    if ( tag-selection-filter = num-tag-groups ) [ set tag-selection-filter 0 ]
  ] ; ask ?reader

  ; arrive ; new truck with same num tags OR...
  ; let live the truck, put in the queue and with begin-service take it again
  ;set total-inventory-cycles ( total-inventory-cycles + 1 ) ; one cycle more is made
  begin-service "1" ; Note that begin-service is made even when there are collision or the pallet is not finished
end

; to report te supervisor with the first
to-report next-supervisor
  report (min-one-of
    ( supervisors with [ next-lookup-time >= ticks ] )
    [ next-lookup-time ] )
end

;; Reports the busy reader with the earliest start-LM-time.
;; considering the state of the reader (contention?, LM?)
to-report next-reader-LM
  report (min-one-of
      (readers with [ ( not LM? ) and (next-start-LM-time >= ticks) ])
      ;(readers with [ is-agent? pallet-being-served and ( not LM? ) and (next-start-LM-time >= ticks) ])
    [ next-start-LM-time ])
end

;; Reports the busy reader with the earliest start-TM-time.
to-report next-reader-TM
  report (min-one-of
    ;(readers with [ is-agent? pallet-being-served and (LM? or contention? )
    (readers with [ is-agent? truck-being-served and
      (LM? or contention?) and
      (next-start-TM-time >= ticks) ]) [ next-start-TM-time ])
end

;; Reports the busy reader with the earliest scheduled completion.
to-report next-reader-complete
  report (min-one-of
    (readers with [is-agent? truck-being-served and TM?
      and (next-completion-time >= ticks) ]) [next-completion-time])
end

;; Reports the busy reader with the earliest start-LM-time.
;; considering the state of the reader (contention?, LM?)
to-report next-checkout-LM
  report (min-one-of
      (checkouts with [ is-agent? chart-being-served and ( not LM? ) and (next-start-LM-time >= ticks) ])
    [ next-start-LM-time ])
end

;; Reports the busy reader with the earliest start-TM-time.
to-report next-checkout-TM
  report (min-one-of
    (checkouts with [ is-agent? chart-being-served and (LM? or contention? )
      and (next-start-TM-time >= ticks) ]) [ next-start-TM-time ])
end

to-report next-checkout-complete
  report (min-one-of
    ( checkouts with [is-agent? chart-being-served and TM?
      and (next-completion-time >= ticks) ]) [next-completion-time])
end

to write-system-time [ S T tg-inv]
  let W (T - S)
  file-open sys-time-file
  ;file-write T file-write W file-write S file-write tg-inv file-write (count my-tags) file-print ""
  file-write ticks file-write T file-write W file-write S file-write tg-inv file-print ""
  file-close
end

;; Updates time-in-system statistics, removes current pallet or truck agent, returns
;; the server to the idle state, and attempts to start service on another
;; pallet or truck.
to complete-service-chk [ ?checkout ]
  ask ?checkout [
    ifelse not collide? [
      let tagson my-tags with [ not inventoried? ]
      if not any? tagson [
        set total-time-in-system-chk (total-time-in-system-chk + ticks
          - one-of [time-entered-queue] of my-tags) ; [time-entered-queue] of one-of my-tags
        ;set total-system-throughput (total-system-throughput + count my-tags) ; this is from before the including outages of tags
        set total-outages ( total-outages + count my-tags with [ (outage-count-of-this-tag >= max-num-of-outages) ] )
        let my-tags-inventoried count ( my-tags with [ inventoried? and (outage-count-of-this-tag < max-num-of-outages) ] )
        set total-system-throughput-chk ( total-system-throughput-chk + my-tags-inventoried )
        set total-charts-throughput (total-charts-throughput + 1)
        write-system-time (ticks - one-of [time-entered-service] of my-tags) (ticks - one-of [time-entered-queue] of my-tags) (my-tags-inventoried) ; S and T and #my-tags
        ask my-tags [ die ]
        set my-tags nobody
        ask chart-being-served [ die ]
        set chart-being-served nobody
        ask my-rris [ set color 5 ] ;default color of link

        set color green
        set next-completion-time 0
        set next-start-LM-time (ticks + TM-to-LM-time)

;        ask truck-being-served [
;          ifelse not any? pallets-in-truck [ ; with [ still-not-inventoried = true ] NOT NECCESSARY B THEY DIE
;            ask myself [
;              set truck-being-served nobody
;              set color green
;              set next-completion-time 0
;            ]
;            ask self [ die ]
;          ] [
;            ; re-schedule the start-LM-time
;            ask myself [ set next-start-LM-time (ticks + TM-to-LM-time) ]
;            ; set a new pallet in the reader is made in begin service
;          ]
;        ] ; ask truck-

      ]
    ] [
        ; have to repeat the inventory of actual pallet
        manage-collision nobody ; with myself
      ]
    set TM? false
  ]
  begin-service-chk ; Note that begin-service is made even when there are collision or the pallet is not finished
end


to update-usage-stats [event-time] ;event-time is the next event time <<--OJO with NAMES
  let delta-time (event-time - ticks)
  let busy-readers (readers with [is-agent? truck-being-served])
  let busy-checkouts ( checkouts with [ is-agent? chart-being-served ] )
  let in-queue (length queue)
  let in-queue-chk (length queue-chk)
  let in-process (count busy-readers)
  let in-process-chk (count busy-checkouts)
  let in-system (in-queue + in-process)
  let in-system-chk (in-queue-chk + in-process-chk)
  set total-truck-queue-time
    (total-truck-queue-time + delta-time * in-queue)
  set total-chart-queue-time
    (total-chart-queue-time + delta-time * in-queue-chk)
  set total-truck-service-time
    (total-truck-service-time + delta-time * in-process)
  set total-chart-service-time
    (total-chart-service-time + delta-time * in-process-chk)
  ;
  tick-advance (event-time - ticks)
  update-plots
end

;;; Updates the usage/utilization statistics and advances the clock to the
;;; specified event time.
;to update-usage-stats [event-time] ;event-time is the next event time <<--OJO with NAMES
;  let delta-time (event-time - ticks)
;  let busy-readers (readers with [is-agent? truck-being-served])
;  let in-queue sum [(length queue-r)] of readers
;  let in-process (count busy-readers)
;  let in-system (in-queue + in-process)
;  set total-truck-queue-time
;    (total-truck-queue-time + delta-time * in-queue)
;  set total-truck-service-time
;    (total-truck-service-time + delta-time * in-process)
;  tick-advance (event-time - ticks)
;;  if total-inventory-cycles [
;;    ; beggining of a new cycle
;;    set cycle-init-time ticks
;;  ]
;;  let max-cycle max [cycle] of readers
;;  if all? readers [cycle = max-cycle] and (max-cycle > 0) [
;;    set cycle-end-time ticks
;;    set cycle-time (cycle-end-time - cycle-init-time)
;;    print cycle-time
;;  ]
;
;  ;update-plots
;end

to reset-stats
  set total-truck-queue-time 0
  set total-truck-service-time 0
  set total-time-in-queue 0
  set total-time-in-system 0
  set total-queue-throughput 0
  set total-system-throughput 0
  set stats-start-time ticks
end

;; To set names to the final reporters of BS Experiments
to make-final-results
  set total-system-throughput-sg (total-system-throughput / (ticks - stats-start-time))
  set total-pallets-thoughput-sg ( total-pallets-thoughput / (ticks - stats-start-time))
  set total-tags-inventoried  total-system-throughput
  set reader-utilization-percent (100 * total-truck-service-time / (ticks - stats-start-time) / count readers)
  set avg-queue-length ( total-truck-queue-time / (ticks - stats-start-time) )
  set final-length-queue (length queue-chk)
  set total-num-arrivals arrival-count
  set avg-time-queue-of-tags ( total-time-in-queue / total-queue-throughput )
  set avg-time-in-system-of-tags ( total-time-in-system / total-system-throughput )
  set total-simulation-time-sg ticks
  set mean-num-collisions-sg ( mean [ num-of-collisions ] of readers / (ticks - stats-start-time) )
  set total-num-of-collisions ( sum [ num-of-collisions ] of readers )
  ;; Network
  set mean-num-links ( mean  [ count my-rris] of readers )
  ;;
  set final-known-tag-ratio (count tags with [inventoried-first?]) / count tags
  set final-mean-efficiency (mean [efficiency] of readers) * 100
  set fsa-sum-throughput (sum [throughput] of readers)
  set fsa-mean-throughput (mean [throughput] of readers)
end


;; Ends the execution of the simulation. In fact, this procedure does nothing,
;; but is still necessary. When the associated event is the first in the event
;; queue, the clock will be updated to the simulation end time prior to this
;; procedure being invoked; this causes the go procedure to stop on the next
;; iteration.
to end-run
  ; Do nothing
end



; ---- EXAMPLES------------------
;  ask (turtle-set [[tags] of pallets-in-truck] of current-truck) [ fd random-float 15 ]
;  ;ask (turtle-set [[tags] of pallets-in-truck] of current-truck) [ fd random-float 15 ]
;  show count (turtle-set [[tags] of pallets-in-truck] of truck 0)
;  ask truck 0[
;    ask one-of pallets-in-truck [
;      ask tags-in-pallet [
;        set shape "x" ]]
;  ]
;  ask one-of pallets-in-truck with [still-not-inventoried = true] [
;    ask tags-in-pallet [
;      set shape "x" ] ]
@#$#@#$#@
GRAPHICS-WINDOW
210
10
824
625
-1
-1
6.0
1
10
1
1
1
0
0
0
1
-50
50
-50
50
1
1
1
ticks
30.0

SLIDER
5
61
177
94
num-readers
num-readers
1
200
16.0
1
1
NIL
HORIZONTAL

SLIDER
5
98
196
131
interf-rri-radius
interf-rri-radius
0
300
100.0
1
1
[m]
HORIZONTAL

BUTTON
141
25
207
58
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
6
282
129
315
new-netw?
new-netw?
0
1
-1000

TEXTBOX
13
10
160
52
world is 100x100 patches\neach patch is 10m and \noccupies 6 pixels
11
0.0
1

SLIDER
3
367
175
400
Q
Q
1
15
4.0
1
1
NIL
HORIZONTAL

BUTTON
72
413
135
446
GO!
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
5
462
70
507
tot cs /s
mean [cs-t] of readers / ticks
1
1
11

MONITOR
71
462
136
507
tot ce /s
mean [ce-t] of readers / ticks
1
1
11

MONITOR
140
461
205
506
tot cc /s
mean [cc-t] of readers / ticks
1
1
11

MONITOR
5
518
79
563
Efficiency %
precision ((mean [efficiency] of readers) * 100) 4
17
1
11

MONITOR
89
518
207
563
Thorughput tgs/ms
precision ((sum [throughput] of readers) * 0.001) 4
17
1
11

MONITOR
139
409
203
454
#frames
mean [ frame ] of readers
1
1
11

MONITOR
6
571
110
616
Total TM-time (s)
precision ((mean [TM-time] of readers) ) 3
3
1
11

SLIDER
835
11
1096
44
mean-arrival-rate
mean-arrival-rate
0.001
30
0.731
0.01
1
per tick
HORIZONTAL

SLIDER
1115
10
1299
43
max-run-time
max-run-time
0
1000000
1000000.0
1
1
seconds
HORIZONTAL

BUTTON
4
413
67
446
Next
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1187
86
1279
131
Current time
ticks
5
1
11

MONITOR
1176
132
1281
177
Next arrival time
next-arrival-time
3
1
11

MONITOR
1202
220
1298
265
Queue length
length queue
3
1
11

SLIDER
835
37
1062
70
mean-pallets-per-truck
mean-pallets-per-truck
0
50
32.0
1
1
pallets
HORIZONTAL

SLIDER
1080
44
1308
77
mean-tags-per-pallet
mean-tags-per-pallet
1
250
63.0
1
1
tags
HORIZONTAL

MONITOR
832
498
949
543
Avg. Queue Length
total-truck-queue-time / (ticks - stats-start-time)
3
1
11

MONITOR
955
497
1070
542
Avg. Time in Queue
total-time-in-queue / total-queue-throughput
3
1
11

MONITOR
1074
497
1192
542
Avg. Time in System
total-time-in-system / total-system-throughput
3
1
11

MONITOR
987
543
1146
588
Tot.System Throughput /s
total-system-throughput-chk / ( ticks )
4
1
11

MONITOR
848
543
981
588
Reader Utilization %
100 * total-truck-service-time / (ticks - stats-start-time) / count readers
3
1
11

MONITOR
113
571
195
616
#Collisions
sum [num-of-collisions] of readers
17
1
11

CHOOSER
6
319
144
364
size-of-frame
size-of-frame
"SFSA" "DFSA"
1

MONITOR
1202
269
1299
314
Num. Arrivals
arrival-count
17
1
11

TEXTBOX
11
633
201
677
- Links Green: one of both ends has TM?\n- Links Red: both ends has TM? -> contention
9
0.0
1

TEXTBOX
1216
204
1294
222
OF TRUCKS
11
0.0
1

TEXTBOX
849
477
915
495
OF TRUCKS
11
0.0
1

TEXTBOX
960
471
1070
513
OF TAGS until pallet is \nput in service
9
0.0
1

TEXTBOX
1084
471
1194
499
OF TAGS until pallet is\ncompleted
9
0.0
1

SLIDER
4
167
205
200
max-time-of-tag-powered
max-time-of-tag-powered
0
15
3.5
0.1
1
s
HORIZONTAL

TEXTBOX
6
255
216
283
ON : new network and save in 'locations.txt'\nOFF: load network from 'locations.txt'
9
0.0
1

BUTTON
838
591
936
624
Reset Stats
reset-stats
NIL
1
T
OBSERVER
NIL
R
NIL
NIL
1

MONITOR
1150
543
1288
588
Tot. Num. Tags Inventoried
total-system-throughput
3
1
11

MONITOR
213
630
387
671
Mean Num Interf. Links per node
mean  [ count my-rris] of readers
2
1
10

TEXTBOX
7
204
204
248
When a pallet has many tags, e.g. 850, the time to inventory is greater than the max-time-of-tag-powered
9
0.0
1

SWITCH
11
708
150
741
two-readers?
two-readers?
1
1
-1000

TEXTBOX
14
680
164
702
two-readers? 'On' means we use two extreme readers
9
0.0
1

MONITOR
1181
588
1291
633
tags with 1 outage
tags-with-one-outage
17
1
11

MONITOR
1180
631
1299
676
tags with 2 outages
tags-with-two-outage
17
1
11

MONITOR
998
589
1167
634
Slots with 1 tag and error
tag-unique-with-errors
17
1
11

MONITOR
989
635
1166
672
Slots with >1 tags and 1 is Decoded
tag-with-interf-decod-well
17
1
9

SLIDER
829
73
1075
106
min-power-to-feed-tag-IC
min-power-to-feed-tag-IC
-25
-10
-17.0
0.5
1
dBm
HORIZONTAL

MONITOR
1161
684
1337
721
Slots with >1 decoded bad
tag-with-interf-decod-bad
17
1
9

TEXTBOX
831
109
999
142
TAG SENSITIVITY\nGriffin has set -13 dBm in his paper\nImpnj Monza 4 has -17dBm
9
0.0
1

SWITCH
401
631
574
664
random-topology?
random-topology?
1
1
-1000

SLIDER
434
667
589
700
distance-var-x
distance-var-x
0
40
5.0
1
1
(m)
HORIZONTAL

MONITOR
1200
499
1342
540
Total Pallet Throughput /s
total-pallets-thoughput / ticks
4
1
10

TEXTBOX
1352
684
1502
706
max-num-of-outages = 5\nnot 2
9
0.0
1

MONITOR
830
633
978
678
Tot.System Outages / s
total-outages / ticks
4
1
11

SLIDER
835
144
1007
177
sigma
sigma
0
5
1.94
0.1
1
NIL
HORIZONTAL

SLIDER
834
179
1054
212
ceiling-to-floor-distance
ceiling-to-floor-distance
1.8
30
5.1
0.05
1
m
HORIZONTAL

SLIDER
834
261
1060
294
time-between-inventories
time-between-inventories
1
60
10.0
1
1
[ s ]
HORIZONTAL

TEXTBOX
1040
140
1138
173
In this case we have \nthe transceivers\n in-ceiling
9
0.0
1

CHOOSER
834
214
988
259
num-pallets-by-side
num-pallets-by-side
1 2 3 4 5 6 7
0

SLIDER
776
713
1080
746
mean-departure-rate
mean-departure-rate
0.0001
0.01
0.0034
0.001
1
per tick
HORIZONTAL

MONITOR
777
760
897
805
Next Depart. time
next-departure-time
6
1
11

SLIDER
901
753
1080
786
max-order-percent
max-order-percent
1
50
20.0
1
1
%
HORIZONTAL

MONITOR
778
809
894
854
Total departures
total-departures
17
1
11

MONITOR
911
794
1059
839
Total inventory cycles
total-inventory-cycles
17
1
11

SLIDER
781
678
970
711
minimum-stock-level
minimum-stock-level
10
80
75.0
1
1
%
HORIZONTAL

SLIDER
1069
794
1309
827
max-inventory-cycles
max-inventory-cycles
50
5000
5000.0
5
1
cycles
HORIZONTAL

SLIDER
501
810
737
843
mean-lookup-rate
mean-lookup-rate
0
0.01
0.0056
0.0001
1
per tick
HORIZONTAL

SLIDER
503
845
675
878
num-supervisors
num-supervisors
1
100
1.0
1
1
NIL
HORIZONTAL

MONITOR
380
773
501
818
NIL
total-lookup-errors
17
1
11

MONITOR
403
820
500
865
NIL
total-lookups
17
1
11

MONITOR
255
819
399
864
failed lookup probability
total-lookup-errors / total-lookups
5
1
11

MONITOR
616
883
733
928
next lookup time
[ next-lookup-time] of super
5
1
11

SLIDER
746
937
1031
970
mean-reorganization-rate
mean-reorganization-rate
0
0.01
0.0011
0.0001
1
per tick
HORIZONTAL

MONITOR
1037
931
1150
976
Next reorg. time
next-reorganization-time
4
1
11

SWITCH
1036
895
1177
928
swap-pallets?
swap-pallets?
0
1
-1000

SLIDER
516
778
688
811
max-lookups
max-lookups
10
5000
400.0
10
1
NIL
HORIZONTAL

TEXTBOX
1341
768
1410
786
Pallet Shape
11
0.0
1

SLIDER
1324
791
1462
824
p-width
p-width
0.2
1.5
0.82
0.01
1
[m]
HORIZONTAL

SLIDER
1324
829
1463
862
p-depth
p-depth
0.2
1.5
1.2
0.01
1
[m]
HORIZONTAL

SLIDER
1324
867
1468
900
p-height
p-height
0.4
2.5
2.0
0.01
1
[m]
HORIZONTAL

MONITOR
1153
930
1246
975
Total reorgs.
total-swaps
17
1
11

MONITOR
992
214
1074
259
NIL
diameter-x
17
1
11

MONITOR
1066
214
1147
259
NIL
diameter-y
17
1
11

TEXTBOX
1327
904
1444
932
Each boxes layer has 0.4m height
11
0.0
1

MONITOR
778
853
895
898
NIL
total-p-arrivals
17
1
11

SLIDER
201
771
376
804
num-tag-groups
num-tag-groups
1
8
1.0
1
1
[groups]
HORIZONTAL

MONITOR
912
842
986
887
max cycle
max [cycle] of readers
17
1
11

MONITOR
501
882
611
927
Known tag ratio
precision ((count tags with [inventoried-first?]) / count tags) 4
17
1
11

TEXTBOX
1082
748
1173
789
not usable \nin this version \nof simulator
11
0.0
1

SLIDER
1319
940
1465
973
p-base
p-base
0.1
0.4
0.15
0.01
1
[m]
HORIZONTAL

TEXTBOX
1082
721
1205
743
Shipped pallets are 8\neach 10 min (0.0017)
9
0.0
1

TEXTBOX
740
974
1034
992
Reorganization of a random unif number of the pallets assigned to a reader
8
0.0
1

MONITOR
778
901
904
938
Total times of p arrivals
moments-of-arrivals
2
1
9

SLIDER
432
703
592
736
distance-var-y
distance-var-y
0
70
5.0
1
1
(m)
HORIZONTAL

SWITCH
583
632
686
665
close?
close?
1
1
-1000

SLIDER
597
668
759
701
readers-per-row
readers-per-row
1
80
5.0
1
1
NIL
HORIZONTAL

SLIDER
596
703
759
736
readers-per-column
readers-per-column
1
50
9.0
1
1
NIL
HORIZONTAL

TEXTBOX
217
684
321
739
CLOSE:\ndistance-var-x 1\ndistance-var-x 1\nreaders-per-row 20\nreaders-per-column 5
9
0.0
1

TEXTBOX
322
683
429
738
FAR: \n distance-var-x 12\n distance-var-x 22\n readers-per-row 8\n readers-per-column 5
9
0.0
1

SLIDER
832
296
1004
329
incli_tx_rx
incli_tx_rx
0
90
0.0
1
1
degrees
HORIZONTAL

SLIDER
1013
296
1171
329
height_tx_rx
height_tx_rx
0
5
0.0
0.1
1
(m)
HORIZONTAL

SLIDER
833
333
1026
366
reader-sensitivity-g
reader-sensitivity-g
-120
-40
-80.0
1
1
dBm
HORIZONTAL

TEXTBOX
1477
800
1525
818
tag-x
9
0.0
1

TEXTBOX
1475
838
1503
856
tag-y
9
0.0
1

TEXTBOX
1477
877
1503
895
tag-z
9
0.0
1

TEXTBOX
1345
19
1481
63
physical world distance between readers\nInterferences depends on this parameter
9
0.0
1

SLIDER
1313
67
1542
100
distance-multiplicative
distance-multiplicative
1
100
2.0
1
1
[x m]
HORIZONTAL

SLIDER
1313
103
1506
136
interf-threshold
interf-threshold
-140
-40
-96.0
1
1
dBm
HORIZONTAL

TEXTBOX
1320
141
1470
185
 tx_pw     ->     Threshold\n[0:100mW]         <=-83dBm\n[101:500mW]     <=-90dBm\n[0.501:2W]         <=-96dBm
9
0.0
1

SLIDER
1316
193
1501
226
transmitter-power
transmitter-power
0
4
0.8
0.01
1
W
HORIZONTAL

SLIDER
1247
457
1479
490
min-tag-inclination-angle
min-tag-inclination-angle
0
90
22.0
1
1
degrees
HORIZONTAL

SWITCH
1382
242
1513
275
two-height?
two-height?
1
1
-1000

CHOOSER
1377
275
1515
320
scenario
scenario
"a" "b" "c" "d" "e" "f" "cycle_10" "cycle_20" "cycle_30" "cycle_40" "cycle_50" "cycle_60" "cycle_70" "cycle_80" "cycle_90" "cycle_100" "cycle_120" "cycle_140" "cycle_160" "cycle_180" "cycle_200" "test"
9

SWITCH
1353
492
1481
525
tag-in-top?
tag-in-top?
0
1
-1000

CHOOSER
1354
547
1492
592
interference-type
interference-type
"0" "1" "2"
2

TEXTBOX
1355
599
1527
634
\"0\" no interference\n\"1\" interference in a radius (100m)\n\"2\" interference model
9
0.0
1

SWITCH
34
828
172
861
stop-by-cycles?
stop-by-cycles?
1
1
-1000

TEXTBOX
37
863
187
896
Stop condition is by a number of lookups except when stop-by-cycles? is true
9
0.0
1

MONITOR
463
931
613
972
Current inventoried tags
precision ((count tags with [inventoried?]) / count tags) 4
17
1
10

SLIDER
4
132
176
165
num-checkouts
num-checkouts
0
100
4.0
1
1
NIL
HORIZONTAL

SLIDER
164
915
419
948
number-of-contention-intervals
number-of-contention-intervals
3
400
50.0
1
1
NIL
HORIZONTAL

SLIDER
833
368
1005
401
portal-width
portal-width
0.5
10
2.0
0.1
1
m
HORIZONTAL

SLIDER
1141
368
1270
401
height_1_tx
height_1_tx
0.1
4
1.2
0.1
1
m
HORIZONTAL

TEXTBOX
1146
348
1219
366
Portal LEFT
11
0.0
1

SLIDER
1271
368
1396
401
height_2_tx
height_2_tx
0.1
4
1.2
0.1
1
m
HORIZONTAL

TEXTBOX
1275
349
1354
367
Portal RIGHT
11
0.0
1

SLIDER
1141
402
1271
435
height_2_rx
height_2_rx
0
4
1.0
0.1
1
m
HORIZONTAL

SLIDER
1272
402
1398
435
height_1_rx
height_1_rx
0
4
1.0
0.1
1
m
HORIZONTAL

SWITCH
839
415
965
448
dislocated?
dislocated?
1
1
-1000

SLIDER
1010
369
1143
402
incli_1tx
incli_1tx
0
90
15.0
1
1
degrees
HORIZONTAL

SLIDER
1008
403
1142
436
incli_2rx
incli_2rx
0
90
15.0
1
1
degrees
HORIZONTAL

SLIDER
1396
368
1533
401
incli_2tx
incli_2tx
0
90
15.0
1
1
degrees
HORIZONTAL

SLIDER
1399
402
1538
435
incli_1rx
incli_1rx
0
90
15.0
1
1
degrees
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="i0_f" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;0&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="1" last="14"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;f&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i1_f" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="1" last="14"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;f&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i2_f" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="1" last="14"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;f&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="g2_f" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4.5" step="1" last="11.5"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;f&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="g2_a" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="0.5" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="g2_b" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="0.5" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;b&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="g2_c" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="0.5" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;c&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="g2_d" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="0.5" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;d&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="g2_e" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="0.5" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;e&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i2_cycles" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_80&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i0_cycles" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;0&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_10&quot;"/>
      <value value="&quot;cycle_20&quot;"/>
      <value value="&quot;cycle_30&quot;"/>
      <value value="&quot;cycle_40&quot;"/>
      <value value="&quot;cycle_50&quot;"/>
      <value value="&quot;cycle_60&quot;"/>
      <value value="&quot;cycle_70&quot;"/>
      <value value="&quot;cycle_80&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i1_cycles" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_10&quot;"/>
      <value value="&quot;cycle_20&quot;"/>
      <value value="&quot;cycle_30&quot;"/>
      <value value="&quot;cycle_40&quot;"/>
      <value value="&quot;cycle_50&quot;"/>
      <value value="&quot;cycle_60&quot;"/>
      <value value="&quot;cycle_70&quot;"/>
      <value value="&quot;cycle_80&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i0_cycles_607080" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;0&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_60&quot;"/>
      <value value="&quot;cycle_70&quot;"/>
      <value value="&quot;cycle_80&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i1_cycles_80" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_80&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="perror_0" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;0&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="0.5" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_60&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="perror_1" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="0.5" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_60&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="perror_2" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="0.5" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_60&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i1_cycles_100r" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_10&quot;"/>
      <value value="&quot;cycle_20&quot;"/>
      <value value="&quot;cycle_30&quot;"/>
      <value value="&quot;cycle_40&quot;"/>
      <value value="&quot;cycle_50&quot;"/>
      <value value="&quot;cycle_60&quot;"/>
      <value value="&quot;cycle_70&quot;"/>
      <value value="&quot;cycle_80&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i0_a" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;0&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="1" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i1_a" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="1" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;a&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i0_b" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;0&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="1" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;b&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i1_b" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="1" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;b&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i0_c" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;0&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="1" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;c&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i1_c" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="1" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;c&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i0_d" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;0&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="1" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;d&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i1_d" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="1" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;d&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="perror_1_80radius" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="0.5" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_60&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="perror_2b" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="6" step="0.5" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_60&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="perror_2c" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="8" step="0.5" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_60&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="perror_2d" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="8.5" step="0.5" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_60&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="perror_2_55" repetitions="6" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="5.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_60&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="perror_2_75" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0022"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="7.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;cycle_60&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i1_c912" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="9" step="1" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;c&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i2_c" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="1" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;c&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i2_d" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="1" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;d&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="i2_b" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>diameter-x</metric>
    <metric>diameter-y</metric>
    <metric>ceiling-to-floor-distance</metric>
    <metric>total-lookup-errors</metric>
    <metric>total-lookups</metric>
    <metric>total-departures</metric>
    <metric>total-p-arrivals</metric>
    <metric>total-inventory-cycles</metric>
    <metric>total-swaps</metric>
    <metric>total-initial-tags</metric>
    <metric>p-width</metric>
    <metric>p-depth</metric>
    <metric>p-height</metric>
    <metric>total-outages</metric>
    <metric>total-num-of-collisions</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>reader-utilization-percent</metric>
    <metric>final-known-tag-ratio</metric>
    <metric>final-mean-efficiency</metric>
    <metric>fsa-mean-throughput</metric>
    <metric>fsa-sum-throughput</metric>
    <metric>ctc</metric>
    <metric>c1</metric>
    <metric>c0</metric>
    <metric>c1-c0</metric>
    <metric>min_cycle</metric>
    <metric>max_cycle</metric>
    <enumeratedValueSet variable="Q">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0017"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.041"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tag-in-top?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_tx_rx">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interference-type">
      <value value="&quot;2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stop-by-cycles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-17"/>
    </enumeratedValueSet>
    <steppedValueSet variable="ceiling-to-floor-distance" first="4" step="1" last="12"/>
    <enumeratedValueSet variable="readers-per-column">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="0.82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0011"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;b&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-height?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
