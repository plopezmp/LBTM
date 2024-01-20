;; _REF:  NOW WE MAKE CONTROL WITH UTILITY (NOT DELTAS THRESHOLDS)
;; Differs respect 10m in replenish-stands as a task here
;; With respect 9m model chages the SNIR computation
;; 4) under construction a discrete event LBT, 6-12-2017
;; 5) I have realize that we must indicate clearly the end of TM
;; 6) I am going to adjust the "time to complete"
;; 7) compute the time to complete a group of tags redings
;; 8) going to change GO and add discrete event engine
;; 9) change begin-service
;; TEST1 is to test max-TM = 4s
;; THIS IS EQUAL TO FSA_CON_6 BUT WITH PALLET REORGANIZATION

;; There is a Pc capture and prob error.
;; The prob of capture is (1/2)^(s-1)
;; new from _03 : Power Outage
;; tags-loose-memory ----counting
;; efficiency = cs/(K)
;; TEST CONTINUOUS INVENTORY
;;
breed [ readers reader ]
;breed [ readers reader ]
breed [ checkouts checkout ]
breed [ charts chart ]
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
  ;reader-height_1 ; h1 even frame
  ;reader-height_2 ; odd frame
  reader-gain-tx-rx ;
  reader-frequency  ; reader carrier frequency
  reader-sensitivity
  reader-read-error
  reader-outage-count
  even-frame? ; to know alternative frames: even h1=1.4 and odd h1= 2.2
  cycle ; count the periodic reading cycles of a block of pallets
  cycle-last-epoch
  tag-selection-filter ; to select a group of tags, each cycle one different
  ; the number of groups depends on the global interface variable 'num-tag-groups'
  delta ; is the minimum number of contention trials
  ;
  reader-type ; "io-type" "inventory-type" "sensing-type"
  ;
  reader-visitor-detect-count
  reader-visitors-die
  reader-pe-io
  group-count ; only in 'io' to count components of a group
  group-detect-count
  group-pe-io
  reader-utl
  reader-utl-from-start
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
  checkout-outage-count
  even-frame? ; to know alternative frames: even h1=1.4 and odd h1= 2.2
  delta ; is the minimum number of contention trials
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
  in-chart? ; 'true' if it goes in a chart, 'false' otherwise
  sensor?
  sample-count
  tag-die-time ; only for the visitors
  ;my-pallet
  ;my-reader
  person?
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
  ;
  ;now the entrance of visitors and departure
  next-p-arrival-time
  next-p-departure-time
  ;
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
  p-arrival-task
  p-departure-task
  tags-die-task
  ;;;
  ;;variables for BS reporters
  total-system-throughput-sg
  total-charts-thoughput-sg
  total-tags-inventoried
  ;; next 2 vars to get the average ratio
  ;total-tags-singulated-sim
  ;total-tags-sim
  average-inv-ratio
  inv-count
  ;pallets-in-queue
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
  ;
  total-visitor-arrivals
  total-visitor-departures
  total-visitors-die
  visitor-detect-count
  ;
  avg-cycles-of-sns
  avg-cycles-of-io
  avg-cycles-of-inv
  pb-error
  ;
  avg-f-inv
  avg-f-io
  avg-f-sns
  f-count
  avg-utl
  utl
  utl-sns
  ult-io
  utl-inv
  avg-pe-io
  ;
  sns-file
  io-file
  inv-file
  utl-file
]

;to startup
;  setup
;end

to setup-timeconstants
  set t1S 0.00283 set t1C 0.00074 set t1E 0.00046 ; slot 1 of PQuery
  set tS 0.00258 set tC 0.00049 set tE 0.00021 ; slots 2..K of QRep
  ;set min-LM 0.005
  set min-LM LM-group
  set max-TM 4 set TM-to-LM-time 0.1 ; time limits for each mode NOW 0, BEFORE 0.1 as standards
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
  set xy-file (word "_readers-xy-" num-readers ".txt")
  set xy-file-chk (word "_checkouts-xy-" num-checkouts ".txt")
  ;set queue-file (word "queue-length-" num-readers "-" mean-departure-rate "-" mean-tags-per-pallet "-" num-pallets-by-side "-" max-order-percent "-" time-between-inventories "-" ceiling-to-floor-distance ".txt")
;  set queue-file (word "queue-length-" num-checkouts "-" num-readers "-" minimum-stock-level "-" time-between-inventories "-" num-of-content-intervals-inv num-of-content-intervals-io num-of-content-intervals-sns
;     "-" behaviorspace-run-number ".txt")
;  set num-of-queue-samples 0
;  set queue-length (list )
;  ;;
;  ;set p-loss-file (word "p-loss-" num-readers "-" mean-departure-rate "-" mean-tags-per-pallet "-" num-pallets-by-side "-" max-order-percent "-" time-between-inventories "-" ceiling-to-floor-distance "-" behaviorspace-run-number ".txt")
;  set p-loss-file (word "p-loss-" num-checkouts "-" num-readers "-" minimum-stock-level "-" time-between-inventories "-" num-of-content-intervals-inv num-of-content-intervals-io num-of-content-intervals-sns "-" behaviorspace-run-number ".txt")
;  set p-loss-list (list )
;  if file-exists? p-loss-file [ file-delete p-loss-file ]
;  ;;
;  ;set time-id-first-file (word "t-id-first-" num-readers "-" mean-departure-rate "-" mean-tags-per-pallet "-" num-pallets-by-side "-" max-order-percent "-" time-between-inventories "-" ceiling-to-floor-distance "-" behaviorspace-run-number ".txt")
;  set time-id-first-file (word "t-id-first-" num-checkouts "-" num-readers "-" minimum-stock-level "-" time-between-inventories "-" num-of-content-intervals-inv num-of-content-intervals-io num-of-content-intervals-sns "-" behaviorspace-run-number ".txt")
;  set time-samples-count 0 ; to count the number of samples in the file
;  if file-exists? time-id-first-file [ file-delete time-id-first-file ]
;  ;;
;  ;set known-file (word "known-ratio-" num-readers "-" mean-departure-rate "-" mean-tags-per-pallet "-" num-pallets-by-side "-" max-order-percent "-" time-between-inventories "-" ceiling-to-floor-distance "-" behaviorspace-run-number ".txt")
;  set known-file (word "known-ratio-" num-checkouts "-" num-readers "-" minimum-stock-level "-" time-between-inventories "-" num-of-content-intervals-inv num-of-content-intervals-io num-of-content-intervals-sns "-" behaviorspace-run-number ".txt")
;  if file-exists? known-file [ file-delete known-file ]
;  ;;
;  ;set lookup-file (word "lookup-ratio" "-" num-readers "-" mean-departure-rate "-" mean-tags-per-pallet "-" num-pallets-by-side "-" max-order-percent "-" time-between-inventories "-" ceiling-to-floor-distance "-" behaviorspace-run-number ".txt")
;  set lookup-file (word "lookup-ratio" "-" num-checkouts "-" num-readers "-" minimum-stock-level "-" time-between-inventories "-" num-of-content-intervals-inv num-of-content-intervals-io num-of-content-intervals-sns "-" behaviorspace-run-number ".txt")
;  if file-exists? lookup-file [ file-delete lookup-file ]
;  ;;
;  ;set sys-time-file (word "sys-time-" num-readers "-" num-checkouts "-" mean-departure-rate "-" mean-tags-per-pallet "-" num-pallets-by-side "-" max-order-percent "-" time-between-inventories "-" ceiling-to-floor-distance "-" behaviorspace-run-number ".txt")
;  set sys-time-file (word "sys-time-" num-checkouts "-" num-readers "-" minimum-stock-level "-" time-between-inventories "-" num-of-content-intervals-inv num-of-content-intervals-io num-of-content-intervals-sns "-" behaviorspace-run-number ".txt")
;  if file-exists? sys-time-file [ file-delete sys-time-file ]

  set sns-file (word "sns-" time-of-visitor-covered "-" g1_min "-" g1_max "-" g2_min "-" g2_max"-" g3_min "-" g3_max "-" behaviorspace-run-number ".txt")
  if file-exists? sns-file [ file-delete sns-file ]
  set io-file (word "io-" time-of-visitor-covered "-" g1_min "-" g1_max "-" g2_min "-" g2_max"-" g3_min "-" g3_max "-" behaviorspace-run-number ".txt")
  if file-exists? io-file [ file-delete io-file ]
  set inv-file (word "inv-" time-of-visitor-covered "-" g1_min "-" g1_max "-" g2_min "-" g2_max"-" g3_min "-" g3_max "-" behaviorspace-run-number ".txt")
  if file-exists? inv-file [ file-delete inv-file ]
  set utl-file (word "utl-" time-of-visitor-covered "-" g1_min "-" g1_max "-" g2_min "-" g2_max"-" g3_min "-" g3_max "-" behaviorspace-run-number ".txt")
  if file-exists? utl-file [ file-delete utl-file ]
  ;;
  set queue []
  set queue-chk []
  set next-arrival-time 0
  set next-departure-time 0
  ;now the entrance of visitors and departure
  set next-p-arrival-time 0
  set next-p-departure-time 0
  ;
  set arrival-count 0
  ;set-default-shape readers "square 2" ; circle
  ;set-default-shape checkouts "circle 2" ; circle 2
  ;set-default-shape readers "square 2" ; circl
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
  set fading-factor-fw 1
  set fading-factor-bw 1
  set fading-factor-bw-a 1
  set fading-factor-bw-b 1
  ;set portal-width 5 ; meters or width
  set c 300000000 ; speed of light
  set noise-figure_dB 22
  set noise-density_dBm_Hz -174
  set max-rx-BW 1600000
  set rician-factor_dB 3
  set rician-factor (10 ^ (rician-factor_dB / 10 ) )
  set sigma 1.94 ; This is the sigma for shadowing
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
  set warehouse-capacity ( num-readers * ( num-pallets-by-side ^ 2 ) ) ; number of pallets
  set total-departures 0
  set total-inventory-cycles 0
  set total-lookup-errors 0
  set total-lookups 0
  set maxnum-fail-inventories 10
  set total-swaps 0
  set diameter-x 0 set diameter-y 0
  set total-initial-tags (warehouse-capacity * mean-tags-per-pallet)
  set total-p-arrivals 0 ; number of pallets in an arrival will be a counter
  ;
  set num-known-samples 0
  set moments-of-arrivals 0
  set inv-count 0 ; to compute inv-ratio averaged
end

to setup
  clear-all
  file-close-all
  ;random-seed behaviorspace-run-number
  if not different-seed? [random-seed 100]
  reset-ticks
  reset-stats
  setup-globals
  setup-timeconstants
  ask patches [ set pcolor blue - 3 ]
  setup-readers
  ;setup-checkouts
  set allreaders-set (turtle-set readers checkouts)
  setup-supervisors
  setup-tasks
  ;reset-ticks
  ;reset-stats
  ; now we set de pallets under the reader
  ; with proc arrive for each reader
  setup-tags-under
  ;schedule-arrival
  schedule-departure
  if swap-pallets? and (num-readers > 1) [ schedule-reorganization ]
  ask supervisors [ schedule-lookup ]
  schedule-replenish ; only if replenish is en event-queue
  schedule-p-arrival
  schedule-p-departure
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

;to setup-checkouts
;   ifelse new-netw? [
;    ifelse random-topology? [
;      create-checkouts num-checkouts [
;        set color green ; means idle state 'red' is active
;        setxy random-xcor random-ycor
;        set size 3
;        set cs-t 0 set cc-t 0 set ce-t 0
;        set TM-time 0 set LM-time 0
;        set TM? false
;        set LM? false
;        set contention? false
;        set collide? false
;        set num-of-collisions 0
;        set frame 0
;        set chart-being-served nobody
;        set next-completion-time 0
;        set checkout-gain-tx-rx 5 ; 7dBi
;        set checkout-power-tx 0.8 ; 800 mW, or, 29 dBm
;        set checkout-frequency (865700000) ; center frequency of Ch1
;        set checkout-read-error 0
;        set checkout-outage-count 0
;        set checkout-height_1_tx height_1_tx; _1 even frame
;        set checkout-height_1_rx height_1_rx
;        set checkout-height_2_tx height_2_tx ; _2 odd frame
;        set checkout-height_2_rx height_2_rx
;        set even-frame? false
;        set checkout-sensitivity (10 ^ (sensitivity-in-reader / 10)) / 1000 ;0.1E-10; -80 ;dBm
;        set delta 1
;      ]
;    ] [ spawn-by-row "chk" ]
;    write-readers-xy xy-file-chk "chk" ] [
;    read-readers-xy xy-file-chk "chk" ]
;  ;ask checkouts [ create-rris-with other (turtle-set checkouts readers) in-radius interf-rri-radius ]
;  ask (turtle-set checkouts readers) [ create-rris-with other (turtle-set checkouts readers) in-radius interf-rri-radius ]
;  ;ask rris [ show (10 * link-length) ]
;end

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
        set reader-power-tx 0.8 ; 800 mW, or, 29 dBm
        set reader-frequency (865700000) ; center frequency of Ch1
        set reader-read-error 0
        set reader-outage-count 0
        set even-frame? false
        set cycle 0
        set tag-selection-filter 0 ; [0..num-tag-groups]
        set reader-sensitivity (10 ^ (sensitivity-in-reader / 10)) / 1000 ;0.1E-10; -80 ;dBm
        set delta num-of-content-intervals-inv
      ]
    ] [ spawn-by-row "read" ]
    write-readers-xy xy-file "rd"
  ] [
    ;read-readers-xy xy-file "rd"
  ]
  ;ask (turtle-set checkouts readers) [ create-rris-with other (turtle-set checkouts readers) in-radius interf-rri-radius ]
  ask (readers with [reader-type != "io"] ) [ create-rris-with other readers in-radius interf-rri-radius ]
    ask (readers with [reader-type = "io"]) [ create-rris-with other readers in-radius (interf-rri-radius + dst) ]
  ;ask rris [ show (10 * link-length) ]
end

to spawn-by-row [ tpe ]
  ; Get a range of coordinate values
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
  ;show (list length possible-coords possible-coords)
  ; Use the number of readers to sublist the possible coordinates, and
  ; create a turtle at each of the coordinate combinations left.
  let max-positions length possible-coords
  ;if tpe = "read" [
  if max-positions > (num-readers + num-checkouts) [
    ;set max-positions (num-readers + num-checkouts)
    set max-positions (num-readers + readers-per-row) ; want an extra row
  ]
  if tpe = "read" [
    let use-coords sublist possible-coords 0 (max-positions) ;num-checkouts max-positions
    ;print use-coords
    let room-count 0
    foreach use-coords [
      coords ->
      set room-count (room-count + 1) ;show room-count
      ;if (room-count <= (num-readers / 2)) or (room-count > (num-readers / 2 + readers-per-row)) [
      if (room-count < (floor num-readers / 4)) or ((room-count > (floor num-readers / 4) + 1) and (room-count <= (floor num-readers / 2) ))  or
                                               ((room-count > (num-readers / 2 + readers-per-row)) and (room-count < (num-readers / 2 + readers-per-row + (floor num-readers / 4)))) or (room-count > (num-readers / 2 + readers-per-row + (floor num-readers / 4) + 1) )  [
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
        set reader-power-tx 0.8 ; 800 mW, or, 29 dBm
        set reader-frequency (865700000) ; center frequency of Ch1
        set reader-read-error 0
        set reader-outage-count 0
        set even-frame? false
        set cycle 0
        set tag-selection-filter 0 ; [0..num-tag-groups]
        set reader-sensitivity (10 ^ (sensitivity-in-reader / 10)) / 1000 ;0.1E-10; -80 ;dBm
        set delta num-of-content-intervals-io
        ifelse (room-count <= (num-readers / 2)) [
            set reader-type "inv"
            set shape "square 2"
            set delta num-of-content-intervals-inv
          ] [
            set reader-type "sns"
            set shape "circle 2"
            set delta num-of-content-intervals-sns
          ]
      ] ; create
    ] ; if room-count
      ;
      ;if (room-count = ((num-readers / 2) + 1) + 0 ) or (room-count = (num-readers / 2 + readers-per-row - 0)) [
      ;if (room-count >= ((num-readers / 2) + 1) + 0 ) and (room-count <= (num-readers / 2 + readers-per-row - 0)) [ ; 10R
      ;if (room-count = ((num-readers / 2) + 1) ) or (room-count = (num-readers / 2 + readers-per-row )) [
      ;if (room-count = ((num-readers / 2) + 1) + 0 ) or (room-count = ((num-readers / 2) + 1) + 2 ) or (room-count = ((num-readers / 2) + 1) + 4 ) or (room-count = ((num-readers / 2) + 1) + 6 ) or (room-count = (num-readers / 2 + readers-per-row - 0))
      if (room-count = (floor (num-readers / 4) + 1) + 0 ) or (room-count = ((num-readers / 2) + 1) + 0 ) or (room-count = (num-readers / 2 + readers-per-row - 0))
                or (room-count = (num-readers / 2 + readers-per-row + (floor (num-readers / 4) + 1)) )
      [
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
            set reader-power-tx 0.8 ; 800 mW, or, 29 dBm
            set reader-frequency (865700000) ; center frequency of Ch1
            set reader-read-error 0
            set reader-outage-count 0
            set even-frame? false
            set cycle 0
            set tag-selection-filter 0 ; [0..num-tag-groups]
            set reader-sensitivity (10 ^ (sensitivity-in-reader / 10)) / 1000 ;0.1E-10; -80 ;dBm
            set delta num-of-content-intervals-io
            set reader-type "io"
            set shape "triangle 2"
          ]
      ]

    ] ; foreach
  ] ; if

;  if tpe = "chk" [
;    ;if num-checkouts >= 1 [
;      let use-coords sublist possible-coords 0 (num-checkouts )
;      foreach use-coords [
;        coords ->
;        create-checkouts 1 [
;          set color green ; means idle state 'red' is active
;          setxy item 0 coords item 1 coords
;          ;set shape "dot"
;          set size 3
;          set cs-t 0 set cc-t 0 set ce-t 0
;          set TM-time 0 set LM-time 0
;          set TM? false
;          set LM? false
;          set contention? false
;          set collide? false
;          set num-of-collisions 0
;          set frame 0
;          set chart-being-served nobody
;          set next-completion-time 0
;          set checkout-gain-tx-rx 5 ; 7dBi
;          set checkout-power-tx 0.8 ; 800 mW, or, 29 dBm
;          set checkout-frequency (865700000) ; center frequency of Ch1
;          set checkout-read-error 0
;          set checkout-outage-count 0
;          set checkout-height_1_tx height_1_tx; _1 even frame
;          set checkout-height_1_rx height_1_rx
;          set checkout-height_2_tx height_2_tx ; _2 odd frame
;          set checkout-height_2_rx height_2_rx
;          set even-frame? false
;          set checkout-sensitivity (10 ^ (sensitivity-in-reader / 10)) / 1000 ;0.1E-10; -80 ;dBm
;          set checkout-read-error 0
;          set delta 1
;        ] ; create
;      ] ; foreach
;   ; ];if
;  ] ; if chk
end

to write-readers-xy [ fxy p ]
  if file-exists? fxy [ file-delete fxy ]
  file-open fxy
;  ifelse p = "rd" [
;    ask readers [
;      file-write xcor
;      file-write ycor ]
;    file-close
;  ] [
;    ask checkouts [
;      file-write xcor
;      file-write ycor ]
;    file-close
;  ]
end

;to read-readers-xy [ fxy p ]
;  if file-exists? fxy [
;    file-open fxy
;    ifelse p = "rd" [
;    while [ not file-at-end? ] [
;      create-readers 1 [
;        set color green ; means idle state 'red' is active
;        setxy file-read file-read
;        set size 3
;        set cs-t 0 set cc-t 0 set ce-t 0
;        set TM-time 0 set LM-time 0
;        set TM? false
;        set LM? false
;        set contention? false
;        set collide? false
;        set num-of-collisions 0
;        set frame 0
;        set truck-being-served nobody
;        set pallet-being-served nobody
;        set next-completion-time 0
;        set reader-gain-tx-rx 5 ; 7dBi
;        set reader-power-tx 0.8 ; 800 mW, or, 29 dBm
;        set reader-frequency (865700000) ; center frequency of Ch1
;        set reader-read-error 0
;        set reader-outage-count 0
;        set even-frame? false
;        set cycle 0
;        set tag-selection-filter 0 ; [0..num-tag-groups]
;        set reader-sensitivity (10 ^ (sensitivity-in-reader / 10)) / 1000 ;0.1E-10; -80 ;dBm
;        set delta 1
;      ] ; create
;    ] ;while
;    ] [
;      while [ not file-at-end? ] [
;        create-checkouts 1 [
;          set color green ; means idle state 'red' is active
;          setxy file-read file-read
;          ;set shape "dot"
;          set size 3
;          set cs-t 0 set cc-t 0 set ce-t 0
;          set TM-time 0 set LM-time 0
;          set TM? false
;          set LM? false
;          set contention? false
;          set collide? false
;          set num-of-collisions 0
;          set frame 0
;          set chart-being-served nobody
;          set next-completion-time 0
;          set checkout-gain-tx-rx 5 ; 7dBi
;          set checkout-power-tx 0.8 ; 800 mW, or, 29 dBm
;          set checkout-frequency (865700000) ; center frequency of Ch1
;          set checkout-read-error 0
;          set checkout-outage-count 0
;          set checkout-height_1_tx height_1_tx; _1 even frame
;          set checkout-height_1_rx height_1_rx
;          set checkout-height_2_tx height_2_tx ; _2 odd frame
;          set checkout-height_2_rx height_2_rx
;          set even-frame? false
;          set checkout-sensitivity (10 ^ (sensitivity-in-reader / 10)) / 1000 ;0.1E-10; -80 ;dBm
;          set checkout-read-error 0
;          set delta 1
;        ] ; create
;      ] ;while
;    ]
;    file-close
;  ]
;end


to-report random-tween-uniform [ a b ]
     report ( a + random (b - a + 1) )
end

to-report random-tween [ a b ]
     report a + random-float (b - a)
end

to-report frequency [ i lst ]
  report length filter [? -> ? = i] lst
end



to check-queue-length-and-write
  ;let len length queue
  ;if ticks >= (150 * num-of-queue-samples) and (num-of-queue-samples <= 100) [ ; this is for max num iterations of 15000
  ; a max of 100 samples taken 100 ticks by 100 ticks
  if ticks >= (10 * num-of-queue-samples) and (num-of-queue-samples <= 1000) [ ; this is for max num iterations of 10000
  ;if ticks >= (100 * num-of-queue-samples) and (num-of-queue-samples <= 100) [ ; this is for max num iterations of 10000
    ; if each 500 then <= 50; it depends of the max-num-of-iterations this example are 25000
    let len length queue-chk
    ;let pallets-in-queue ( sum map [i -> [total-pallets] of i ] queue-chk ) ; total pallets in queue
    ;let tags-in-queue ( sum map [ i -> sum [ [ num-tags-in-pallet ] of pallets-in-truck ] of i ] queue-chk ) ; total tags in queue
    let tags-in-queue (sum map [i -> [num-tags-in-chart] of i ] queue-chk)
    ;set queue-length lput (list ticks len pallets-in-queue tags-in-queue ) queue-length
    set queue-length lput (list ticks len tags-in-queue ) queue-length
    set num-of-queue-samples (num-of-queue-samples + 1)
  ]
end

to write-queue-file [ f-queue ]
  if file-exists? f-queue [ file-delete f-queue ]
  file-open f-queue
  foreach range ( length queue-length ) [ ? ->
    file-write ( first item ?  queue-length ) ;the time ticks
    file-write ( item 1 item ?  queue-length ) ; the length of the queue
    ;file-write ( item 2 item ?  queue-length ) ; total pallets in queue
    file-write ( last item ? queue-length ) ; total tags in queue
    file-print ""
  ]
  file-close
end

;to-report compute-a
;  report (-4.39445 / (g1_min - g1_max))
;end
;
;to-report compute-b
;  report (-2.19722 / (g1_min - g1_max))
;end

to-report sigmoid [f a b]
  report (1 / ( 1 + (exp (-1 * a * f + b) ) ) )
end

to compute-utl-averages
  ifelse ticks >= readers-control-period - 1 [ ;10 [
    let f-sns (mean [cycle] of readers with [reader-type = "sns"] / ticks)
    set avg-f-sns ((avg-f-sns) * (f-count - 1) + f-sns) / f-count
    let f-io (mean [cycle] of readers with [reader-type = "io"] / ticks)
    set avg-f-io ((avg-f-io) * (f-count - 1) + f-io) / f-count
    let f-inv (mean [cycle] of readers with [reader-type = "inv"] / ticks)
    set avg-f-inv ((avg-f-inv) * (f-count - 1) + f-inv) / f-count
    ; let a1 8.7889 let b1 10.9861
    ; let a2 8.7889 let b2 6.59167
    ; let a3 439.445  let b3 21.9722
    ; let a1 11.5643 let b1 16.8839
    ; let a2 17.8636 let b2 6.30586
    ; let a3 439.445  let b3 24.1695
    ;
    let a1 (-4.39445 / (g1_min - g1_max)) let b1 (-2.19722 / (g1_min - g1_max) * (g1_min + g1_max) )
    let a2 (-4.39445 / (g2_min - g2_max)) let b2 (-2.19722 / (g2_min - g2_max) * (g2_min + g2_max) )
    let a3 (-4.39445 / (g3_min - g3_max)) let b3 (-2.19722 / (g3_min - g3_max) * (g3_min + g3_max) )
    ;
    set utl ((sigmoid f-sns a1 b1) * (sigmoid f-io a2 b2) * (sigmoid f-inv a3 b3))
    ;show (list  (sigmoid f-sns a1 b1) (sigmoid f-io a2 b2) (sigmoid f-inv a3 b3) utl )

    ask readers with [reader-type = "sns"] [
      set reader-utl (sigmoid ( (cycle - cycle-last-epoch ) / readers-control-period) a1 b1)
      set cycle-last-epoch cycle
      set reader-utl-from-start (sigmoid (cycle / ticks) a1 b1)
    ]
    ask readers with [reader-type = "io"] [
      set reader-utl (sigmoid ( (cycle - cycle-last-epoch ) / readers-control-period) a2 b2)
      set cycle-last-epoch cycle
      set reader-utl-from-start (sigmoid (cycle / ticks) a2 b2)
    ]
    ask readers with [reader-type = "inv"] [
      set reader-utl (sigmoid ( (cycle - cycle-last-epoch ) / readers-control-period) a3 b3)
      set cycle-last-epoch cycle
      set reader-utl-from-start (sigmoid (cycle / ticks) a2 b3)
    ]
    ;set utl-sns ( reduce * ([reader-utl] of readers with [reader-type = "sns"]) )
    ;set utl-io ( reduce * ([reader-utl] of readers with [reader-type = "io"]) )
    ;set utl-inv ( reduce * ([reader-utl] of readers with [reader-type = "inv"]) )
    set avg-utl ((avg-utl) * (f-count - 1) + utl) / f-count
    let pe-io (ifelse-value (total-visitors-die > 0) [1 - (visitor-detect-count / total-visitors-die)][0])
    set avg-pe-io ((avg-pe-io) * (f-count - 1) + pe-io) / f-count
    set f-count (f-count + 1)
    ;( compute-deltas f-sns f-inv pe-io )
    compute-deltas ; but now we check the utility, not the frequency
  ] [
    set f-count (f-count + 1)
  ]
end

;to compute-deltas [ f-sns f-inv pe-io ]
to compute-deltas
;  let f-sns-min 1.35 ;cycles/s
;  let f-sns-max 1.45 ;cycles/s
;  ;let f-sns-middle (f-sns-min + f-sns-max) / 2
;  ;let f-io-min 1 ;cycles/s compute with identification ratio
;  let f-inv-min 0.050 ;cycles/s
;  let f-inv-max 0.053 ;cycles/s
  ;let f-inv-middle (f-inv-min + f-inv-max) / 2
  ask readers[
    if reader-utl < 0.5 [ set delta (max (list 1 (delta - 5)) ) ]
    if reader-utl > 0.9 [ set delta (max (list 1 (delta + 5)) ) ]
  ]
  ; lo siguyiente era el mod anterior y lo comento
;  ; Control SENSORS
;  ask readers with [reader-type = "sns"] [
;    ; if (cycle / ticks) < f-sns-min [ set delta (max (list 1 (delta - 10)) ) ]
;    ; if (cycle / ticks) > f-sns-max [ set delta (max (list 1 (delta + 10)) ) ]
;  ]
;  ; Control DOORS
;  ask readers with [reader-type = "io"] [
;    ; In Average IO readers
;    ;ifelse pe-io > 0.05 [ ; the minimum Prob Error allowed is 5%
;    ;  ask readers with [reader-type = "io"] [ set delta (max (list 1 (delta - 10)) ) ]
;    ;] [
;    ;  ask readers with [reader-type = "io"] [ set delta (max (list 1 (delta + 10)) ) ]
;    ;]
;    ;For Each IO Reader
;    set reader-pe-io (ifelse-value (reader-visitors-die > 0) [1 - (reader-visitor-detect-count / reader-visitors-die)][0])
;;    ifelse reader-pe-io > 0 [ ; the minimum Prob Error allowed is 5%
;;      ;set delta (max (list 1 (delta - 10)) )
;;      set delta 1
;;    ] [
;;      set delta (max (list 1 (delta + 10)) )
;;    ]
;    ; For Each group of tags
;    if synchronous? [
;      ifelse group-pe-io > 0 [
;        ;set delta (max (list 1 (delta - 10)) ) ; NO VA
;        set delta 1 ; SI VA
;      ] [
;        set delta (max (list 1 (delta + 10)) )
;      ]
;    ] ; if synchro
;  ] ; ask
;  ; Control INVENTORY ROOMS
;  ask readers with [reader-type = "inv"] [
;    if (cycle / ticks) < f-inv-min [ set delta (max (list 1 (delta - 10)) ) ]
;    if (cycle / ticks) > f-inv-max [ set delta (max (list 1 (delta + 10)) ) ]
;  ]
  write-traces-per-reader
end

to write-traces-per-reader
  ;let utl-list (list )
  ;let utl-mean-list (list )
  file-open sns-file ; there are up to 8 sns-readers
  let sns-r sort-on [ who ] (readers with [ reader-type = "sns" ])
  file-write ticks
  foreach sns-r [ ? ->
    file-write ( ([cycle] of ?) / ticks )
    file-write ( [delta] of ? )
    file-write [reader-utl] of ?
    ;set utl-list ( lput ([reader-utl] of ? ) utl-list )
  ]
  ;set utl-mean-list (lput mean [reader-utl] of (readers with [reader-type = "sns"]) utl-mean-list
  file-write ( mean [reader-utl] of (readers with [reader-type = "sns"]) )
  file-print ""
  file-close
  ;
  file-open io-file ; there are up to 4 io-readers
  let io-r sort-on [ who ] (readers with [ reader-type = "io" ])
  file-write ticks
  foreach io-r [ ? ->
    file-write ( ([cycle] of ?) / ticks )
    file-write ( [delta] of ? )
    file-write ( [reader-pe-io] of ? )
    file-write [reader-utl] of ?
  ]
  file-write ( mean [reader-utl] of (readers with [reader-type = "io"]) )
  file-print ""
  file-close
  ;
  file-open inv-file ; there are up to 8 inv-readers
  let inv-r sort-on [ who ] (readers with [ reader-type = "inv" ])
  file-write ticks
  foreach inv-r [ ? ->
    file-write ( ([cycle] of ?) / ticks )
    file-write ( [delta] of ? )
    file-write [reader-utl] of ?
  ]
  file-write ( mean [reader-utl] of (readers with [reader-type = "inv"]) )
  file-print ""
  file-close
  ;
  file-open utl-file ; total of 25 columns in this file
  file-write ticks
  foreach sns-r [ ? -> file-write [reader-utl] of ? ]
  let utl-avg-sns ( mean [reader-utl] of (readers with [reader-type = "sns"]) )
  file-write utl-avg-sns
  foreach io-r [ ? -> file-write [reader-utl] of ? ]
  let utl-avg-io ( mean [reader-utl] of (readers with [reader-type = "io"]) )
  file-write utl-avg-io
  foreach inv-r [ ? -> file-write [reader-utl] of ? ]
  let utl-avg-inv ( mean [reader-utl] of (readers with [reader-type = "inv"]) )
  file-write utl-avg-inv
  file-write ( utl-avg-sns * utl-avg-io * utl-avg-inv )
  file-print "col# 26 / from start"
  file-write utl
  file-write ( mean [reader-utl-from-start] of (readers with [reader-type = "sns"]) )
  file-write ( mean [reader-utl-from-start] of (readers with [reader-type = "io"]) )
  file-write ( mean [reader-utl-from-start] of (readers with [reader-type = "inv"]) )
  file-write ( ( mean [reader-utl-from-start] of (readers with [reader-type = "sns"]) ) *
        ( mean [reader-utl-from-start] of (readers with [reader-type = "io"]) ) * ( mean [reader-utl-from-start] of (readers with [reader-type = "inv"]) ) )
  file-print ""
  file-close
end

to check-frequencies-and-utl
  if ticks >= (readers-control-period * f-count) [ ; readers-control-period antes 10s es para tomar muestras de utilidad cada periodo
    compute-utl-averages
    ;compute-deltas
  ]
end

to check-known-samples-and-write
  ; take a sample each 100 seconds or 10 seconds
  ;if ticks >= (100 * num-known-samples) and (num-known-samples <= 10000) [ ; this is for max num iterations of 15000
  if ticks >= (10 * num-known-samples) and (num-known-samples <= 10000) [ ; this is for max num iterations of 15000
    write-known-tags-ratio "0"
    set num-known-samples ( num-known-samples + 1 )
  ]
  write-known-tags-ratio "1"
end

;; Sets up anonymous procedures for event queue
to setup-tasks
  set end-run-task [[?ignore] -> end-run]
  ; new
  ;set arrive-task [[?ignore] -> arrive-chart] ; change 'arrive' to 'arrive-chart' (in each call does 'arrive-task nobody' to create a truck)
  ;
  set start-LM-task [[?reader] -> start-LM ?reader]
  set start-TM-task [[?reader] -> start-TM ?reader]
  set complete-service-task [[?reader] -> complete-service ?reader]
  ;new:
  ;set complete-service-task-chk [[?checkout] -> complete-service-chk ?checkout]
  ;
  set departure-task [[?ignore] -> departure]
  set lookup-task [[?supervisor] -> lookup ?supervisor]
  set reorganization-task [[?ignore] -> reorganization]
  ;set reset-stats-task [[?ignore] -> reset-stats]
  ;set replenish-task [[?ignore] -> replenish-stands]
  set p-arrival-task [[?ignore] -> visitor-arrival]
  set p-departure-task [[?ignore] -> visitor-departure]
  set tags-die-task [[?tags] -> tags-die ?tags]
end
;;

to go
  set total-inventory-cycles min [ cycle ] of readers
  ifelse ticks < max-run-time [;and total-inventory-cycles <= 50 [;and ( length queue <= 1000) [
  ;ifelse total-inventory-cycles <= max-inventory-cycles [
  ;ifelse total-lookups < max-lookups [
  ;ifelse arrival-count <= max-num-of-arrivals [
    ;
    ;check-queue-length-and-write
    ;check-known-samples-and-write
    check-frequencies-and-utl
    ;
    let next-event []
    let event-queue (list (list max-run-time end-run-task nobody)) ; ---OJO do not coment this lline
    ;[[500000 (anonymous command from: procedure SETUP-TASKS: [end-run]) nobody]]
    let next-reader-to-complete next-reader-complete ; reader with min of next-completion-time

    ;;;--
    ; ; -- Next the GO of continuous:
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
    ; departures? OFF in this case
    if departures? [
     set event-queue (
       fput (list next-departure-time departure-task nobody) event-queue )
    ]
    ;;;-------------
    set event-queue (
      fput (list next-p-arrival-time p-arrival-task nobody) event-queue )
    set event-queue (
      fput (list next-p-departure-time p-departure-task nobody) event-queue )
    ;;;-------------
    ;set event-queue (
    ;   fput (list next-replenish-time replenish-task nobody) event-queue )
    ;
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
    ;;tags-to-die
    let next-tags-to-die next-tags-die
    ;if is-agent? next-tags-to-die [
      if (is-turtle?  next-tags-to-die)  [
      ;print "die-go"
        set event-queue (fput
          (list
            ([ tag-die-time ] of (next-tags-to-die) )
            tags-die-task
            next-tags-to-die)
          event-queue)
      ]
    ;]
    ;show event-queue
    if not empty? event-queue [
      set event-queue (sort-by [[?1 ?2] -> first ?1 < first ?2] event-queue)
      ; show event-queue
      set next-event (first event-queue)
      update-usage-stats (first next-event) ; the time of the next event;
      set next-event (but-first next-event) ; the procedure of the next event
      ; print (word "next-event = " next-event " and Ticks = " ticks)
      ;[(anonymous command from: procedure SETUP-TASKS: [arrive]) nobody]
      (run (first next-event) (last next-event))
      ;update-plots
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
  let tgs count my-tags with [ not inventoried? ];and (tag-id-group = [tag-selection-filter] of myself) ]
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
  set efficiency cs-t / (cs-t + cc-t + ce-t)
  set throughput cs-t / (TM-time + LM-time)
  report reading-time
end



to-report one-frame-inventory [ reading-time ]
  let frame-time 0 let s 0
  set ce 0 set cs 0 set cc 0
  let tagson my-tags with [ (inventoried? = false) ];and (tag-id-group = [tag-selection-filter] of myself) ] ;show tagson
  ifelse any? tagson [   ;show but-first range  (frame-size + 1)
    ask tagson [ set tag-outage? false ]
    ;let tagsoff (turtle-set )

    foreach but-first range ( frame-size + 1 ) [ [ ?slot ] ->
      set tagson tagson with [ tag-outage? = false ] ; not inventoried and with not outage
      ask tagson [ compute-power-rec-in-tag reading-time frame-time ]
      let contending-tags tagson with [ ( my-inventory-slot = ?slot ) and ( tag-outage? = false ) ]
      ifelse any? contending-tags [ set s count contending-tags ] [set s 0 ]
      ;show (list ?slot s)

      if ?slot = 1 [

        if s = 0 [ set frame-time t1E set ce 1 ]

        if s >= 1 [
          let tags-powers (list )
          ask contending-tags [
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
          ask contending-tags [
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
  let tag-power-rx-linear 0
  ifelse in-chart? [
     set tag-power-rx-linear ( ([ checkout-power-tx * checkout-gain-tx-rx * ((c / checkout-frequency) ^ 2) ] of myself ) * tag-gain * polarz-mismatch * pow-tx-coefficient )  /
      (( ( 4 * pi * distance-to-r ) ^ 2) * on-object-gain-penalty * path-blockages * fading-factor-fw ) * ( q_e_rcn_fw * shadow_fw )
  ] [
    set tag-power-rx-linear ( ([ reader-power-tx * reader-gain-tx-rx * ((c / reader-frequency) ^ 2) ] of myself ) * tag-gain * polarz-mismatch * pow-tx-coefficient )  /
      (( ( 4 * pi * distance-to-reader ) ^ 2) * on-object-gain-penalty * path-blockages * fading-factor-fw ) * ( q_e_rcn_fw * shadow_fw )
  ]
  ;show (list tag-power-rx-linear fading-factor-fw q_e_rcn_fw  shadow_fw)
  ;print (word "distance to reader: " distance-to-reader)
  set tag-power-rx ( 10 * log (1000 * tag-power-rx-linear) 10 ) ;write "2" show tag-power-rx
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
  let reader-power-rx-linear 0
  let checkout-power-rx-linear  0
  ifelse in-chart? [
    set checkout-power-rx-linear ( ([ checkout-power-tx * (checkout-gain-tx-rx ^ 2) * (c / checkout-frequency) ^ 4 ] of myself ) * (tag-gain ^ 2) * (polarz-mismatch ^ 2) * modulation-factor ) /
    ( ( 4 * pi ) ^ 4 * (distance-to-r_f ^ 2)* (distance-to-r ^ 2) * ( on-object-gain-penalty ^ 2) * (path-blockages ^ 2) * fading-factor-bw ) * ( ( q_e_rcn_fw * q_e_rcn_bw ) * shadow_fw * shadow_bw ) ; loss-by-rician-fading-fw * loss-by-rician-fading-bw
    ask myself [ set checkout-power-rx 10 * log (1000 * checkout-power-rx-linear) 10  ]
  ] [
    set reader-power-rx-linear ( ([ reader-power-tx * (reader-gain-tx-rx ^ 2) * (c / reader-frequency) ^ 4 ] of myself ) * (tag-gain ^ 2) * (polarz-mismatch ^ 2) * modulation-factor ) /
      ( ( 4 * pi * distance-to-reader ) ^ 4 * ( on-object-gain-penalty ^ 2) * (path-blockages ^ 2) * fading-factor-bw-a ) * ( ( q_e_rcn_fw * q_e_rcn_bw ) * shadow_fw * shadow_bw ) ; loss-by-rician-fading-fw * loss-by-rician-fading-bw
    ask myself [ set reader-power-rx 10 * log (1000 * reader-power-rx-linear) 10  ]
  ]
  ;show (list shadow_bw reader-power-rx-linear (10 * log (1000 * reader-power-rx-linear) 10) )
  ;set reader-power-rx-linear ((10 ^ (-0.6)) / 1000 )
  ;;
  ;ask myself [ set reader-power-rx 10 * log (1000 * reader-power-rx-linear) 10  ]
  ;report reader-power-rx-linear
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
  let CIR 0
  ;let tags-powers-interference (list ) let powers-interference (list )
  ;let tag-of-max-power nobody
  ;print "1 t" show tags-powers
  if not empty? tags-powers [
    set tags-powers sort-by [ [ ?1 ?2 ] -> item 1 ?1 > item 1 ?2 ] tags-powers
    ;set tags-powers-ordered tags-powers
    ;print "2 t" show tags-powers
    set tag-of-max-power first first tags-powers
    let max-power last ( first tags-powers )
;    let SNR ( ( 10 * log (1000 * max-power) 10 ) - ( noise-figure_dB + (10 * (log max-rx-BW 10 ) ) + noise-density_dBm_Hz ) )
;    let SNR_linear (10 ^ (SNR / 10))
;    let SNIR SNR_linear
    let N_linear ((10 ^ (-116.87 / 10)) / 1000) ;B=200E3
    ;let N_linear ((10 ^ (-105.11 / 10)) / 1000) ;B=3E6
    let SNR_linear (max-power / N_linear)
    let SNIR SNR_linear
    if length tags-powers > 1 [
      let tags-powers-interference-linear but-first tags-powers
      let powers-interference-linear map [ p -> last p ] tags-powers-interference-linear
      ;let CIR ( max-power / ( sum powers-interference ) ) ;show CIR
      ;set SNIR ( 1 / ( ( 1 / SNR_linear) + (1 / CIR ) ) )
      set SNIR ( max-power / (( sum powers-interference-linear ) + N_linear))
    ]
    let BER (1 + rician-factor) / ( 2 + 2 * rician-factor + SNIR ) * exp (-3 * SNIR / ( 2 + rician-factor + SNIR ) ) ;print "BER=" show BER
    let prob-error ( 1 - ( 1 - BER) ^ 40) ;show (list BER prob-error)
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
          ;
          set sample-count (sample-count + 1)
          ;
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
to schedule-p-arrival
  set next-p-arrival-time (ticks + random-exponential (1 / mean-p-arrival-rate))
end

to schedule-p-departure
  set next-p-departure-time (ticks + random-exponential (1 / mean-p-departure-rate))
end
;;


; REORG based on tags
to reorganization
  let num-changes-in-reorg (random-tween 20 60)
  ;let tags-not-sensor nobody
  ;ask readers with [ not (reader-type = "io") ] [ set tags-not-sensor (turtle-set tags-not-sensor (my-tags with [not sensor?])) ]
  ;show tags-not-sensor
  let readers-not-io (readers with [not (reader-type = "io")])
  let pallets-not-io (turtle-set [pallet-being-served] of readers-not-io )
  repeat num-changes-in-reorg [
    let p1 nobody let p2 nobody
    let t1 nobody let t2 nobody let t1_1 nobody let t2_1 nobody
    let two-pallets n-of 2 pallets-not-io
    ask one-of two-pallets [
      set p1 self
      set p2 other two-pallets
      set t1 (turtle-set [tags-in-pallet] of p1)
      set t2 (turtle-set [tags-in-pallet] of p2)
      set t1_1 one-of t1 with [ not sensor? ]
      set t2_1 one-of t2 with [ not sensor? ]
      ask (turtle-set t1_1 t2_1) [
        set inventoried-first? false
        set inventoried? false
        set tag-round-not-located 0
      ]
    ]
    ask t1_1 [set t1 t1 with [self != myself]]
    ask t2_1 [set t2 t2 with [self != myself]]
    set t1 (turtle-set t1 t2_1)
    set t2 (turtle-set t2 t1_1)
    ask p1 [ set tags-in-pallet t1 ]
    ask p2 [ set tags-in-pallet t2 ]
    ;print "my-tags = "
  ] ; repeat
  ask readers-not-io [
    set my-tags (turtle-set [ tags-in-pallet ] of pallet-being-served)
    ;print (word "reader " [who] of self ", my-tags = " my-tags)
  ]
  set total-swaps (total-swaps + 1)
  schedule-reorganization
end


;;
; is an observer procedure
; In a Hospital we discharge some patients (all) and inmediately replenish with new patients
to departure
  let number-of-items 120
  let tags-of-inv-readers (turtle-set [ my-tags ] of (readers with [reader-type = "inv"]) )
  ask n-of number-of-items tags-of-inv-readers [ die ]
  set total-departures (total-departures + 1)
  if ( sum [count my-tags] of (readers with [reader-type = "inv"]) < ((count readers with [reader-type = "inv"]) * mean-tags-per-pallet * minimum-stock-level  / 100 )) [
  ;if (total-departures mod 4) = 0 [
    replenish-cabinet
  ]
  schedule-departure
end
;;


to visitor-arrival
  let arrival-reader one-of readers with [reader-type = "io"]
  let num-visitors (random-poisson 2 + 1)
  ask arrival-reader [
    let this-reader self
    ask pallet-being-served [
      set num-tags-in-pallet (num-visitors + num-tags-in-pallet)
      hatch-tags num-visitors [
        set total-visitor-arrivals ( total-visitor-arrivals + 1 )
        let this-tag self
        ask myself [set tags-in-pallet (turtle-set tags-in-pallet this-tag)]
        set inventoried? false
        set inventoried-first? false
        set time-entered-queue ticks
        ; set time-entered-queue ifelse-value is-agent? ?truck [
        ;  [time-entered-queue ] of ?truck ] [ ticks ]
        set hidden? true
        ; x total-pallets if several pallets
        ; show (list ([ dx-to-center-of-reader ] of ?p) ([ dy-to-center-of-reader ] of ?p ) )
        set tag-x (random-tween (-1 * (p-width / 2)) (p-width / 2) ) + [ dx-to-center-of-reader ] of myself
        set tag-y (random-tween (-1 * (p-depth / 2)) (p-depth / 2) ) + [ dy-to-center-of-reader ] of myself
        set tag-z (random-tween p-base p-height )
        ; show (list tag-x tag-y tag-z ( ceiling-to-floor-distance - tag-z ) )
        set distance-to-reader sqrt ( ( ( tag-x ) ^ 2 + ( tag-y ) ^ 2 ) + ( ceiling-to-floor-distance - tag-z ) ^ 2 )
        ; show distance-to-reader
        set tag-sensitivity min-power-to-feed-tag-IC
        set tag-outage? false
        set tag-gain 1.621810097 ; 2.1 dBi
        set outage-count-of-this-tag 0
        ;set time-being-inventoried-first 0
        set inventoried-first? false ; still not inventoried
        set tag-id-group (random num-tag-groups )
        set in-chart? false
        ;
        set sensor? false
        set sample-count 0
        set tag-die-time (ticks + time-of-visitor-covered)
        set person? true
        ;set my-pallet myself
        ;set my-reader this-reader
      ] ; hatch
    ];ask pallet
    set my-tags (turtle-set [tags-in-pallet] of pallet-being-served)
  ];ask reader
  schedule-p-arrival

end

to visitor-departure
  let departure-reader one-of readers with [reader-type = "io"]
  let num-visitors (random-poisson 2 + 1)
  ask departure-reader [
    let this-reader self
    ask pallet-being-served [
      set num-tags-in-pallet (num-visitors + num-tags-in-pallet)
      hatch-tags num-visitors [
        set total-visitor-arrivals ( total-visitor-arrivals + 1 )
        let this-tag self
        ask myself [set tags-in-pallet (turtle-set tags-in-pallet this-tag)]
        set inventoried? false
        set inventoried-first? false
        set time-entered-queue ticks
        ; set time-entered-queue ifelse-value is-agent? ?truck [
        ;  [time-entered-queue ] of ?truck ] [ ticks ]
        set hidden? true
        ; x total-pallets if several pallets
        ; show (list ([ dx-to-center-of-reader ] of ?p) ([ dy-to-center-of-reader ] of ?p ) )
        set tag-x (random-tween (-1 * (p-width / 2)) (p-width / 2) ) + [ dx-to-center-of-reader ] of myself
        set tag-y (random-tween (-1 * (p-depth / 2)) (p-depth / 2) ) + [ dy-to-center-of-reader ] of myself
        set tag-z (random-tween p-base p-height )
        ; show (list tag-x tag-y tag-z ( ceiling-to-floor-distance - tag-z ) )
        set distance-to-reader sqrt ( ( ( tag-x ) ^ 2 + ( tag-y ) ^ 2 ) + ( ceiling-to-floor-distance - tag-z ) ^ 2 )
        ; show distance-to-reader
        set tag-sensitivity min-power-to-feed-tag-IC
        set tag-outage? false
        set tag-gain 1.621810097 ; 2.1 dBi
        set outage-count-of-this-tag 0
        ;set time-being-inventoried-first 0
        set inventoried-first? false ; still not inventoried
        set tag-id-group (random num-tag-groups )
        set in-chart? false
        ;
        set sensor? false
        set sample-count 0
        set tag-die-time (ticks + time-of-visitor-covered)
        set person? true
        ;set my-pallet myself
        ;set my-reader this-reader
      ] ; hatch
    ];ask pallet
    set my-tags (turtle-set [tags-in-pallet] of pallet-being-served)
  ];ask reader
  schedule-p-departure

end


to lookup [ ?supervisor ]
  if any? tags [
    let product one-of tags with [not in-chart?]
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
    ; Next is to write lookup successes and errors in a file
;    file-open lookup-file
;    file-write error? file-write ticks file-write ([who] of ?supervisor) file-write ([tag-x] of product) file-write ([tag-y] of product) file-write ([tag-z] of product)
;    file-write ([distance-to-reader] of product) file-write total-lookups file-write total-lookup-errors file-write diameter-x file-write diameter-y
;    file-write ceiling-to-floor-distance file-print ""
;    file-close
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
;to arrive-chart
;  print "1"
;  let total-charts 1
;  set total-offered-load-of-charts ( total-offered-load-of-charts + total-charts )
;  let base-point (portal-width / 2)
;  create-charts 1  [
;    set num-tags-in-chart generate-number "tags"
;    ;if num-tags-in-pallet > 200 [print num-tags-in-pallet ]
;    ;set pallets-of-this-truck (lput self pallets-of-this-truck)
;    set chart-distance base-point + (random-tween -0.15 0.15 )
;    ;set pallet-distance 2
;    set hidden? true
;    set shape "fish"
;    set size 2
;    set time-entered-queue ticks
;	  set still-not-inventoried true
;    set queue-chk (lput self queue-chk)
;    ;
;    set total-offered-load-of-tags ( total-offered-load-of-tags + num-tags-in-chart )
;  ]
;;  ask current-truck [
;;    set pallets-in-truck (turtle-set pallets-of-this-truck)
;;    set total-pallets count pallets-in-truck
;;  ]
;;  foreach pallets-of-this-truck [ [pallet?] ->
;;    let list-of-tags []
;;    create-tags ([num-tags-in-pallet] of pallet?) [
;;      set list-of-tags (lput self list-of-tags)
;;      set inventoried? false
;;      set time-entered-queue ticks
;;      set hidden? true
;;    ]
;;    ask pallet? [ set tags-in-pallet (turtle-set list-of-tags) ]
;;  ]
;  set arrival-count (arrival-count + 1)
;  schedule-arrival
;  begin-service-chk
;end

;; Creates a new truck agent, adds it to the queue, and attempts to start
;; service. We create a truck with pallets and the tags on each pallet.
to arrive [ tp ]
  let current-truck nobody
  create-trucks 1 [
    set current-truck self
    set queue (lput self queue)
    set time-entered-queue ticks
    ;set total-pallets generate-number "pallets"
    set total-pallets ( num-pallets-by-side * num-pallets-by-side )
    ; set shape "truck"
    if (tp = "inv") [set shape "box" set color brown]
    if (tp = "sns") [set shape "person" set color red]
    if (tp = "io") [set shape "dot" set color yellow]
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
    ;set num-tags-in-pallet mean-tags-per-pallet ;generate-number "tags"
    ;set num-tags-in-pallet ifelse-value (tp = "inv") [ mean-tags-per-pallet ] [ ifelse-value (tp = "sns") [20] [0]   ] ; sensing are 10x2 of sens +30 inventory, 0 in doors
    ;set num-tags-in-pallet ifelse-value (tp = "inv") [ mean-tags-per-pallet ] [ ifelse-value (tp = "sns") [20] [20]   ] ; sensing are 10x2 of sens +30 inventory, 0 in doors
    set num-tags-in-pallet  20 ;mean-tags-per-pallet
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
  ;set arrival-count (arrival-count + 1)
  ;schedule-arrival
  ; if stp = '0' then next-start-LM-time = ticks + TM-to-LM-time
  ; else next-start-LM-time = ticks + TM-to-LM-time + time-between-inventories
  (begin-service "0" tp ) ; 0 is stp means is the first time proc begin-service
end


;; Create the tags for each reader
;; we make this as an 'arrive' of a truck
;; This proc called at start in SETUP proc.
to setup-tags-under
  foreach sort readers with [ reader-type = "inv" ] [ r? -> (arrive "inv") ]
  foreach sort readers with [ reader-type = "sns" ] [ r? -> (arrive "sns") ]
  foreach sort readers with [ reader-type = "io" ] [ r? -> (arrive "io") ]
end


; reader context??
; We call this proc from begin-service() OJO--> DEPARTURE is DIFFERENT
to-report setup-tags [ ?pallet ?truck tp ]
  foreach sort ?pallet [ [?p] ->
    let list-of-tags []
    ;ask ?p [if is-agentset? tags-in-pallet [ask tags-in-pallet [die]]]
    ;if tp != "io" [ ;not io = sns or inv
    hatch-tags ([num-tags-in-pallet] of ?p) [
      set list-of-tags (lput self list-of-tags)
      set inventoried? false
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
      ; show (list tag-x tag-y tag-z ( ceiling-to-floor-distance - tag-z ) )
      set distance-to-reader sqrt ( ( ( tag-x ) ^ 2 + ( tag-y ) ^ 2 ) + ( ceiling-to-floor-distance - tag-z ) ^ 2 )
      ; show distance-to-reader
      set tag-sensitivity min-power-to-feed-tag-IC
      set tag-outage? false
      set tag-gain 1.621810097 ; 2.1 dBi
      set outage-count-of-this-tag 0
      ;set time-being-inventoried-first 0
      set inventoried-first? false ; still not inventoried
      set tag-id-group (random num-tag-groups )
      set in-chart? false
      ;
      ;set tag-type "inv"
      set sensor? false
      set sample-count 0
      set person? false
      ;set my-pallet ?p
      ;set my-reader myself
    ] ; hatch
   ; ] ; if
    ask ?p [ set tags-in-pallet (turtle-set list-of-tags) ]
    if tp = "sns" [
      ask n-of 10 (turtle-set list-of-tags) [
        ;set tag-type "sns"
        set sensor? true
      ]
    ] ;if tp
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
        ;
        ;set time-entered-queue ticks
      ]
    ] ;if
  ]
end

;ARRIVE HACE BEGIN-SERVICE 0, NOSOTROS QUEREMOS HACER BEGIN SERVICE ASIGNANDO EL READER CORRECTO: INV, SNS O IO

;; If there are trucks in the queue, and at least one reader is idle, starts
;; service on the first truck in the queue, using a randomly selected
;; idle server.
;; -->Besides, for each pallet in the truck, generate a complete-service event with
;; a time computed making the inventory of that particular pallet
;; But first we have to plan an event time to start LM
to begin-service [ stp tp]
  ; stp is "0" or "1" and tp="inv,sns,io"
  let available-readers (readers with [(not is-agent? truck-being-served) and reader-type = tp ])
  ;let available-readers (readers with [(not is-agent? truck-being-served) ]); or (not is-agent? pallet-being-served) ])
  if (not empty? queue and any? available-readers) [ ; OJO
    let next-truck (first queue)
    let next-reader one-of available-readers
    set queue (but-first queue)
    ask next-truck [
      move-to next-reader
      set hidden? false ]
    ask next-reader [
      set truck-being-served next-truck ; task variable owned by reader
      ;set pallet-being-served one-of [ pallets-in-truck ] of next-truck
      set pallet-being-served [ pallets-in-truck ] of next-truck
      ;ask pallet-being-served [ set pallet-distance (random-tween 1 3 ) ]
      set color red
      ; In this traffic case 'pallet-being-served' are all pallets
      ;setup-tags ( pallet-being-served )  ( truck-being-served )
      ;let pallet-with-tags-this-reader pallet-being-served with [is-agentset? tags-in-pallet]
      ifelse stp = "0" [ ; first tag creation
        set my-tags ( setup-tags ( [pallets-in-truck] of truck-being-served )  ( truck-being-served ) tp )
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
        ;
        ;ticks + time-between-inventories
        (ticks + ifelse-value (reader-type = "inv") [ 5 ] [time-between-inventories]) ; 20s period for traffic of material to inventory
      ]
      ;[ ticks + 0 ]; + TM-to-LM-time ] ; This line makes start inmediately the inventory
      [ticks + random-float 10]
    ]
  ]
 ; next look if there is any ready reader to start LM
 ; to see if there is a pallet to inventory.
 if empty? queue and any? available-readers [
    ask one-of available-readers [
      set next-start-LM-time ifelse-value (stp = "1") [
        ;ticks + time-between-inventories
        (ticks + ifelse-value (reader-type = "inv") [ 5 ] [time-between-inventories]) ; 20s period for traffic of material to inventory
       ;] [ ticks + random-tween 0 5]; TM-to-LM-time ]
       ] [
        ;ticks +  TM-to-LM-time
        (ticks + ifelse-value (reader-type = "inv") [ 5 ] [time-between-inventories])
      ]
    ]
 ]

  ;; in portal simulator here we look for readers with truck but no pallet to assing one
end

to setup-tags-distances-chk
  print "2"
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




;to replenish-stands
to replenish-cabinet
  ;if (count tags with [not in-chart?]) <= ( (minimum-stock-level / 100) * total-initial-tags ) [
      set moments-of-arrivals ( moments-of-arrivals + 1 )
      ;let pallets-to-refill (pallets with [ count tags-in-pallet < mean-tags-per-pallet ])
      let pallets-inv (turtle-set [pallet-being-served] of (readers with [reader-type = "inv"]) )
      let pallets-to-refill (pallets-inv with [ count tags-in-pallet < mean-tags-per-pallet ])
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
            ask readers with [TM?] [
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
    ;] ; if count
  ;schedule-replenish ; only if replenish is included in event-queue
end



to-report random11steps [ minLM ]
  let step random 11 + 1
  let step-value (minLM / 11)
  report step * step-value
end

;; The reader start listening the channel
;; if another reader uses the channel, then it has to wait a random time [.05s 0.1s]
;; and try again.
to start-LM [ ?reader ]
  ask ?reader [
    ;ifelse not any? other readers with [ TM? = true ] [
    ifelse not any? rri-neighbors with [ TM? = true ] [
      set next-start-TM-time (next-start-LM-time + min-LM * delta) ; exp_2
      ;set next-start-TM-time (next-start-LM-time + min-LM) ;test_1 exp_2
      ;set contention? false
      set LM? true
    ] [ ; Not Sure If This ELSE is need it
      ;; if not, change start LM to random time between 50 to 100 ms
      set next-start-LM-time (next-start-LM-time + random-tween 0.05 0.1 )
      ;set next-start-LM-time (next-start-LM-time + random-tween 0.01 0.05 )
      ;set next-start-LM-time (next-start-LM-time + random-tween 0.1 0.5 )
      ;set next-start-LM-time (next-start-LM-time + (min-LM * delta) + random-tween 0.05 0.1 )
      ;set next-start-LM-time (next-start-LM-time + (min-LM * delta) )
      ;set contention? true
      set LM? false
    ]
  ]
end

to start-TM [ ?reader ]
  ask ?reader [
    set TM? true   set LM? false
    if contention? [ set contention? false ]
    ;let readers-with-RRI other readers with [
    let readers-with-RRI rri-neighbors with [
      next-start-TM-time < ([next-start-TM-time] of myself) and
        ([next-start-TM-time] of myself) - next-start-TM-time <= (distance myself) * 10 * tau ]
    ;let kk any? other readers with [ TM? ] show kk
    ;ifelse any? other readers with [ TM? ] [
    ifelse any? rri-neighbors with [ TM? ] [
      ask my-rris with [ [ TM? ] of other-end ] [ set color red ]
      ;;print " possible collision"
      ;; check if collision or contention
      ifelse any? readers-with-RRI [
        ;print "collision"
        manage-collision readers-with-RRI ] [ manage-contention ]
    ] [
      ask my-rris with [ [ color = red ] of other-end ] [ set color green ]
      let k my-FSA
      ;show (list k count my-tags with [inventoried? and outage-count-of-this-tag < 2] count my-tags ); <<------OJO "Not Remove"
      ;set next-completion-time (ticks + k ) ;my-FSA)
      set next-completion-time ( ticks + k + empty-frames-TM )
      set LM-time (LM-time + (ticks - next-start-LM-time))
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
  set collide? false
  ; Other readers note the collision after the propagation back to themselves
  ;if any? rdr-with-rri [
  if (is-agentset? rdr-with-rri) or (is-agent? rdr-with-rri) [
    ask rdr-with-rri [
      set next-completion-time ticks + ((distance myself) * 10 * tau)
      ;set num-of-collisions (num-of-collisions + 1)
      ; When they reach the completion-time
      ; they have to start the inventory of all tags on the pallet.
      ; However, more accurate is to die the tags inventoried
      set collide? true
    ]
  ]
end

;; another reader have owned the channel
;; during my LM-time or just at the current time
;; and actual reader must re-schedule another LM-time
to manage-contention
  ;set next-start-TM-time ( ticks + (random11steps min-LM) * delta )
  ;set next-start-TM-time ( ticks + (random11steps min-LM) * delta )
  ;set next-start-TM-time ( ticks + (min-LM) * delta )
  set next-start-TM-time ( ticks + (min-LM) )
  set TM? false
  set contention? true
end

; inspect reader 0 inspect truck 1 inspect pallet 5 inspect tag 100
to write-known-tags-ratio [ wrt ]
  ;; Get the tags invenotoried vs all tags and write in a file
  ;if total-inventory-cycles <= 100000 [
    let pallets-with-tags (pallets with [ is-agentset? tags-in-pallet ])
    ;let total-tags sum [ num-tags-in-pallet ] of pallets-with-tags
    let total-tags sum ([ count tags-in-pallet ] of pallets-with-tags)
    ;let total-tags-singulated sum [ count tags-in-pallet with [
    ;  inventoried? and not(outage-count-of-this-tag < max-num-of-outages) ] ] of pallets-with-tags
    ;
    let tags-singulated-agt (turtle-set [tags-in-pallet with [inventoried-first?] ] of pallets )
    ;let tags-singulated-agt (turtle-set [tags-in-pallet with [inventoried-first?] ] of (pallets with [num-tags-in-pallet > 0]) )
    ;let tags-singulated-agt (turtle-set [tags-in-pallet with [inventoried-first?] ] of pallets-with-tags )
    let total-tags-singulated 0
    if any? tags-singulated-agt [ set total-tags-singulated count tags-singulated-agt ]
    ; show (list pallets-with-tags total-tags total-tags-singulated ) ;------
    ;set total-tags-singulated-sim ( total-tags-singulated-sim + total-tags-singulated )
    ;set total-tags-sim ( total-tags-sim + total-tags )

  let avg-inv-ratio ifelse-value (total-tags > 0) [( total-tags-singulated / total-tags )][0]
    ifelse (inv-count >= 2) [
      set average-inv-ratio ((average-inv-ratio * (inv-count - 1) + avg-inv-ratio) / inv-count)
      set inv-count inv-count + 1
    ][
      set average-inv-ratio average-inv-ratio
      set inv-count inv-count + 1
    ]
    if wrt = "0" [
      file-open known-file
      file-write ticks file-write ifelse-value (total-tags > 0) [( total-tags-singulated / total-tags )][0] file-write total-tags file-print ""
      file-close
      ;set total-inventory-cycles (total-inventory-cycles + 1)
    ] ;if
end



to reset-truck [ truck? ]
  ask truck? [
    set color brown
    set queue (fput self queue)
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
              set next-start-LM-time (ticks + time-between-inventories )
           ]
            reset-truck  self ;[ truck-being-served ] of myself
        ] ; ask truck-
      ;] ;if tagson
    ] [
        ; have to repeat the inventory of actual pallet
        manage-collision nobody ; with myself
      ] ; ifelse (not collide)

    set TM? false
    set cycle (cycle + 1)
    set tag-selection-filter ( tag-selection-filter + 1 )
    ; next the selection come back to the first group of tags
    if ( tag-selection-filter = num-tag-groups ) [ set tag-selection-filter 0 ]
  ] ; ask ?reader

  ; arrive ; new truck with same num tags OR...
  ; let live the truck, put in the queue and with begin-service take it again
  ;set total-inventory-cycles ( total-inventory-cycles + 1 ) ; one cycle more is made
  (begin-service "1" [reader-type] of ?reader); Note that begin-service is made even when there are collision or the pallet is not finished
end

to tags-die [ ?tag ]
  set total-visitors-die (total-visitors-die + 1)
  ;let my-pallet nobody
  let this-reader nobody
  let io-tags nobody
  let this-group-tags nobody
  ask ?tag [
    ; ask my-pallet and my-reader to update
    ; num-tags-in-pallet, tags-in-pallet and my-tags
    let t-end tag-die-time
    ask (readers with [reader-type = "io"]) [
      if (member? myself my-tags) [
        set this-reader self
        set io-tags my-tags with [tag-die-time = t-end]
        ;show count io-tags
        ;set my-pallet [pallet-being-served] of self
        ;set my-pallet pallet-being-served
        set this-group-tags (turtle-set [tags-in-pallet] of pallet-being-served)
        ask myself [ set this-group-tags other this-group-tags]
        ask pallet-being-served [
          set tags-in-pallet this-group-tags
          set num-tags-in-pallet (num-tags-in-pallet - 1)
        ]
        let my-r-tags my-tags
        ask myself [set my-r-tags other my-r-tags]
        set my-tags my-r-tags
      ] ;if
    ] ;ask readers with ...
    if inventoried-first? [
      set visitor-detect-count (visitor-detect-count + 1)
      ask this-reader [ set reader-visitor-detect-count (reader-visitor-detect-count + 1) ]
    ]
    ask this-reader [ set reader-visitors-die (reader-visitors-die + 1) ] ; increment specific count in reader

    ;;- next is for each group of tags
    ;let t-start time-entered-service
    ;show count io-tags ;with [time-entered-service = t-start]
    ;if count io-tags with [tag-die-time = t-end] > 0 [
    if count io-tags > 0 [
      ;print ">0"
      ask this-reader [
        set group-count (group-count + 1)
        if [inventoried-first?] of myself [ set group-detect-count (group-detect-count + 1) ]
      ];ask
      if count io-tags = 1 [
        ;print "NADIE"
        ask this-reader [
          set group-pe-io ( ifelse-value (group-count > 0) [ 1 - (group-detect-count / group-count) ][0] )
          ;show group-pe-io
          set group-count 0
          set group-detect-count 0
          ;
          if ( not synchronous? ) [
            ifelse group-pe-io > 0 [
             ;set delta (max (list 1 (delta - 10)) ) ; NO VA
             set delta 1 ; SI VA
            ] [
              set delta (max (list 1 (delta + 10)) )
            ]
          ]; if not sync
        ];ask
      ] ;if
    ]

    die

  ] ; ?tags

;  ask this-reader [
;    ifelse group-pe-io > 0 [
;      ;set delta (max (list 1 (delta - 10)) )
;      set delta 1
;    ] [
;      set delta (max (list 1 (delta + 10)) )
;    ]
;  ]

  ;show (word "#tags= " count tags " , die: " (list total-visitors-die count tags))
end

; to report the tag with the min time to die
to-report next-tags-die
  let io-tags (turtle-set [my-tags] of (readers with [reader-type = "io"]))
  ;report ifelse-value (any? io-tags with [tag-die-time > ticks]) [( io-tags with-min [tag-die-time] )][nobody]
  report (min-one-of
    ( io-tags with [ tag-die-time >= ticks and person?] )
    [ tag-die-time ] )
end

; to report the supervisor with the first
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




;; Updates the usage/utilization statistics and advances the clock to the
;; specified event time.
to update-usage-stats [event-time] ;event-time is the next event time <<--OJO with NAMES
  let delta-time (event-time - ticks)
  let busy-readers (readers with [is-agent? truck-being-served])
  ;let busy-checkouts ( checkouts with [ is-agent? chart-being-served ] )
  let in-queue (length queue)
  ;let in-queue-chk (length queue-chk)
  let in-process (count busy-readers)
  ;let in-process-chk (count busy-checkouts)
  let in-system (in-queue + in-process)
  ;let in-system-chk (in-queue-chk + in-process-chk)
  set total-truck-queue-time
    (total-truck-queue-time + delta-time * in-queue)
  ;set total-chart-queue-time
  ;  (total-chart-queue-time + delta-time * in-queue-chk)
  set total-truck-service-time
    (total-truck-service-time + delta-time * in-process)
  ;set total-chart-service-time
  ;  (total-chart-service-time + delta-time * in-process-chk)
  ;
  tick-advance (event-time - ticks)
  update-plots
end

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
;  set total-offered-load-of-tags-sg ( total-offered-load-of-tags / (ticks - stats-start-time))
;  ;set total-offered-load-of-charts-sg ( total-offered-load-of-charts / (ticks - stats-start-time))
;  set average-inv-ratio average-inv-ratio; (total-tags-singulated-sim / total-tags-sim)
;  ;
;  ;set total-system-throughput-sg (total-system-throughput-chk / (ticks - stats-start-time))
;  set total-system-throughput-sg (total-system-throughput / (ticks - stats-start-time))
;  ;set total-charts-thoughput-sg ( total-charts-throughput / (ticks - stats-start-time))
;  ;set total-tags-inventoried  total-system-throughput-chk
;  ;set reader-utilization-percent (100 * total-chart-service-time / (ticks - stats-start-time) / count checkouts)
;  set avg-queue-length ( total-chart-queue-time / (ticks - stats-start-time) )
;  ;set final-length-queue (length queue-chk)
;  set total-num-arrivals arrival-count
;  ;set avg-time-queue-of-tags ( total-time-in-queue-chk / total-queue-throughput-chk )
;  ;set avg-time-in-system-of-tags ( total-time-in-system-chk / total-system-throughput-chk )
;  set total-simulation-time-sg ticks
;  set mean-num-collisions-sg ( mean [ num-of-collisions ] of allreaders-set / (ticks - stats-start-time) )
;  set total-num-of-collisions ( sum [ num-of-collisions ] of allreaders-set )
  set avg-cycles-of-sns mean [cycle] of readers with [reader-type = "sns"] / ticks
  set avg-cycles-of-io mean [cycle] of readers with [reader-type = "io"] / ticks
  set avg-cycles-of-inv mean [cycle] of readers with [reader-type = "inv"] / ticks
  set pb-error ifelse-value (total-visitors-die > 0) [1 - (visitor-detect-count / total-visitors-die)][0]
  ;; Network
  set mean-num-links ( mean  [ count my-rris] of allreaders-set )
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
18.0
1
1
NIL
HORIZONTAL

SLIDER
6
172
197
205
interf-rri-radius
interf-rri-radius
0
200
102.0
1
1
 (x 10) m
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
5
328
128
361
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
2
413
174
446
Q
Q
1
15
5.0
1
1
NIL
HORIZONTAL

BUTTON
71
459
134
492
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
4
508
69
553
tot cs /s
mean [cs-t] of checkouts / ticks
1
1
11

MONITOR
70
508
135
553
tot ce /s
mean [ce-t] of checkouts / ticks
1
1
11

MONITOR
140
509
205
554
tot cc /s
mean [cc-t] of checkouts / ticks
1
1
11

MONITOR
4
564
78
609
Efficiency %
precision ((mean [efficiency] of checkouts) * 100) 4
17
1
11

MONITOR
88
564
206
609
Thorughput tgs/ms
precision ((sum [throughput] of checkouts) * 0.001) 4
17
1
11

MONITOR
138
455
202
500
#frames
mean [ frame ] of checkouts
1
1
11

MONITOR
0
627
104
672
Total TM-time (s)
precision ((mean [TM-time] of checkouts) ) 3
3
1
11

SLIDER
836
10
1097
43
mean-arrival-rate
mean-arrival-rate
0.001
30
0.081
0.01
1
per tick
HORIZONTAL

SLIDER
1115
10
1333
43
max-run-time
max-run-time
0
1000000
43200.0
1
1
seconds
HORIZONTAL

BUTTON
3
459
66
492
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
1220
127
1312
172
Current time
ticks
5
1
11

MONITOR
1205
173
1310
218
Next arrival time
next-arrival-time
3
1
11

MONITOR
1209
252
1305
297
Queue length
length queue-chk
3
1
11

SLIDER
834
44
1061
77
mean-pallets-per-truck
mean-pallets-per-truck
0
50
0.0
1
1
pallets
HORIZONTAL

SLIDER
1076
45
1304
78
mean-tags-per-pallet
mean-tags-per-pallet
1
100
20.0
1
1
tags
HORIZONTAL

MONITOR
837
464
954
509
Avg. Queue Length
total-chart-queue-time / (ticks - stats-start-time)
3
1
11

MONITOR
960
463
1075
508
Avg. Time in Queue
total-time-in-queue-chk / total-queue-throughput-chk
3
1
11

MONITOR
1079
463
1197
508
Avg. Time in System
total-time-in-system-chk / total-system-throughput-chk
3
1
11

MONITOR
978
510
1137
555
Tot.System Throughput /s
total-system-throughput-chk / ( ticks )
4
1
11

MONITOR
839
510
975
555
Checkout Utilization %
100 * total-chart-service-time / (ticks - stats-start-time) / count checkouts
3
1
11

MONITOR
107
627
225
672
#Collisions allset
sum [num-of-collisions] of allreaders-set
17
1
11

CHOOSER
5
365
143
410
size-of-frame
size-of-frame
"SFSA" "DFSA"
1

MONITOR
1209
301
1306
346
Num. Arrivals
arrival-count
17
1
11

TEXTBOX
10
679
200
723
- Links Green: one of both ends has TM?\n- Links Red: both ends has TM? -> contention
9
0.0
1

TEXTBOX
1222
233
1300
251
OF TRUCKS
11
0.0
1

TEXTBOX
854
443
920
461
OF TRUCKS
11
0.0
1

TEXTBOX
964
434
1075
459
OF TAGS until pallet is put in service
10
0.0
1

TEXTBOX
1087
433
1191
461
OF TAGS until pallet\nis completed
10
0.0
1

SLIDER
2
233
203
266
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
5
301
215
329
ON : new network and save in 'locations.txt'\nOFF: load network from 'locations.txt'
9
0.0
1

BUTTON
841
557
939
590
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
1141
510
1279
555
Tot. Num. Tags Inventoried
total-system-throughput-chk
3
1
11

MONITOR
226
630
400
671
Mean Num Interf. Links per node
mean  [ count my-rris] of (turtle-set readers checkouts)
2
1
10

TEXTBOX
5
266
202
310
When a pallet has many tags, e.g. 850, the time to inventory is greater than the max-time-of-tag-powered
9
0.0
1

MONITOR
1184
554
1294
599
tags with 1 outage
tags-with-one-outage
17
1
11

MONITOR
1186
597
1305
642
tags with 2 outages
tags-with-two-outage
17
1
11

MONITOR
1001
555
1170
600
Slots with 1 tag and error
tag-unique-with-errors
17
1
11

MONITOR
995
601
1172
638
Slots with >1 tags and 1 is Decoded
tag-with-interf-decod-well
17
1
9

SLIDER
831
90
1092
123
min-power-to-feed-tag-IC
min-power-to-feed-tag-IC
-25
-10
-13.0
0.5
1
dBm
HORIZONTAL

MONITOR
996
639
1172
676
Slots with >1 decoded bad
tag-with-interf-decod-bad
17
1
9

TEXTBOX
834
129
1002
162
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
400
670
574
703
distance-var-x
distance-var-x
1
30
6.0
0.1
1
(m)
HORIZONTAL

MONITOR
1205
465
1350
506
Total Chart Throughput /s
total-charts-throughput / ticks
4
1
10

TEXTBOX
1189
645
1339
667
max-num-of-outages = 5\nnot 2
9
0.0
1

MONITOR
836
599
984
644
Tot.System Outages / s
total-outages / ticks
4
1
11

SLIDER
859
161
1031
194
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
858
199
1056
232
ceiling-to-floor-distance
ceiling-to-floor-distance
1.8
15
3.05
0.05
1
NIL
HORIZONTAL

SLIDER
859
279
1118
312
time-between-inventories
time-between-inventories
0
10
1.0E-9
0.001
1
[ s ]
HORIZONTAL

TEXTBOX
1064
194
1162
222
In this case we have an in-ceiling reader
11
0.0
1

CHOOSER
858
233
1012
278
num-pallets-by-side
num-pallets-by-side
1 2 3 4 5 6 7
0

SLIDER
613
674
917
707
mean-departure-rate
mean-departure-rate
0.0001
0.02
0.0111
0.001
1
per tick
HORIZONTAL

MONITOR
614
721
734
766
Next Depart. time
next-departure-time
6
1
11

SLIDER
738
714
917
747
max-order-percent
max-order-percent
1
50
30.0
1
1
%
HORIZONTAL

MONITOR
615
770
731
815
Total departures
total-departures
17
1
11

SLIDER
618
639
815
672
minimum-stock-level
minimum-stock-level
10
100
80.0
1
1
%
HORIZONTAL

SLIDER
906
755
1146
788
max-inventory-cycles
max-inventory-cycles
50
5000
115.0
5
1
cycles
HORIZONTAL

SLIDER
369
782
605
815
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
371
817
543
850
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
247
738
368
783
NIL
total-lookup-errors
17
1
11

MONITOR
249
788
346
833
NIL
total-lookups
17
1
11

MONITOR
101
796
245
841
failed lookup probability
total-lookup-errors / total-lookups
5
1
11

MONITOR
372
858
489
903
next lookup time
[ next-lookup-time] of super
5
1
11

SLIDER
583
898
868
931
mean-reorganization-rate
mean-reorganization-rate
0
0.01
0.0044
0.0001
1
per tick
HORIZONTAL

MONITOR
874
870
987
915
Next reorg. time
next-reorganization-time
4
1
11

SWITCH
873
834
1014
867
swap-pallets?
swap-pallets?
0
1
-1000

SLIDER
384
750
556
783
max-lookups
max-lookups
10
5000
1000.0
10
1
NIL
HORIZONTAL

TEXTBOX
1178
729
1247
747
Pallet Shape
11
0.0
1

SLIDER
1161
752
1299
785
p-width
p-width
0.2
10
5.0
0.01
1
[m]
HORIZONTAL

SLIDER
1161
790
1300
823
p-depth
p-depth
0.2
10
5.0
0.01
1
[m]
HORIZONTAL

SLIDER
1161
828
1305
861
p-height
p-height
0.4
4
1.75
0.01
1
[m]
HORIZONTAL

MONITOR
990
869
1083
914
Total reorgs.
total-swaps
17
1
11

MONITOR
1015
236
1097
281
NIL
diameter-x
17
1
11

MONITOR
1089
236
1170
281
NIL
diameter-y
17
1
11

TEXTBOX
1164
865
1281
893
Each boxes layer has 0.4m height
11
0.0
1

MONITOR
615
814
732
859
NIL
total-p-arrivals
17
1
11

SLIDER
212
678
387
711
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
749
803
823
848
max cycle
max [cycle] of readers
17
1
11

MONITOR
250
837
360
882
Known tag ratio
precision ((count tags with [inventoried-first?]) / count tags) 4
17
1
11

TEXTBOX
919
709
1010
750
not usable \nin this version \nof simulator
11
0.0
1

SLIDER
1161
905
1307
938
p-base
p-base
0.1
0.4
0.1
0.01
1
[m]
HORIZONTAL

TEXTBOX
919
682
1042
704
Shipped pallets are 8\neach 10 min (0.0017)
9
0.0
1

TEXTBOX
577
935
871
955
Reorganization of a random unif number of the pallets assigned to a reader; 0.0040 ~ 1 each 4min in average
8
0.0
1

MONITOR
615
862
741
899
Total times of p arrivals
moments-of-arrivals
2
1
9

SLIDER
7
140
197
173
num-checkouts
num-checkouts
0
20
0.0
1
1
NIL
HORIZONTAL

TEXTBOX
10
97
194
139
Readers in checkout points\n(num-readers - this = \ncontinuous inventory)
11
0.0
1

SLIDER
858
313
1030
346
portal-width
portal-width
0.5
10
2.3
0.1
1
m
HORIZONTAL

SLIDER
841
365
1013
398
height_1_tx
height_1_tx
0.1
8
1.2
0.1
1
m
HORIZONTAL

SLIDER
841
398
1014
431
height_2_rx
height_2_rx
0.1
8
1.0
0.1
1
m
HORIZONTAL

TEXTBOX
844
349
908
367
Portal LEFT
11
0.0
1

SLIDER
1019
365
1191
398
height_2_tx
height_2_tx
0.1
8
1.2
0.1
1
m
HORIZONTAL

SLIDER
1018
399
1190
432
height_1_rx
height_1_rx
0.1
8
1.0
0.1
1
m
HORIZONTAL

TEXTBOX
1069
349
1154
367
Portal RIGHT
11
0.0
1

SWITCH
1229
397
1355
430
dislocated?
dislocated?
1
1
-1000

SLIDER
1007
125
1189
158
sensitivity-in-reader
sensitivity-in-reader
-100
-50
-80.0
1
1
dBm
HORIZONTAL

TEXTBOX
1314
767
1350
785
0.8m
11
0.0
1

TEXTBOX
1311
804
1351
822
1.2m
11
0.0
1

TEXTBOX
1312
836
1358
854
2.14m
11
0.0
1

SLIDER
400
705
572
738
distance-var-y
distance-var-y
1
100
6.0
1
1
(m)
HORIZONTAL

MONITOR
746
753
874
798
Total inventory cycles
total-inventory-cycles
17
1
11

SLIDER
18
993
263
1026
num-of-content-intervals-inv
num-of-content-intervals-inv
1
10000
100.0
1
1
NIL
HORIZONTAL

TEXTBOX
21
876
234
907
This is the \\delta value, i.e., min. number of trials for ceiling readers. In chk's =1
10
0.0
1

MONITOR
264
884
372
929
average-inv-ratio
average-inv-ratio
5
1
11

SLIDER
1126
85
1350
118
max-num-of-arrivals
max-num-of-arrivals
1000
10000
4140.0
10
1
(arrivals)
HORIZONTAL

SLIDER
63
716
217
749
readers-per-row
readers-per-row
1
50
9.0
1
1
NIL
HORIZONTAL

SLIDER
61
752
217
785
readers-per-column
readers-per-column
1
50
19.0
1
1
NIL
HORIZONTAL

SWITCH
874
795
1005
828
departures?
departures?
1
1
-1000

MONITOR
496
952
570
993
INV cycles/s
mean [cycle] of readers with [reader-type = \"inv\"] / ticks
4
1
10

MONITOR
495
910
569
951
IO cycles/s
mean [cycle] of readers with [reader-type = \"io\"] / ticks
4
1
10

MONITOR
494
869
570
910
SNS cycles/s
mean [cycle] of readers with [reader-type = \"sns\"] / ticks
4
1
10

TEXTBOX
506
852
559
870
Average
11
0.0
1

SLIDER
18
959
261
992
num-of-content-intervals-io
num-of-content-intervals-io
1
10000
100.0
1
1
NIL
HORIZONTAL

SLIDER
18
924
260
957
num-of-content-intervals-sns
num-of-content-intervals-sns
1
10000
100.0
1
1
NIL
HORIZONTAL

SLIDER
807
948
1034
981
mean-p-arrival-rate
mean-p-arrival-rate
0
0.5
0.04
0.0001
1
per tick
HORIZONTAL

SLIDER
806
983
1035
1016
mean-p-departure-rate
mean-p-departure-rate
0
0.5
0.04
0.0001
1
per tick
HORIZONTAL

TEXTBOX
889
931
1019
950
0.008 ~ 30 visitors/h
11
0.0
1

SLIDER
589
959
798
992
time-of-visitor-covered
time-of-visitor-covered
0
10
5.0
0.1
1
[s]
HORIZONTAL

MONITOR
1033
994
1174
1031
next-person-departure-time
next-p-departure-time
10
1
9

MONITOR
1033
956
1173
993
next-person-arrival-time
next-p-arrival-time
10
1
9

MONITOR
1179
957
1265
994
#visitors-dead
total-visitors-die
1
1
9

MONITOR
1171
1040
1279
1077
#persons-under-io
count (turtle-set [my-tags] of readers with [reader-type = \"io\"])
1
1
9

MONITOR
1178
996
1273
1037
visitors detected
visitor-detect-count
1
1
10

MONITOR
1275
955
1374
996
Prob. detect error
ifelse-value (total-visitors-die > 0) [1 - (visitor-detect-count / total-visitors-die)][0]
5
1
10

MONITOR
326
957
490
994
Max. Sampling Freq. per minute
max [sample-count] of (turtle-set [my-tags with [sensor?]] of readers ) / ticks * 60
5
1
9

TEXTBOX
351
939
458
957
Sensors Sampling
11
0.0
1

MONITOR
326
995
491
1032
Min. Sampling Freq. per minute
min [sample-count] of (turtle-set [my-tags with [sensor?]] of readers ) / ticks * 60
4
1
9

MONITOR
326
1035
491
1072
Avg. Sampling Freq. per minute
mean [sample-count] of (turtle-set [my-tags with [sensor?]] of readers ) / ticks * 60
4
1
9

SLIDER
8
202
180
235
dst
dst
0
50
5.0
1
1
m
HORIZONTAL

MONITOR
494
1049
569
1094
io degree
mean  [ count my-rris] of (readers with [reader-type = \"io\"])
4
1
11

MONITOR
494
1003
568
1048
sns degree
mean  [ count my-rris] of (readers with [reader-type = \"sns\"])
4
1
11

MONITOR
494
1094
568
1139
inv degree
mean  [ count my-rris] of (readers with [reader-type = \"inv\"])
4
1
11

SWITCH
32
1042
171
1075
different-seed?
different-seed?
0
1
-1000

SLIDER
33
1091
244
1124
LM-group
LM-group
0.005
0.1
0.005
0.001
1
(min-LM)
HORIZONTAL

MONITOR
574
1006
644
1047
avg-f-sns
avg-f-sns
6
1
10

MONITOR
574
1047
644
1088
NIL
avg-f-io
6
1
10

MONITOR
573
1088
644
1129
NIL
avg-f-inv
6
1
10

MONITOR
721
1023
799
1064
avg-utl
avg-utl
6
1
10

MONITOR
722
1064
799
1105
current-utl
utl
6
1
10

MONITOR
1280
1008
1363
1049
avg-pe-io
avg-pe-io
6
1
10

MONITOR
250
1115
486
1152
delta-sns
map [i -> [delta] of i ] sort readers with [reader-type = \"sns\"]
3
1
9

MONITOR
249
1152
441
1189
delta-io
map [i -> [delta] of i ] sort readers with [reader-type = \"io\"]
2
1
9

MONITOR
249
1191
515
1228
delta-inv
map [i -> [delta] of i ] sort readers with [reader-type = \"inv\"]
2
1
9

MONITOR
648
1005
705
1046
f-sns
(mean [cycle] of readers with [reader-type = \"sns\"] / ticks)
4
1
10

MONITOR
648
1047
705
1088
f-io
(mean [cycle] of readers with [reader-type = \"io\"] / ticks)
4
1
10

MONITOR
648
1089
705
1130
f-inv
(mean [cycle] of readers with [reader-type = \"inv\"] / ticks)
4
1
10

INPUTBOX
801
1029
856
1089
g1_min
1.0
1
0
Number

INPUTBOX
858
1028
909
1088
g1_max
1.5
1
0
Number

INPUTBOX
801
1090
856
1150
g2_min
0.5
1
0
Number

INPUTBOX
859
1088
909
1148
g2_max
1.0
1
0
Number

INPUTBOX
799
1150
855
1210
g3_min
0.045
1
0
Number

INPUTBOX
858
1149
908
1209
g3_max
0.053
1
0
Number

MONITOR
572
1136
684
1173
g-pe-io
map [i -> [group-pe-io] of i ] sort readers with [reader-type = \"io\"]
4
1
9

MONITOR
572
1176
754
1213
err-per-reader
map [i -> [precision reader-pe-io 4] of i ] sort readers with [reader-type = \"io\"]
4
1
9

SWITCH
50
1147
194
1180
synchronous?
synchronous?
0
1
-1000

TEXTBOX
53
1183
203
1209
Tape of rate update of Delta in the doors
10
0.0
1

SLIDER
1172
1080
1363
1113
readers-control-period
readers-control-period
10
600
90.0
1
1
[s]
HORIZONTAL

MONITOR
931
1043
1117
1080
f-period-sns
map [ ? -> [(cycle - cycle-last-epoch )] of ?] (sort-on [who] readers with [reader-type = \"sns\" ] )
5
1
9

MONITOR
931
1081
1040
1118
f-period-io
map [ ? -> [(cycle - cycle-last-epoch )] of ?] (sort-on [who] readers with [reader-type = \"io\" ] )
5
1
9

MONITOR
930
1123
1110
1160
f-period-inv
map [ ? -> [(cycle - cycle-last-epoch )] of ?] (sort-on [who] readers with [reader-type = \"inv\" ] )
5
1
9

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
  <experiment name="delta3_100_bak" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>avg-cycles-of-sns</metric>
    <metric>avg-cycles-of-io</metric>
    <metric>avg-cycles-of-inv</metric>
    <metric>mean-num-links</metric>
    <metric>pb-error</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="109"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-sns">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-io">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
      <value value="25"/>
      <value value="30"/>
      <value value="35"/>
      <value value="40"/>
      <value value="45"/>
      <value value="50"/>
      <value value="55"/>
      <value value="60"/>
      <value value="65"/>
      <value value="70"/>
      <value value="75"/>
      <value value="80"/>
      <value value="85"/>
      <value value="90"/>
      <value value="95"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-inv">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="115"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-num-of-arrivals">
      <value value="4140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0091"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-departure-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="departures?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="6.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dst">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-checkouts">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-arrival-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="1.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sensitivity-in-reader">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="3.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="2400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-of-visitor-covered">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LM-group">
      <value value="0.005"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.004"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="delta3_1000_bak" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>avg-cycles-of-sns</metric>
    <metric>avg-cycles-of-io</metric>
    <metric>avg-cycles-of-inv</metric>
    <metric>mean-num-links</metric>
    <metric>pb-error</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="109"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-sns">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-io">
      <value value="1"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="100"/>
      <value value="125"/>
      <value value="150"/>
      <value value="175"/>
      <value value="200"/>
      <value value="225"/>
      <value value="250"/>
      <value value="275"/>
      <value value="300"/>
      <value value="325"/>
      <value value="350"/>
      <value value="375"/>
      <value value="400"/>
      <value value="425"/>
      <value value="450"/>
      <value value="475"/>
      <value value="500"/>
      <value value="525"/>
      <value value="550"/>
      <value value="575"/>
      <value value="600"/>
      <value value="625"/>
      <value value="650"/>
      <value value="675"/>
      <value value="700"/>
      <value value="725"/>
      <value value="750"/>
      <value value="775"/>
      <value value="800"/>
      <value value="825"/>
      <value value="850"/>
      <value value="875"/>
      <value value="900"/>
      <value value="925"/>
      <value value="950"/>
      <value value="975"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-inv">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="115"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-num-of-arrivals">
      <value value="4140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0091"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-departure-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="departures?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="6.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dst">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-checkouts">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-arrival-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="1.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sensitivity-in-reader">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="3.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="2400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-of-visitor-covered">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LM-group">
      <value value="0.005"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.004"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="delta3_100_8" repetitions="8" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>avg-cycles-of-sns</metric>
    <metric>avg-cycles-of-io</metric>
    <metric>avg-cycles-of-inv</metric>
    <metric>mean-num-links</metric>
    <metric>pb-error</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="102"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-sns">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-io">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
      <value value="25"/>
      <value value="30"/>
      <value value="35"/>
      <value value="40"/>
      <value value="45"/>
      <value value="50"/>
      <value value="55"/>
      <value value="60"/>
      <value value="65"/>
      <value value="70"/>
      <value value="75"/>
      <value value="80"/>
      <value value="85"/>
      <value value="90"/>
      <value value="95"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-inv">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="115"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-num-of-arrivals">
      <value value="4140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0091"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-departure-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="departures?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.081"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dst">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-checkouts">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-arrival-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="1.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sensitivity-in-reader">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="1.0E-9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="3.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="3600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-of-visitor-covered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.004"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LM-group">
      <value value="0.005"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="delta3_1000" repetitions="8" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>avg-cycles-of-sns</metric>
    <metric>avg-cycles-of-io</metric>
    <metric>avg-cycles-of-inv</metric>
    <metric>mean-num-links</metric>
    <metric>pb-error</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="102"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-sns">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-io">
      <value value="1"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="100"/>
      <value value="125"/>
      <value value="150"/>
      <value value="175"/>
      <value value="200"/>
      <value value="225"/>
      <value value="250"/>
      <value value="275"/>
      <value value="300"/>
      <value value="325"/>
      <value value="350"/>
      <value value="375"/>
      <value value="400"/>
      <value value="425"/>
      <value value="450"/>
      <value value="475"/>
      <value value="500"/>
      <value value="525"/>
      <value value="550"/>
      <value value="575"/>
      <value value="600"/>
      <value value="625"/>
      <value value="650"/>
      <value value="675"/>
      <value value="700"/>
      <value value="725"/>
      <value value="750"/>
      <value value="775"/>
      <value value="800"/>
      <value value="825"/>
      <value value="850"/>
      <value value="875"/>
      <value value="900"/>
      <value value="925"/>
      <value value="950"/>
      <value value="975"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-inv">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="115"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-num-of-arrivals">
      <value value="4140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0091"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-departure-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="departures?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.081"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dst">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-checkouts">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-arrival-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="1.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sensitivity-in-reader">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="1.0E-9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="3.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="3600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-of-visitor-covered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.004"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LM-group">
      <value value="0.005"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="delta3_100" repetitions="15" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>avg-cycles-of-sns</metric>
    <metric>avg-cycles-of-io</metric>
    <metric>avg-cycles-of-inv</metric>
    <metric>mean-num-links</metric>
    <metric>pb-error</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="102"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-sns">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-io">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
      <value value="25"/>
      <value value="30"/>
      <value value="35"/>
      <value value="40"/>
      <value value="45"/>
      <value value="50"/>
      <value value="55"/>
      <value value="60"/>
      <value value="65"/>
      <value value="70"/>
      <value value="75"/>
      <value value="80"/>
      <value value="85"/>
      <value value="90"/>
      <value value="95"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-inv">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="115"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-num-of-arrivals">
      <value value="4140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0091"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-departure-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="departures?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.081"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dst">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-checkouts">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-arrival-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="1.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sensitivity-in-reader">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="1.0E-9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="3.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="4800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-of-visitor-covered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.004"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LM-group">
      <value value="0.005"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="utl1_500" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>avg-cycles-of-sns</metric>
    <metric>avg-cycles-of-io</metric>
    <metric>avg-cycles-of-inv</metric>
    <metric>utl</metric>
    <metric>mean-num-links</metric>
    <metric>pb-error</metric>
    <metric>avg-f-inv</metric>
    <metric>avg-f-io</metric>
    <metric>avg-f-sns</metric>
    <metric>avg-utl</metric>
    <metric>avg-pe-io</metric>
    <metric>f-count</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="102"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-sns">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-io">
      <value value="1"/>
      <value value="20"/>
      <value value="40"/>
      <value value="60"/>
      <value value="80"/>
      <value value="100"/>
      <value value="120"/>
      <value value="140"/>
      <value value="160"/>
      <value value="180"/>
      <value value="200"/>
      <value value="220"/>
      <value value="240"/>
      <value value="260"/>
      <value value="280"/>
      <value value="300"/>
      <value value="320"/>
      <value value="340"/>
      <value value="360"/>
      <value value="380"/>
      <value value="400"/>
      <value value="420"/>
      <value value="440"/>
      <value value="460"/>
      <value value="480"/>
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-inv">
      <value value="1"/>
      <value value="20"/>
      <value value="40"/>
      <value value="60"/>
      <value value="80"/>
      <value value="100"/>
      <value value="120"/>
      <value value="140"/>
      <value value="160"/>
      <value value="180"/>
      <value value="200"/>
      <value value="220"/>
      <value value="240"/>
      <value value="260"/>
      <value value="280"/>
      <value value="300"/>
      <value value="320"/>
      <value value="340"/>
      <value value="360"/>
      <value value="380"/>
      <value value="400"/>
      <value value="420"/>
      <value value="440"/>
      <value value="460"/>
      <value value="480"/>
      <value value="500"/>
      <value value="520"/>
      <value value="540"/>
      <value value="560"/>
      <value value="580"/>
      <value value="600"/>
      <value value="620"/>
      <value value="640"/>
      <value value="660"/>
      <value value="680"/>
      <value value="700"/>
      <value value="720"/>
      <value value="740"/>
      <value value="760"/>
      <value value="780"/>
      <value value="800"/>
      <value value="820"/>
      <value value="840"/>
      <value value="860"/>
      <value value="880"/>
      <value value="900"/>
      <value value="920"/>
      <value value="940"/>
      <value value="960"/>
      <value value="980"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="115"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-num-of-arrivals">
      <value value="4140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0091"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-departure-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="departures?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.081"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dst">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-checkouts">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-arrival-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="1.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sensitivity-in-reader">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="1.0E-9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="3.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="4800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-of-visitor-covered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.004"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LM-group">
      <value value="0.005"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="utl520_1000" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>avg-cycles-of-sns</metric>
    <metric>avg-cycles-of-io</metric>
    <metric>avg-cycles-of-inv</metric>
    <metric>utl</metric>
    <metric>mean-num-links</metric>
    <metric>pb-error</metric>
    <metric>avg-f-inv</metric>
    <metric>avg-f-io</metric>
    <metric>avg-f-sns</metric>
    <metric>avg-utl</metric>
    <metric>avg-pe-io</metric>
    <metric>f-count</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="102"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-sns">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-io">
      <value value="520"/>
      <value value="540"/>
      <value value="560"/>
      <value value="580"/>
      <value value="600"/>
      <value value="620"/>
      <value value="640"/>
      <value value="660"/>
      <value value="680"/>
      <value value="700"/>
      <value value="720"/>
      <value value="740"/>
      <value value="760"/>
      <value value="780"/>
      <value value="800"/>
      <value value="820"/>
      <value value="840"/>
      <value value="860"/>
      <value value="880"/>
      <value value="900"/>
      <value value="920"/>
      <value value="940"/>
      <value value="960"/>
      <value value="980"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-inv">
      <value value="1"/>
      <value value="20"/>
      <value value="40"/>
      <value value="60"/>
      <value value="80"/>
      <value value="100"/>
      <value value="120"/>
      <value value="140"/>
      <value value="160"/>
      <value value="180"/>
      <value value="200"/>
      <value value="220"/>
      <value value="240"/>
      <value value="260"/>
      <value value="280"/>
      <value value="300"/>
      <value value="320"/>
      <value value="340"/>
      <value value="360"/>
      <value value="380"/>
      <value value="400"/>
      <value value="420"/>
      <value value="440"/>
      <value value="460"/>
      <value value="480"/>
      <value value="500"/>
      <value value="520"/>
      <value value="540"/>
      <value value="560"/>
      <value value="580"/>
      <value value="600"/>
      <value value="620"/>
      <value value="640"/>
      <value value="660"/>
      <value value="680"/>
      <value value="700"/>
      <value value="720"/>
      <value value="740"/>
      <value value="760"/>
      <value value="780"/>
      <value value="800"/>
      <value value="820"/>
      <value value="840"/>
      <value value="860"/>
      <value value="880"/>
      <value value="900"/>
      <value value="920"/>
      <value value="940"/>
      <value value="960"/>
      <value value="980"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="115"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-num-of-arrivals">
      <value value="4140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0091"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-departure-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="departures?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.081"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dst">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-checkouts">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-arrival-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="1.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sensitivity-in-reader">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="1.0E-9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="3.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="4800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-of-visitor-covered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.004"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LM-group">
      <value value="0.005"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="utl_test" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>avg-cycles-of-sns</metric>
    <metric>avg-cycles-of-io</metric>
    <metric>avg-cycles-of-inv</metric>
    <metric>utl</metric>
    <metric>mean-num-links</metric>
    <metric>pb-error</metric>
    <metric>avg-f-inv</metric>
    <metric>avg-f-io</metric>
    <metric>avg-f-sns</metric>
    <metric>avg-utl</metric>
    <metric>avg-pe-io</metric>
    <metric>f-count</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="102"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-sns">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-io">
      <value value="1"/>
      <value value="40"/>
      <value value="80"/>
      <value value="120"/>
      <value value="160"/>
      <value value="200"/>
      <value value="240"/>
      <value value="280"/>
      <value value="320"/>
      <value value="360"/>
      <value value="400"/>
      <value value="440"/>
      <value value="480"/>
      <value value="520"/>
      <value value="560"/>
      <value value="600"/>
      <value value="640"/>
      <value value="680"/>
      <value value="720"/>
      <value value="760"/>
      <value value="800"/>
      <value value="840"/>
      <value value="880"/>
      <value value="920"/>
      <value value="960"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-inv">
      <value value="1"/>
      <value value="40"/>
      <value value="80"/>
      <value value="120"/>
      <value value="160"/>
      <value value="200"/>
      <value value="240"/>
      <value value="280"/>
      <value value="320"/>
      <value value="360"/>
      <value value="400"/>
      <value value="440"/>
      <value value="480"/>
      <value value="520"/>
      <value value="560"/>
      <value value="600"/>
      <value value="640"/>
      <value value="680"/>
      <value value="720"/>
      <value value="760"/>
      <value value="800"/>
      <value value="840"/>
      <value value="880"/>
      <value value="920"/>
      <value value="960"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="115"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-num-of-arrivals">
      <value value="4140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0091"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-departure-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="departures?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.081"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dst">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-checkouts">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-arrival-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="1.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sensitivity-in-reader">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="1.0E-9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="3.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="3600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-of-visitor-covered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.004"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LM-group">
      <value value="0.005"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="utl_test_1" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>avg-cycles-of-sns</metric>
    <metric>avg-cycles-of-io</metric>
    <metric>avg-cycles-of-inv</metric>
    <metric>utl</metric>
    <metric>mean-num-links</metric>
    <metric>pb-error</metric>
    <metric>avg-f-inv</metric>
    <metric>avg-f-io</metric>
    <metric>avg-f-sns</metric>
    <metric>avg-utl</metric>
    <metric>avg-pe-io</metric>
    <metric>f-count</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="102"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-sns">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-io">
      <value value="1"/>
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
      <value value="200"/>
      <value value="250"/>
      <value value="300"/>
      <value value="350"/>
      <value value="400"/>
      <value value="450"/>
      <value value="500"/>
      <value value="550"/>
      <value value="600"/>
      <value value="650"/>
      <value value="700"/>
      <value value="750"/>
      <value value="800"/>
      <value value="850"/>
      <value value="900"/>
      <value value="950"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-inv">
      <value value="1"/>
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
      <value value="200"/>
      <value value="250"/>
      <value value="300"/>
      <value value="350"/>
      <value value="400"/>
      <value value="450"/>
      <value value="500"/>
      <value value="550"/>
      <value value="600"/>
      <value value="650"/>
      <value value="700"/>
      <value value="750"/>
      <value value="800"/>
      <value value="850"/>
      <value value="900"/>
      <value value="950"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="115"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-num-of-arrivals">
      <value value="4140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0091"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-departure-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="departures?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.081"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dst">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-checkouts">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-arrival-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="1.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sensitivity-in-reader">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="1.0E-9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="3.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="2400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-of-visitor-covered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.004"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LM-group">
      <value value="0.005"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="utl_1_1000a" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>avg-cycles-of-sns</metric>
    <metric>avg-cycles-of-io</metric>
    <metric>avg-cycles-of-inv</metric>
    <metric>utl</metric>
    <metric>mean-num-links</metric>
    <metric>pb-error</metric>
    <metric>avg-f-inv</metric>
    <metric>avg-f-io</metric>
    <metric>avg-f-sns</metric>
    <metric>avg-utl</metric>
    <metric>avg-pe-io</metric>
    <metric>f-count</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="102"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-sns">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-io">
      <value value="1"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="100"/>
      <value value="125"/>
      <value value="150"/>
      <value value="175"/>
      <value value="200"/>
      <value value="225"/>
      <value value="250"/>
      <value value="275"/>
      <value value="300"/>
      <value value="325"/>
      <value value="350"/>
      <value value="375"/>
      <value value="400"/>
      <value value="425"/>
      <value value="450"/>
      <value value="475"/>
      <value value="500"/>
      <value value="525"/>
      <value value="550"/>
      <value value="575"/>
      <value value="600"/>
      <value value="625"/>
      <value value="650"/>
      <value value="675"/>
      <value value="700"/>
      <value value="725"/>
      <value value="750"/>
      <value value="775"/>
      <value value="800"/>
      <value value="825"/>
      <value value="850"/>
      <value value="875"/>
      <value value="900"/>
      <value value="925"/>
      <value value="950"/>
      <value value="975"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-inv">
      <value value="1"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="100"/>
      <value value="125"/>
      <value value="150"/>
      <value value="175"/>
      <value value="200"/>
      <value value="225"/>
      <value value="250"/>
      <value value="275"/>
      <value value="300"/>
      <value value="325"/>
      <value value="350"/>
      <value value="375"/>
      <value value="400"/>
      <value value="425"/>
      <value value="450"/>
      <value value="475"/>
      <value value="500"/>
      <value value="525"/>
      <value value="550"/>
      <value value="575"/>
      <value value="600"/>
      <value value="625"/>
      <value value="650"/>
      <value value="675"/>
      <value value="700"/>
      <value value="725"/>
      <value value="750"/>
      <value value="775"/>
      <value value="800"/>
      <value value="825"/>
      <value value="850"/>
      <value value="875"/>
      <value value="900"/>
      <value value="925"/>
      <value value="950"/>
      <value value="975"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="115"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-num-of-arrivals">
      <value value="4140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0091"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-departure-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="departures?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.081"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dst">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-checkouts">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-arrival-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="1.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sensitivity-in-reader">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="1.0E-9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="3.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="2400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-of-visitor-covered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.004"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LM-group">
      <value value="0.005"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="utl_1_1000" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>avg-cycles-of-sns</metric>
    <metric>avg-cycles-of-io</metric>
    <metric>avg-cycles-of-inv</metric>
    <metric>utl</metric>
    <metric>mean-num-links</metric>
    <metric>pb-error</metric>
    <metric>avg-f-inv</metric>
    <metric>avg-f-io</metric>
    <metric>avg-f-sns</metric>
    <metric>avg-utl</metric>
    <metric>avg-pe-io</metric>
    <metric>f-count</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="102"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-sns">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-io">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
      <value value="25"/>
      <value value="30"/>
      <value value="35"/>
      <value value="40"/>
      <value value="45"/>
      <value value="50"/>
      <value value="55"/>
      <value value="60"/>
      <value value="65"/>
      <value value="70"/>
      <value value="75"/>
      <value value="80"/>
      <value value="85"/>
      <value value="90"/>
      <value value="95"/>
      <value value="100"/>
      <value value="105"/>
      <value value="110"/>
      <value value="115"/>
      <value value="120"/>
      <value value="125"/>
      <value value="130"/>
      <value value="135"/>
      <value value="140"/>
      <value value="145"/>
      <value value="150"/>
      <value value="155"/>
      <value value="160"/>
      <value value="165"/>
      <value value="170"/>
      <value value="175"/>
      <value value="180"/>
      <value value="185"/>
      <value value="190"/>
      <value value="195"/>
      <value value="200"/>
      <value value="205"/>
      <value value="210"/>
      <value value="215"/>
      <value value="220"/>
      <value value="225"/>
      <value value="230"/>
      <value value="235"/>
      <value value="240"/>
      <value value="245"/>
      <value value="250"/>
      <value value="255"/>
      <value value="260"/>
      <value value="265"/>
      <value value="270"/>
      <value value="275"/>
      <value value="280"/>
      <value value="285"/>
      <value value="290"/>
      <value value="295"/>
      <value value="300"/>
      <value value="305"/>
      <value value="310"/>
      <value value="315"/>
      <value value="320"/>
      <value value="325"/>
      <value value="330"/>
      <value value="335"/>
      <value value="340"/>
      <value value="345"/>
      <value value="350"/>
      <value value="355"/>
      <value value="360"/>
      <value value="365"/>
      <value value="370"/>
      <value value="375"/>
      <value value="380"/>
      <value value="385"/>
      <value value="390"/>
      <value value="395"/>
      <value value="400"/>
      <value value="405"/>
      <value value="410"/>
      <value value="415"/>
      <value value="420"/>
      <value value="425"/>
      <value value="430"/>
      <value value="435"/>
      <value value="440"/>
      <value value="445"/>
      <value value="450"/>
      <value value="455"/>
      <value value="460"/>
      <value value="465"/>
      <value value="470"/>
      <value value="475"/>
      <value value="480"/>
      <value value="485"/>
      <value value="490"/>
      <value value="495"/>
      <value value="500"/>
      <value value="505"/>
      <value value="510"/>
      <value value="515"/>
      <value value="520"/>
      <value value="525"/>
      <value value="530"/>
      <value value="535"/>
      <value value="540"/>
      <value value="545"/>
      <value value="550"/>
      <value value="555"/>
      <value value="560"/>
      <value value="565"/>
      <value value="570"/>
      <value value="575"/>
      <value value="580"/>
      <value value="585"/>
      <value value="590"/>
      <value value="595"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-inv">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
      <value value="25"/>
      <value value="30"/>
      <value value="35"/>
      <value value="40"/>
      <value value="45"/>
      <value value="50"/>
      <value value="55"/>
      <value value="60"/>
      <value value="65"/>
      <value value="70"/>
      <value value="75"/>
      <value value="80"/>
      <value value="85"/>
      <value value="90"/>
      <value value="95"/>
      <value value="100"/>
      <value value="105"/>
      <value value="110"/>
      <value value="115"/>
      <value value="120"/>
      <value value="125"/>
      <value value="130"/>
      <value value="135"/>
      <value value="140"/>
      <value value="145"/>
      <value value="150"/>
      <value value="155"/>
      <value value="160"/>
      <value value="165"/>
      <value value="170"/>
      <value value="175"/>
      <value value="180"/>
      <value value="185"/>
      <value value="190"/>
      <value value="195"/>
      <value value="200"/>
      <value value="205"/>
      <value value="210"/>
      <value value="215"/>
      <value value="220"/>
      <value value="225"/>
      <value value="230"/>
      <value value="235"/>
      <value value="240"/>
      <value value="245"/>
      <value value="250"/>
      <value value="255"/>
      <value value="260"/>
      <value value="265"/>
      <value value="270"/>
      <value value="275"/>
      <value value="280"/>
      <value value="285"/>
      <value value="290"/>
      <value value="295"/>
      <value value="300"/>
      <value value="305"/>
      <value value="310"/>
      <value value="315"/>
      <value value="320"/>
      <value value="325"/>
      <value value="330"/>
      <value value="335"/>
      <value value="340"/>
      <value value="345"/>
      <value value="350"/>
      <value value="355"/>
      <value value="360"/>
      <value value="365"/>
      <value value="370"/>
      <value value="375"/>
      <value value="380"/>
      <value value="385"/>
      <value value="390"/>
      <value value="395"/>
      <value value="400"/>
      <value value="405"/>
      <value value="410"/>
      <value value="415"/>
      <value value="420"/>
      <value value="425"/>
      <value value="430"/>
      <value value="435"/>
      <value value="440"/>
      <value value="445"/>
      <value value="450"/>
      <value value="455"/>
      <value value="460"/>
      <value value="465"/>
      <value value="470"/>
      <value value="475"/>
      <value value="480"/>
      <value value="485"/>
      <value value="490"/>
      <value value="495"/>
      <value value="500"/>
      <value value="505"/>
      <value value="510"/>
      <value value="515"/>
      <value value="520"/>
      <value value="525"/>
      <value value="530"/>
      <value value="535"/>
      <value value="540"/>
      <value value="545"/>
      <value value="550"/>
      <value value="555"/>
      <value value="560"/>
      <value value="565"/>
      <value value="570"/>
      <value value="575"/>
      <value value="580"/>
      <value value="585"/>
      <value value="590"/>
      <value value="595"/>
      <value value="600"/>
      <value value="605"/>
      <value value="610"/>
      <value value="615"/>
      <value value="620"/>
      <value value="625"/>
      <value value="630"/>
      <value value="635"/>
      <value value="640"/>
      <value value="645"/>
      <value value="650"/>
      <value value="655"/>
      <value value="660"/>
      <value value="665"/>
      <value value="670"/>
      <value value="675"/>
      <value value="680"/>
      <value value="685"/>
      <value value="690"/>
      <value value="695"/>
      <value value="700"/>
      <value value="705"/>
      <value value="710"/>
      <value value="715"/>
      <value value="720"/>
      <value value="725"/>
      <value value="730"/>
      <value value="735"/>
      <value value="740"/>
      <value value="745"/>
      <value value="750"/>
      <value value="755"/>
      <value value="760"/>
      <value value="765"/>
      <value value="770"/>
      <value value="775"/>
      <value value="780"/>
      <value value="785"/>
      <value value="790"/>
      <value value="795"/>
      <value value="800"/>
      <value value="805"/>
      <value value="810"/>
      <value value="815"/>
      <value value="820"/>
      <value value="825"/>
      <value value="830"/>
      <value value="835"/>
      <value value="840"/>
      <value value="845"/>
      <value value="850"/>
      <value value="855"/>
      <value value="860"/>
      <value value="865"/>
      <value value="870"/>
      <value value="875"/>
      <value value="880"/>
      <value value="885"/>
      <value value="890"/>
      <value value="895"/>
      <value value="900"/>
      <value value="905"/>
      <value value="910"/>
      <value value="915"/>
      <value value="920"/>
      <value value="925"/>
      <value value="930"/>
      <value value="935"/>
      <value value="940"/>
      <value value="945"/>
      <value value="950"/>
      <value value="955"/>
      <value value="960"/>
      <value value="965"/>
      <value value="970"/>
      <value value="975"/>
      <value value="980"/>
      <value value="985"/>
      <value value="990"/>
      <value value="995"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="115"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-num-of-arrivals">
      <value value="4140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0091"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-departure-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="departures?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.081"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dst">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-checkouts">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-arrival-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="1.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sensitivity-in-reader">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="1.0E-9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="3.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="2400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-of-visitor-covered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.004"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LM-group">
      <value value="0.005"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="test1" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>avg-cycles-of-sns</metric>
    <metric>avg-cycles-of-io</metric>
    <metric>avg-cycles-of-inv</metric>
    <metric>utl</metric>
    <metric>mean-num-links</metric>
    <metric>pb-error</metric>
    <metric>avg-f-inv</metric>
    <metric>avg-f-io</metric>
    <metric>avg-f-sns</metric>
    <metric>avg-utl</metric>
    <metric>avg-pe-io</metric>
    <metric>f-count</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="102"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-inv">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-num-of-arrivals">
      <value value="4140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0111"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-departure-rate">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="g2_min">
      <value value="0.23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.081"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="synchronous?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="g3_max">
      <value value="0.056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-checkouts">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-arrival-rate">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="1.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="1.0E-9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="3.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="43200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-of-visitor-covered">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LM-group">
      <value value="0.005"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0044"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="115"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="g3_min">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="departures?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="g1_max">
      <value value="1.65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-io">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dst">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sensitivity-in-reader">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-sns">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="g1_min">
      <value value="1.27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="g2_max">
      <value value="0.476"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="test2" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>avg-cycles-of-sns</metric>
    <metric>avg-cycles-of-io</metric>
    <metric>avg-cycles-of-inv</metric>
    <metric>utl</metric>
    <metric>mean-num-links</metric>
    <metric>pb-error</metric>
    <metric>avg-f-inv</metric>
    <metric>avg-f-io</metric>
    <metric>avg-f-sns</metric>
    <metric>avg-utl</metric>
    <metric>avg-pe-io</metric>
    <metric>f-count</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="102"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-inv">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-stock-level">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lookup-rate">
      <value value="0.0056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-num-of-arrivals">
      <value value="4140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-depth">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-departure-rate">
      <value value="0.0111"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-departure-rate">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="g2_min">
      <value value="0.23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.081"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="synchronous?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="g3_max">
      <value value="0.056"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-checkouts">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-lookups">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-p-arrival-rate">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-height">
      <value value="1.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="different-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-order-percent">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-base">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-pallets-by-side">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-between-inventories">
      <value value="1.0E-9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ceiling-to-floor-distance">
      <value value="3.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="43200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-of-visitor-covered">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LM-group">
      <value value="0.005"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-reorganization-rate">
      <value value="0.0044"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="swap-pallets?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-supervisors">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-inventory-cycles">
      <value value="115"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="g3_min">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="departures?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="g1_max">
      <value value="1.65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-io">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dst">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-tag-groups">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sensitivity-in-reader">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-width">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-content-intervals-sns">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="g1_min">
      <value value="1.27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="g2_max">
      <value value="0.476"/>
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
