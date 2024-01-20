;; 4) under construction a discrete event LBT, 6-12-2017
;; 5) I have realize that we must indicate clearly the end of TM
;; 6) I am going to adjust the "time to complete"
;; 7) compute the time to complete a group of tags redings
;; 8) going to change GO and add discrete event engine
;; 9) change begin-service
;; TEST1 is to test max-TM = 4s

;; There is a Pc capture and prob error.
;; The prob of capture is (1/2)^(s-1)
;; new from _03 : Power Outage
;; tags-loose-memory ----counting
;; efficiency = cs/(K)
;; TEST CONTINUOUS INVENTORY
;;
;; Note polarz mismatch is 1 because we use directivity formulas
;; Also tag gains set and reader sensitivity
breed [ readers reader ]
undirected-link-breed [ rris rri ]
breed [ tags tag ]
breed [ pallets pallet ]
breed [ trucks truck ]

trucks-own [
  pallets-in-truck
  total-pallets
  time-entered-queue
]
pallets-own [
  num-tags-in-pallet
  tags-in-pallet
  still-not-inventoried ; true if pallet is  being inventoried
  pallet-distance ; min ( list random normal [2,1] 3 ) or U[ 2 - 1 , 2 + 1 ] metros
  ; also max (list  min (list random-normal 2 0.8 3) 1)
  reading-pallet-time
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

  reader-gain-tx-rx ;
  ;reader-gain-tx ;for R2R interferences
  ;reader-gain-rx ;for R2R interferences
  reader-frequency  ; reader carrier frequency
  reader-sensitivity
  reader-read-error
  reader-outage-count
  even-frame? ; to know alternative frames: even h1=1.4 and odd h1= 2.2
  ;
  queue-r ; is a list of truck agents
  ;total-batches-of-reader ; backlog of tags
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
  distance-to-reader_1_fw ; there are two readers per docking portal
  distance-to-reader_1_bw
  distance-to-reader_2_fw
  distance-to-reader_2_bw
  ; the postition of the tag in the pallet
  ; relative to pallet-position
  tag-x ; U(-0.75 , 0.75) + pallet-distance gives D of my alculations ; This is my 'D'
  D_1 D_2
  tag-y ; U(0.10, 1.20) This is my 'h2'
  tag-z ; U( depth-of-pallet )
  tag-power-rx ; to see if there is a power outage or not
               ; which depends on R that is ( D + (h1+h2)^2 /(2D) )
  tag-outage? ; it can be not powered depends of the position in the pallet
  ;tag-gain
  tag-gain-fw
  tag-gain-bw
  tag-sensitivity
  q_e_fw q_e_bw
  q_e_rcn_fw
  shadow_fw
  outage-count-of-this-tag
  ;; this angles with respect the reader beam
  ;; (to compute directivity gain of Reader Tx/Rx antenna)
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

globals [
  xy-file
  queue-file
  queue-length
  num-of-queue-samples ; 1, 2, ....50
  ; Q 1..15 ; determine the number of slotSS (K= 2^Q)
  t1S t1C t1E ; times of successful collision and empty slot 1
  tS tC tE    ; times of successful collision and empty any slot in frame 2..2^Q
  min-LM max-TM TM-to-LM-time ; time limits for receiver mode plus the time after TM
  tiny-num
  tau ; propagation time by metre of the reader's signal
  queue ; waiting line
  arrival-count ; Arrival process (for trucks, for now)
  next-arrival-time
  ; Statistics for average load/usage of queue and servers
  stats-start-time
  total-truck-queue-time
  total-tag-queue-time
  total-tag-service-time
  total-truck-service-time
  ; Statistics for average time-in-queue and time-in-service
  total-time-in-queue
  total-time-in-system
  total-queue-throughput
  total-system-throughput
  ; Theoretical measures, computed analytically using classic queueing theory
  expected-utilization
  expected-queue-length
  expected-queue-time
  ; Anonymous procedures
  end-run-task
  arrive-task
  complete-service-task
  ; reset-stats-task ; unnecessary for now
  ; plus
  start-LM-task
  start-TM-task
  ;;;
  ;;variables for BS reporters
  total-system-throughput-sg
  total-pallets-thoughput-sg
  total-tags-inventoried
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
  total-outages
  total-offered-load-of-pallets
  total-offered-load-of-tags
  total-offered-load-of-tags-sg
  total-offered-load-of-pallets-sg
  average-S1 average-S2
  average-efficiency
  ACPR_linear ;Adjacent Channel Power Ratio, in the DRE masc is 30dB
  ;;
  ;;-------------------  OJO  ----------------------
  total-reading-time
  total-reading-time-square
  num-pallets-completely-read
  num-pallets-not-completely-read
  total-tags-not-inventoried
  mean-tags-not-inventoried
  total-pallets-th
  read-failures-probability ; (num-pallets-not-completely-read / total-pallets-th)
  mean-of-tags
  total-mytags
  ;;-----------------------------------------------
  ;
  ;non-completed-percent1 ; for the th (ok)
  ;non-completed-percent2 ; for the thoughput
  ;non-completed-percent3 ; for the max
  mean-reading-time-of-pallets
  variance-reading-time-of-pallets
]

;to startup
;  setup
;end

to setup-timeconstants
  set t1S 0.00283 set t1C 0.00074 set t1E 0.00046 ; slot 1 of PQuery
  set tS 0.00258 set tC 0.00049 set tE 0.00021 ; slots 2..K of QRep
  set min-LM 0.005 set max-TM 4 set TM-to-LM-time 0.1 ; time limits for each mode
  set empty-frames-TM 0.00109 ; time threshold of 3 frames empty and Pquery empty after completition
  set tiny-num 0.000000001 ; 1ns
  set tau 0.000000003 ; 3ns, propagation time by metre of the reader's signal
  set tags-loose-memory 0 ; to count the tags left expire the memory time.
end

to setup-globals
  ;set xy-file "locations20R.txt"
  ifelse not random-topology? [
    set xy-file (word "regular" num-readers ".txt")
  ] [ set xy-file (word "random" num-readers ".txt") ]
  ;set queue-file (word "queue-length-" mean-arrival-rate ".txt")
  set queue-file (word "queue-length-" mean-arrival-rate "-" behaviorspace-run-number ".txt")
  set num-of-queue-samples 0
  set queue-length (list )
  set queue []
  set next-arrival-time 0
  set arrival-count 0
  set-default-shape readers "square 2" ; circle
  set-default-shape tags "x"
  set stats-start-time 0
  ; now the globals for the Link budget
  ;set polarz-mismatch 0.5      ; X ~ 0.5
  set polarz-mismatch 1      ; Set 1 because is included in the tag-gain's which depends on random angle.
  set pow-tx-coefficient 1  ; \tau ~ 1
  set modulation-factor 0.25   ; M indicates the energy reflected by the tag for 0's and 1's
  set on-object-gain-penalty 1.2
  set path-blockages 1
  ;set fading-factor-fw 10 ; 10 for a P(outage >= 0.05 ) con K = 3dB
  ;set fading-factor-bw ifelse-value dislocated? [ 32 ] [ 126 ]

  set fading-factor-fw 1
  set fading-factor-bw ifelse-value dislocated? [ 1 ] [ 1 ]

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
  set max-num-of-outages 10
  set total-offered-load-of-pallets 0
  set total-offered-load-of-tags 0

  set ACPR_linear 10 ^ (30 / 10) ;30dB
  if (transmitter-power <= 0.1) [set interf-threshold -83]
  if (transmitter-power > 0.1) and (transmitter-power <= 0.5) [set interf-threshold -90]
  if (transmitter-power >= 0.5) [set interf-threshold -96]
end

to setup
  clear-all
  ;random-seed behaviorspace-run-number
  ;random-seed 100
  reset-ticks
  tick-advance 1E-9
  setup-globals
  setup-timeconstants
  ask patches [ set pcolor blue - 3 ]
  setup-readers
  setup-tasks
  ;reset-ticks
  reset-stats
  schedule-arrival
end

;; Sets up anonymous procedures for event queue
to setup-tasks
  set end-run-task [[?ignore] -> end-run]
  set arrive-task [[?ignore] -> arrive] ; in each call does 'arrive-task nobody' to create a truck
  set start-LM-task [[?reader] -> start-LM ?reader]
  set start-TM-task [[?reader] -> start-TM ?reader]
  set complete-service-task [[?reader] -> complete-service ?reader]

  ;set reset-stats-task [[?ignore] -> reset-stats]
end

to-report temp-in-radius [agentset r]
  report (agentset with [ distance myself <= r ])
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
        set reader-height_1_tx height_1_tx; _1 even frame
        set reader-height_1_rx height_1_rx
        set reader-height_2_tx height_2_tx ; _2 odd frame
        set reader-height_2_rx height_2_rx
        set even-frame? false
        ;set total-batches-of-reader 0; backlog of tags
        set queue-r (list )
        set inclination_angle_1_tx incli_1tx
        set inclination_angle_1_rx incli_1rx
        set inclination_angle_2_tx incli_2tx
        set inclination_angle_2_rx incli_2rx
        set reader-sensitivity (10 ^ (reader-sensitivity-g / 10) ) / 1000
        set interf-from-neighbors_TM-linear 0
      ]
    ] [ spawn-by-row ]
    write-readers-xy xy-file ] [
    read-readers-xy xy-file ]
  ;ask readers [ create-rris-with other readers in-radius (interf-rri-radius / 10) ] ;not correct from version 6.0.3
   ;ask readers [ create-rris-with (temp-in-radius other readers (interf-rri-radius / 10)) ]
  ;ask rris [ show (10 * link-length) ]
end

to spawn-by-row
  ; Get a range of coordinate values
  ifelse close? [
    set distance-var-x 1 set distance-var-y 1
    set readers-per-row 20 set readers-per-column 5
  ] [ ; else FAR
    set distance-var-x 12 set distance-var-y 22 ; [12 22]
    set readers-per-row 8 set readers-per-column 5
  ]
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
  let num-checkouts 0
  ; Use the number of readers to sublist the possible coordinates, and
  ; create a turtle at each of the coordinate combinations left.
  let max-positions length possible-coords
  ;if tpe = "read" [
  if max-positions > (num-readers + num-checkouts) [ set max-positions (num-readers + num-checkouts) ]
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
      set reader-power-tx transmitter-power ;0.8 ; 800 mW, or, 29 dBm
      set reader-frequency (865700000) ; center frequency of Ch1
      set reader-read-error 0
      set reader-outage-count 0
      set reader-height_1_tx height_1_tx; _1 even frame
      set reader-height_1_rx height_1_rx
      set reader-height_2_tx height_2_tx ; _2 odd frame
      set reader-height_2_rx height_2_rx
      set even-frame? false
      ;set total-batches-of-reader 0; backlog of tags
      set queue-r (list )
      set inclination_angle_1_tx incli_1tx
      set inclination_angle_1_rx incli_1rx
      set inclination_angle_2_tx incli_2tx
      set inclination_angle_2_rx incli_2rx
      set reader-sensitivity (10 ^ (reader-sensitivity-g / 10) ) / 1000
      set interf-from-neighbors_TM-linear 0
    ]
  ]
end

to write-readers-xy [ fxy ]
  if file-exists? fxy [ file-delete fxy ]
  file-open fxy
  ask readers
  [ file-write xcor
    file-write ycor ]
  file-close
end

to read-readers-xy [ fxy ]
  if file-exists? fxy [
    file-open fxy
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
        set reader-power-tx transmitter-power ;0.8 ; 800 mW, or, 29 dBm
        set reader-frequency (865700000) ; center frequency of Ch1
        set reader-read-error 0
        set reader-outage-count 0
        set reader-height_1_tx height_1_tx; _1 even frame
        set reader-height_1_rx height_1_rx
        set reader-height_2_tx height_2_tx ; _2 odd frame
        set reader-height_2_rx height_2_rx
        set even-frame? false
        ;set total-batches-of-reader 0; backlog of tags
        set queue-r (list )
        set inclination_angle_1_tx incli_1tx
        set inclination_angle_1_rx incli_1rx
        set inclination_angle_2_tx incli_2tx
        set inclination_angle_2_rx incli_2rx
        set reader-sensitivity (10 ^ (reader-sensitivity-g / 10) ) / 1000
        set interf-from-neighbors_TM-linear 0
      ]
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

to check-queue-length-and-write
  ;let len length queue
  ;if ticks >= (150 * num-of-queue-samples) and (num-of-queue-samples <= 100) [ ; this is for max num iterations of 15000
  ; a max of 100 samples taken 100 ticks by 100 ticks
  ;if ticks >= (100 * num-of-queue-samples) and (num-of-queue-samples <= 1000) [ ; this is for max num iterations of 10000
  if ticks >= (10 * num-of-queue-samples) and (num-of-queue-samples <= 1000) [ ; this is for max num iterations of 10000
    ; if each 500 then <= 50; it depends of the max-num-of-iterations this example are 25000
    ;;--
    ;let len length queue
    ;let pallets-in-queue ( sum map [i -> [total-pallets] of i ] queue ) ; total pallets in queue
    ;let tags-in-queue ( sum map [ i -> sum [ [ num-tags-in-pallet ] of pallets-in-truck ] of i ] queue ) ; total tags in queue
    ;set queue-length lput (list ticks len pallets-in-queue tags-in-queue ) queue-length
    ;set num-of-queue-samples (num-of-queue-samples + 1)
    ;;--
    if (file-exists? queue-file) and (num-of-queue-samples = 0) [ file-delete queue-file ]
    file-open queue-file
    file-write ticks
    foreach sort readers [ i ->
      file-write [length queue-r] of i
    ]
    file-write mean ([length queue-r] of readers)
    file-write sum ([length queue-r] of readers)
    file-print ""
    file-close
    set num-of-queue-samples (num-of-queue-samples + 1)
  ]
end

to write-queue-file [ f-queue ]
  if file-exists? f-queue [ file-delete f-queue ]
  file-open f-queue
  foreach range ( length queue-length ) [ ? ->
    file-write ( first item ?  queue-length ) ;the time ticks
    file-write ( item 1 item ?  queue-length ) ; the length of the queue
    file-write ( item 2 item ?  queue-length ) ; total pallets in queue
    file-write ( last item ? queue-length ) ; total tags in queue
    file-print ""
  ]
  file-close
end

to go
  ;ifelse ticks < max-run-time and ( sum [length queue-r] of readers <= (num-readers * 275)) [
  ifelse arrival-count < 4000 and length queue < 1000 [
    check-queue-length-and-write
    ;
    let next-event []
    let event-queue (list (list max-run-time end-run-task nobody))
    ;[[500000 (anonymous command from: procedure SETUP-TASKS: [end-run]) nobody]]
    let next-reader-to-complete next-reader-complete ; reader with min of next-combegipletion-time
    ;show next-reader-to-complete
    set event-queue (
      fput (list next-arrival-time arrive-task nobody) event-queue)
    ;show event-queue
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
    ;show event-queue
    set event-queue (sort-by [[?1 ?2] -> first ?1 < first ?2] event-queue)
    ;show event-queue
    set next-event (first event-queue)
    update-usage-stats (first next-event) ; the time of the next event;
    set next-event (but-first next-event) ; the procedure of the next event
    ;show next-event
    ;[(anonymous command from: procedure SETUP-TASKS: [arrive]) nobody]
    if (first next-event) != 0 [
      (run (first next-event) (last next-event)) ]
    ;update-plots
  ] [
    make-final-results ; to set names to final reporters
    ;write-queue-file queue-file
    stop
  ]
end

;; Selection of optimal frame size for a population of tags
;; See article Vales-Alonso 2014
;; "Analytical Computation of the mean number of Tag Id..."
to-report var-frame-size
  ;; using Letter Vales
  let tgs count my-tags with [ not inventoried? ]
  ;; using Chen2 algorithm (Web-Tzu CHEN, 2006)
  ;let tgs max (list 2 ((frame-size - 1) * (cs / (max (list 1 ce)))) )
  ;let tgs mean-tags-per-pallet - cs
  let k 0
  ifelse tgs < 2 [ set k 1 ][
        ifelse  tgs < 4 [ set k 2 ][ ;Q=1
          ifelse tgs < 7 [ set k 4 ][;Q=2
            ifelse tgs < 12 [ set k 8 ][;Q=3
              ifelse tgs < 23 [ set k 16 ][;Q=4
                ifelse tgs < 45 [ set k 32 ][;Q=5
                  ifelse tgs < 90 [ set k 64 ][;Q=6
                    ifelse tgs < 178 [ set k 128 ][;Q=7
                      ifelse tgs < 356 [ set k 256 ][;Q=8
                        ifelse tgs < 711 [ set k 512 ][;Q=9
                          ifelse tgs < 1421 [ set k 1024 ][
                            ifelse tgs < 2840 [ set k 2048 ][
                              ifelse tgs < 5679 [ set k 4096 ][
                                ifelse tgs < 11358 [ set k 8192 ][
                                  ifelse tgs < 22714 [ set k 2 ^ 14 ][
                                    set k 2 ^ 15 ]
      ]]]]]]]]]]]]]]
  ;print "k= " show (list count my-tags tgs k )
  ;print "n= " show (list ce frame-size ((frame-size - 1) * (cs / (max (list 1 ce))))  )
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
      print "too much time"
      ;print (word "tag= " [who] of self " , reader= " [who] of myself)
    ]
    ifelse ( reading-time >= max-TM ) [
      ask my-inventoried-tags with [ time-of-inventory > ( ticks + max-TM ) ] [ set inventoried? false ]
      set TM? false
      set reading-time max-TM
      print "max-TM = 4s reached"
      print (word "reader= " [who] of self  )
      set next-start-LM-time ticks + TM-to-LM-time
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
  if ((cs-t + cc-t + ce-t) > 0) [ set efficiency cs-t / (cs-t + cc-t + ce-t) ]
  set throughput cs-t / (TM-time + LM-time)
  report reading-time
end



to-report one-frame-inventory [ reading-time ]
  let frame-time 0 let s 0
  set ce 0 set cs 0 set cc 0
  let tagson my-tags with [ (inventoried? = false) ] ;show tagson
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
        ;print "1 from a group decod. with Success"
      ] [
        set tag-with-interf-decod-bad ( tag-with-interf-decod-bad + 1 )
        ;print "more than 1 and Error"
      ]

    ] ; foreach

  ] [
    foreach but-first range 4 [ ; son 3 frames vacíos
      foreach but-first range ( frame-size + 1 ) [ [ ?slot ] ->
        if ?slot = 1 [ set frame-time t1E set ce 1 ]
        if ?slot > 1 [ set frame-time (tE + frame-time) set ce (ce + 1) ]
        ;set TM? false ; commented because the only condition to stop is 'T'
     ]
      set TM? false ; commented because the only condition to stop is 'T'
    ] ; foreach 4
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
    ifelse [even-frame?] of myself [
      set alpha alpha_1_fw
      set phi azimuthal_angle_1_fw
    ] [
      set alpha alpha_2_fw
      set phi azimuthal_angle_2_fw
    ]
  ] ; ask
  ;;
  ;show (list alpha phi )
  ;set alpha 45 set phi 45
  ;show 3.136 * ( (tan alpha) * (sin ( 90 * (cos alpha) * (sin phi) ) ) ) ^ 2
  report 3.136 * ( (tan alpha) * (sin ( 90 * (cos alpha) * (sin phi) ) ) ) ^ 2

end

; this a tags context procedure
; used to compute tag-power-rx of all tagson with tag-outage? false
; Note: "the outages" I can read with two readers both sides of the gate because I do not know the number of tags in pallet
; or I could put a new variable in the tag to indicate that the tag has have already an outage then put the tag as inventaried to pass the reding but
; register how many tags has have outage.
to compute-power-rec-in-tag [ reading-time frame-time ]
  ;let freq [ reader-frequency ] of myself
  ;let D ( tag-x + ( [ pallet-distance ] of ( [ pallet-being-served ] of myself ) ) )
  let tag-gain tag-gain-fw
  let current-r-height 1.5 let D 2 let distance-to-r 2.5
  ifelse [ even-frame? ] of myself [
    set current-r-height ([ reader-height_1_tx ] of myself )
    set D D_1
    set distance-to-r  distance-to-reader_1_fw
  ] [
    set current-r-height ([ reader-height_2_tx ] of myself )
    set D D_2
    set distance-to-r  distance-to-reader_2_fw
  ]
  ;;------Two Rays Model (No Rician fading)
  let H ( sqrt( 1 - (4 * current-r-height * tag-y ) / ( (D ^ 2) + (( current-r-height + tag-y ) ) ^ 2) ) )
  let theta 2 * pi / (c / [ reader-frequency ] of myself ) * ( sqrt( ( (D ^ 2) + (( current-r-height + tag-y ) ) ^ 2 ) - sqrt( ( (D ^ 2) + (( current-r-height - tag-y ) ) ^ 2) ) ) )
  set q_e_fw  ( (H ^ 2) * ( sin (theta * radians-to-degrees) ) ^ 2 ) + (( 1 - H * cos (theta * radians-to-degrees) ) ^ 2) ;show (list H theta q_e)
  ;;-----Rician only-------
  ;set q_e_rcn_fw ( compute-rician-fading ( sqrt 3 ) ( 1 / sqrt 2 ) )
  ;;-----Rician only-------
  ; SHADOWING parameter
  set shadow_fw ( 10 ^ (-1 * ( random-normal 0 sigma ) / 10 ) )
  ;
  let this-tag self
  ask myself [ set reader-gain-tx-rx ( compute-reader-gain-tx this-tag ) ]
  ;
  ;;-----Rician only-------
  ;let tag-power-rx-linear ( ([ reader-power-tx * reader-gain-tx-rx * ((c / reader-frequency) ^ 2) ] of myself ) * tag-gain * polarz-mismatch * pow-tx-coefficient )  /
  ;    (( ( 4 * pi * distance-to-r ) ^ 2) * on-object-gain-penalty * path-blockages * fading-factor-fw ) * ( q_e_rcn_fw * shadow_fw ); loss-by-rician-fading-fw
  ;;-----Rician only-------
  ;;------Two Rays Model (No Rician fading) --------
  let tag-power-rx-linear ( ([ reader-power-tx * reader-gain-tx-rx * ((c / reader-frequency) ^ 2) ] of myself ) * tag-gain * polarz-mismatch * pow-tx-coefficient )  /
      (( ( 4 * pi * distance-to-r ) ^ 2) * on-object-gain-penalty * path-blockages * fading-factor-fw ) * ( q_e_fw * shadow_fw ); loss-by-rician-fading-fw
  ;let tag-power-rx-linear max (list tag-power-rx-linear_1 tag-power-rx-linear_2 )
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
      ;set tag-outage? true
      set time-of-inventory random-tween (ticks + reading-time) (ticks + reading-time + frame-time)
      set tags-with-two-outage ( tags-with-two-outage + 1) ; this is global var
    ]
  ] [ if tag-outage? [ set tag-outage? not tag-outage? ] ] ; or simply set tag-outage? false
end



; tag context
to-report compute-power-rec-in-reader
  ;let freq [ reader-frequency ] of myself
  ;let D ( tag-x + ( [ pallet-distance ] of ( [ pallet-being-served ] of myself ) ) )
  let tag-gain tag-gain-bw
  let current-r-height 1.5 let D 2 let distance-to-r 2.5 let distance-to-r_f 2.5
  ifelse [ even-frame? ] of myself [
    set current-r-height ([ reader-height_1_rx ] of myself )
    set D D_2
    set distance-to-r  distance-to-reader_1_bw
    set distance-to-r_f distance-to-reader_1_fw
  ] [
    set current-r-height ([ reader-height_2_rx ] of myself )
    set D D_1
    set distance-to-r  distance-to-reader_2_bw
    set distance-to-r_f distance-to-reader_2_fw
  ]
  ;; ----- Two Rays ----
  let H ( sqrt( 1 - (4 * current-r-height * tag-y ) / ( (D ^ 2) + (( current-r-height + tag-y ) ) ^ 2) ) )
  let theta 2 * pi / (c / [ reader-frequency ] of myself ) * ( sqrt( ( (D ^ 2) + (( current-r-height + tag-y ) ) ^ 2 ) - sqrt( ( (D ^ 2) + (( current-r-height - tag-y ) ) ^ 2) ) ) )
  set q_e_bw  ( (H ^ 2) * ( sin (theta * radians-to-degrees) ) ^ 2 ) + (( 1 - H * cos (theta * radians-to-degrees) ) ^ 2)
  ;;
  let shadow_bw ( 10 ^ (-1 * ( random-normal 0 (sigma ) ) / 10 ) )
  let reader-power-rx-linear ( ([ reader-power-tx * (reader-gain-tx-rx ^ 2) * (c / reader-frequency) ^ 4 ] of myself ) * (tag-gain ^ 2) * (polarz-mismatch ^ 2) * modulation-factor ) /
    ( ( 4 * pi ) ^ 4 * (distance-to-r_f ^ 2)* (distance-to-r ^ 2) * ( on-object-gain-penalty ^ 2) * (path-blockages ^ 2) * fading-factor-bw ) * ( ( q_e_fw * q_e_bw ) * shadow_fw * shadow_bw )
  ;; ------Two Rays --FIN--
  ;; ----Rician Fading
  ;let q_e_rcn_bw ( compute-rician-fading ( sqrt 3 ) ( 1 / sqrt 2 ) )
  ;let shadow_bw ( 10 ^ (-1 * ( random-normal 0 (sigma ) ) / 10 ) )
  ;let reader-power-rx-linear ( ([ reader-power-tx * (reader-gain-tx-rx ^ 2) * (c / reader-frequency) ^ 4 ] of myself ) * (tag-gain ^ 2) * (polarz-mismatch ^ 2) * modulation-factor ) /
  ;  ( ( 4 * pi ) ^ 4 * (distance-to-r_f ^ 2)* (distance-to-r ^ 2) * ( on-object-gain-penalty ^ 2) * (path-blockages ^ 2) * fading-factor-bw ) * ( ( q_e_rcn_fw * q_e_rcn_bw ) * shadow_fw * shadow_bw ) ; loss-by-rician-fading-fw * loss-by-rician-fading-bw
  ;; ----Rician Fading--FIN
  ;show (list shadow_bw reader-power-rx-linear (10 * log (1000 * reader-power-rx-linear) 10) )
  ;set reader-power-rx-linear ((10 ^ (-0.6)) / 1000 )
  ask myself [
    set reader-power-rx ifelse-value (reader-power-rx-linear > 0) [( 10 * log (1000 * reader-power-rx-linear) 10 )][-1000]
  ]

  report reader-power-rx-linear
end

; reader context
to-report compute-SNIR-prob-error [ tags-powers reading-time frame-time ]
  if not empty? ( filter [ p -> last p < reader-sensitivity ] tags-powers ) [ set reader-outage-count reader-outage-count + 1 ]
  let tags-powers-below ( filter [ p -> last p < reader-sensitivity ] tags-powers )
  set tags-powers ( filter [ p -> last p >= reader-sensitivity ] tags-powers )
  let tag-of-max-power nobody
  ;let tags-powers-interference (list ) let powers-interference (list )
  ;let tag-of-max-power nobody
  ;print "1 t" show tags-powers
  ifelse not empty? tags-powers [
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


   ;    let CIR ifelse-value (interf-from-neighbors_TM-linear > 0) [ max-power / (interf-from-neighbors_TM-linear / ACPR_linear)] [max-power]
    let tags-powers-interference (list ) let powers-interference (list )
    if length tags-powers > 1 [
      set tags-powers-interference but-first tags-powers
      set powers-interference map [ p -> last p ] tags-powers-interference
;      set CIR ifelse-value (sum powers-interference > 0) [( max-power / ( sum powers-interference + (interf-from-neighbors_TM-linear / ACPR_linear) ) ) ] [CIR]
    ]
;    set SNIR ifelse-value (max-power > 0 ) [ ( 1 / ( ( 1 / SNR_linear) + (1 / CIR ) ) ) ] [ 0 ]
    ;show tag-of-max-power
    ;show (word "[maxPow,mPdBm]= " (list max-power (10 * log (1000 * max-power) 10)) " , [SNR_lin,SNR_dB]= " (list SNR_linear (10 * log (1 * SNR_linear) 10)) " , CIR= " CIR ", [SNIR, SNIR_dB]= " (list SNIR (10 * log SNIR 10)) )

    let I_linear ( (sum powers-interference) + (interf-from-neighbors_TM-linear / ACPR_linear))
    set SNIR (max-power / (N_linear + I_linear))
    ;show (word "mpow= " max-power " , N_lin= " N_linear " , I_lin= " I_linear " , SNIR= " (list SNIR (10 * log (1 * SNR_linear) 10)) )
    let M 8
    let BER ifelse-value SNIR > 0 [1 / (2 * M * SNIR)][1]
    ;let BER (1 + rician-factor) / ( 2 + 2 * rician-factor + SNIR ) * exp (-3 * SNIR / ( 2 + rician-factor + SNIR ) ) ;print "BER=" show BER
    let prob-error ( 1 - ( 1 - BER) ^ 40)
    ;show (list BER prob-error)
    ifelse prob-error <= random-float 1  [ ;and  length tags-powers = 1
      ask tag-of-max-power [
          ;show (word "inventoried" tag-of-max-power )
          set inventoried? true
          ;set tag-outage? false
          ;set time-of-inventory random-tween (ticks + reading-time) (ticks + reading-time + frame-time)
          set time-of-inventory (ticks + reading-time + frame-time)
      ]
    ] [ set reader-read-error (reader-read-error + 1) ]

  ] [
    ; the orientation in the backguard direction makes the reading not possible bacause of the tag gain
     ;set inventoried? true
     ;set time-of-inventory random-tween (ticks + reading-time) (ticks + reading-time + frame-time)
    if not empty? tags-powers-below [
      ;show (word "tags-powers-below = " tags-powers-below )
      foreach tags-powers-below [ tp? ->
        ifelse (last tp?) = 0 [
          ask first tp? [
            set tag-outage? true
            set inventoried? true
            set time-of-inventory random-tween (ticks + reading-time) (ticks + reading-time + frame-time)
            set outage-count-of-this-tag  max-num-of-outages
          ]
        ] [
         ask first tp? [
          set tag-outage? true
          ;set inventoried? true
          ifelse outage-count-of-this-tag < max-num-of-outages [
             set outage-count-of-this-tag (outage-count-of-this-tag + 1)
             ;show outage-count-of-this-tag
             set tags-with-one-outage ( tags-with-one-outage + 1) ; this is global var
         ] [
            ;show outage-count-of-this-tag ;print " invent with outage"
            set inventoried? true
            ;set tag-outage? true
            set time-of-inventory random-tween (ticks + reading-time) (ticks + reading-time + frame-time)
            set tags-with-two-outage ( tags-with-two-outage + 1) ; this is global var
           ]
         ]
        ]
      ]
    ]


  ]
  report tag-of-max-power
end

; this is the function to compute a realization of the rician pdf
; parameter s: s^2 is the LOS energy received
; parameter sgm: 2*sgm^2 is the NLOS energy received
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


;; Generates the random number of pallets per truck
;; and tags per pallet
to-report generate-number [ s ]
  ;let lg exp random-normal mean-tags-per-pallet 1.29
  report ifelse-value (s = "tags") [
    ; max (list 1 random-poisson mean-tags-per-pallet)
    ;max (list 1 random-poisson exp random-normal 2.201 1.29 )  ; mean-tags-per-pallet = 2.32 in UK supers

    ifelse-value PLN? [
      ;min (list 250 max (list 1 random-poisson exp random-normal 2.32 1.29 ) )
      max (list 1 random-poisson exp random-normal 2.32 1.31 )
    ][ 24 ]

    ;random-poisson lg
    ;random-tween-uniform 100 1000
    ;20
    ; mean-tags-per-pallet must be 15 for a supermarket
    ;round max (list 5 random-exponential mean-tags-per-pallet)
  ] [
    ;max (list 1 random-poisson mean-pallets-per-truck)
    ifelse-value cart-traffic? [1][max (list 1 random-poisson mean-pallets-per-truck)]
  ]
end


;; Creates a new truck agent, adds it to the queue, and attempts to start
;; service. We create a truck with pallets and the tags on each pallet.
to arrive
  let current-truck nobody
  ;let one-of-readers nobody ;(one-of readers)
  create-trucks 1 [
    set color brown
    set current-truck self
    ;;
    let one-of-readers nobody
    ifelse multiple-input-queues? [
      let reader-min-queue ifelse-value random-queue-assignation? [ one-of readers ][ min-one-of readers [length queue-r ] ]
      set one-of-readers reader-min-queue
      ask reader-min-queue [
        set queue-r (lput myself queue-r)
      ]
    ][
      set queue (lput self queue)
    ]
    ;;
    set time-entered-queue ticks
    set total-pallets generate-number "pallets"
    set shape "truck"
    set size 2
    set hidden? true
    ;
    set total-offered-load-of-pallets ( total-offered-load-of-pallets + total-pallets )
  ]
  let pallets-of-this-truck []
  let base-point (portal-width / 2)
  create-pallets [ total-pallets ] of current-truck  [
    set num-tags-in-pallet generate-number "tags"
    ;if num-tags-in-pallet > 200 [print num-tags-in-pallet ]
    set pallets-of-this-truck (lput self pallets-of-this-truck)
    set pallet-distance base-point + (random-tween -0.15 0.15 )
    ;set pallet-distance 2
    set hidden? true
	  set still-not-inventoried true
    ;
    set total-offered-load-of-tags ( total-offered-load-of-tags + num-tags-in-pallet )
    set reading-pallet-time 0
  ]
  ask current-truck [
    set pallets-in-truck (turtle-set pallets-of-this-truck)
    set total-pallets count pallets-in-truck
  ]
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
  ;ask one-of-readers [ set total-batches-of-reader (total-batches-of-reader + (sum  pallets-of-this-truck) ) ]
  set arrival-count (arrival-count + 1)
  schedule-arrival
  begin-service
end

to setup-tags-distances
  ifelse dislocated? [ ; See labels in Fig. of block
    set distance-to-reader_1_fw sqrt ( (([ reader-height_1_tx ] of myself - tag-y ) ^ 2) + (D_1 ^ 2)  )
    set distance-to-reader_1_bw sqrt ( (([ reader-height_1_rx ] of myself - tag-y ) ^ 2) + (D_2 ^ 2)  )
    set distance-to-reader_2_fw sqrt ( (([ reader-height_2_tx ] of myself - tag-y ) ^ 2) + (D_2 ^ 2)  )
    set distance-to-reader_2_bw sqrt ( (([ reader-height_2_rx ] of myself - tag-y ) ^ 2) + (D_1 ^ 2)  )
  ] [
    set distance-to-reader_1_fw sqrt ( (([ reader-height_1_tx ] of myself - tag-y ) ^ 2) + (D_1 ^ 2)  )
    set distance-to-reader_1_bw sqrt ( (([ reader-height_1_rx ] of myself - tag-y ) ^ 2) + (D_1 ^ 2)  )
    set distance-to-reader_2_fw sqrt ( (([ reader-height_2_tx ] of myself - tag-y ) ^ 2) + (D_2 ^ 2)  )
    set distance-to-reader_2_bw sqrt ( (([ reader-height_2_rx ] of myself - tag-y ) ^ 2) + (D_2 ^ 2)  )
  ]
  ;show (list distance-to-reader_1_fw distance-to-reader_1_bw distance-to-reader_2_fw distance-to-reader_2_bw)
end


to setup-tags-angles [ ?pallet ]
  ifelse dislocated? [ ; See labels in Fig. of block
    set azimuthal_angle_1_fw (90 - acos (( tag-x + [ pallet-distance ] of ?pallet ) / distance-to-reader_1_fw ) )
    set azimuthal_angle_1_bw (90 - acos (( tag-x + ( portal-width - [ pallet-distance ] of ?pallet ) ) / distance-to-reader_1_bw ) )
    set alpha_1_fw ([inclination_angle_1_tx] of myself + asin ( ([ reader-height_1_tx ] of myself - tag-y ) / distance-to-reader_1_fw ) )
    set alpha_1_bw ([inclination_angle_1_rx] of myself + asin ( ([ reader-height_1_rx ] of myself - tag-y ) / distance-to-reader_1_bw ) )
    if alpha_1_fw = 90 or alpha_1_fw = 270 [set alpha_1_fw (alpha_1_fw + 1e-6)]
    if alpha_1_bw = 90 or alpha_1_bw = 270 [set alpha_1_bw (alpha_1_bw + 1e-6)]
    ;
    set azimuthal_angle_2_bw (90 - acos (( tag-x + [ pallet-distance ] of ?pallet ) / distance-to-reader_2_bw ) )
    set azimuthal_angle_2_fw (90 - acos (( tag-x + ( portal-width - [ pallet-distance ] of ?pallet ) ) / distance-to-reader_2_fw ) )
    set alpha_2_bw ([inclination_angle_2_rx] of myself + asin ( ([ reader-height_2_rx ] of myself - tag-y ) / distance-to-reader_2_bw ) )
    set alpha_2_fw ([inclination_angle_2_tx] of myself + asin ( ([ reader-height_2_tx ] of myself - tag-y ) / distance-to-reader_2_fw ) )
    if alpha_2_fw = 90 or alpha_2_fw = 270 [set alpha_1_fw (alpha_1_fw + 1e-6)]
    if alpha_2_bw = 90 or alpha_2_bw = 270 [set alpha_1_bw (alpha_1_bw + 1e-6)]
  ] [
    set azimuthal_angle_1_fw (90 - acos (( tag-x + [ pallet-distance ] of ?pallet ) / distance-to-reader_1_fw ) )
    set azimuthal_angle_1_bw azimuthal_angle_1_fw
    set alpha_1_fw ([inclination_angle_1_tx] of myself + asin ( ([ reader-height_1_tx ] of myself - tag-y ) / distance-to-reader_1_fw ) )
    set alpha_1_bw alpha_1_fw
    if alpha_1_fw = 90 or alpha_1_fw = 270 [set alpha_1_fw (alpha_1_fw + 1e-6)]
    if alpha_1_bw = 90 or alpha_1_bw = 270 [set alpha_1_bw (alpha_1_bw + 1e-6)]
    ;
    set azimuthal_angle_2_fw (90 - acos (( tag-x + ( portal-width - [ pallet-distance ] of ?pallet ) ) / distance-to-reader_2_fw ) )
    set azimuthal_angle_2_bw azimuthal_angle_2_fw
    set alpha_2_fw ([inclination_angle_2_tx] of myself + asin ( ([ reader-height_2_tx ] of myself - tag-y ) / distance-to-reader_2_fw ) )
    set alpha_2_bw alpha_2_fw
    if alpha_2_fw = 90 or alpha_2_fw = 270 [set alpha_1_fw (alpha_1_fw + 1e-6)]
    if alpha_2_bw = 90 or alpha_2_bw = 270 [set alpha_1_bw (alpha_1_bw + 1e-6)]
  ]
end

to setup-tags [ ?pallet ?truck]
  let list-of-tags []
  hatch-tags ([num-tags-in-pallet] of ?pallet) [
    set list-of-tags (lput self list-of-tags)
    set inventoried? false
    set time-entered-queue [ time-entered-queue ] of ?truck
    set hidden? true
    ;set tag-x   0
    ;set tag-x (random-tween -0.20 0.20 )
    ifelse cart-traffic? [
      ifelse dispersion-var > 0 [
;        set tag-x (random-tween (-0.29 * dispersion-var / 100) (0.29 * dispersion-var / 100) )
;        ;set tag-y ( random-tween 0.42 0.9525 )
;        let chart-height-half ((0.9525 - 0.42) / 2)
;        set tag-y (random-tween (-1 * (chart-height-half) * dispersion-var / 100) ((chart-height-half) * dispersion-var / 100) ) + (chart-height-half + 0.42)
;        set tag-z ( random-tween (-0.43 * dispersion-var / 100) (0.43 * dispersion-var / 100) )
        set tag-x (random-tween (-0.5 * dispersion-var / 100) (0.5 * dispersion-var / 100) )
        ;set tag-y ( random-tween 0.42 0.9525 )
        let chart-height-half ((1.9 - 0.20) / 2)
        set tag-y (random-tween (-1 * (chart-height-half) * dispersion-var / 100) ((chart-height-half) * dispersion-var / 100) ) + (chart-height-half + 0.42)
        set tag-z ( random-tween (-0.85 * dispersion-var / 100) (0.85 * dispersion-var / 100) )
      ][
        set tag-x 0
        set tag-y ((1.9525 - 0.42) / 2)
        set tag-z 0
      ]
    ] [
      set tag-x (random-tween -0.4 0.4 )
      set tag-y ( random-tween 0.144 1.85 )
      set tag-z ( random-tween -0.6 0.6 )
    ]
    set D_1 sqrt ( ( tag-x + [ pallet-distance ] of ?pallet ) ^ 2 + ( tag-z ^ 2 ) )
    set D_2 sqrt ( ( tag-x + ( portal-width - [ pallet-distance ] of ?pallet ) ) ^ 2 + (tag-z ^ 2 ) )
    setup-tags-distances
    setup-tags-angles (?pallet)
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
  ]
  ask ?pallet [ set tags-in-pallet (turtle-set list-of-tags) ]
end


;; If there are trucks in the queue, and at least one reader is idle, starts
;; service on the first truck in the queue, using a randomly selected
;; idle server.
;; -->Besides, for each pallet in the truck, generate a complete-service event with
;; a time computed making the inventory of that particular pallet
;; But first we have to plan an event time to start LM
to begin-service
  ifelse multiple-input-queues? [
    let available-readers (readers with [(not is-agent? truck-being-served) and (length queue-r) > 0])
  ;if (not empty? queue and any? available-readers) [ ; OJO
  if (any? available-readers) [ ; OJO
    ;let next-truck (first queue)
    ;
    let next-reader one-of available-readers
    let next-truck (first [ queue-r ] of next-reader)
    ask next-reader [ set queue-r (but-first queue-r) ]
    ;;
    ask next-truck [
      move-to next-reader
      set hidden? false ]
    ask next-reader [
      set truck-being-served next-truck ; task variable owned by server
      set pallet-being-served one-of [ pallets-in-truck ] of next-truck
      ;ask pallet-being-served [ set pallet-distance (random-tween 1 3 ) ]
      set color red
      setup-tags ( pallet-being-served )  ( truck-being-served )
      set my-tags [ tags-in-pallet ] of pallet-being-served
      ask my-tags [ set time-entered-service ticks ] ;<<--we should measure some parameters
      set total-time-in-queue  ; OJO
        (total-time-in-queue + (one-of [time-entered-service - time-entered-queue] of my-tags))
      set total-queue-throughput (total-queue-throughput + (count my-tags))
      set next-start-LM-time ticks
    ]
  ]
  ][ ;ifelse multiple-input-queues?
  ;
  let available-readers (readers with [not is-agent? truck-being-served])
  if (not empty? queue and any? available-readers) [ ; OJO
    let next-truck (first queue)
    let next-reader one-of available-readers
    set queue (but-first queue)
    ;;
    ask next-truck [
      move-to next-reader
      set hidden? false ]
    ask next-reader [
      set truck-being-served next-truck ; task variable owned by server
      set pallet-being-served one-of [ pallets-in-truck ] of next-truck
      ;ask pallet-being-served [ set pallet-distance (random-tween 1 3 ) ]
      set color red
      setup-tags ( pallet-being-served )  ( truck-being-served )
      set my-tags [ tags-in-pallet ] of pallet-being-served
      ask my-tags [ set time-entered-service ticks ] ;<<--we should measure some parameters
      set total-time-in-queue  ; OJO
        (total-time-in-queue + (one-of [time-entered-service - time-entered-queue] of my-tags))
      set total-queue-throughput (total-queue-throughput + (count my-tags))
      set next-start-LM-time ticks
      ;;;;
      ;set total-offered-load-of-tags ( total-offered-load-of-tags + ( count my-tags ) )
      ;set total-offered-load-of-pallets ( total-offered-load-of-pallets + 1 )
    ]
  ]
  ] ;ifelse multiple-input-queues?

  ;; there could be other readers prepared to receive a new pallet
  ;; and generate event time to start LM
  let ready-readers ( readers with [ is-agent? truck-being-served and (not is-agent? pallet-being-served) ] )
  if any? ready-readers [
    ;let next-ready-reader one-of ready-readers ;
    ask one-of ready-readers [
      ; still-not inventoried should probably take it out from code <-- Ojo
      let not-inventoried-pallets-in-truck ([pallets-in-truck with [still-not-inventoried = true] ] of truck-being-served)
      if any? not-inventoried-pallets-in-truck [ ;print "Estoy aqui"
        set pallet-being-served  one-of not-inventoried-pallets-in-truck
        ;ask pallet-being-served [ set pallet-distance (random-tween 1 3 ) ]
        ;set color red
        setup-tags ( pallet-being-served )  ( truck-being-served )
        set my-tags ([ tags-in-pallet ] of pallet-being-served)
        ask my-tags [ set time-entered-service ticks ]
        set total-time-in-queue  ; OJO
          (total-time-in-queue + (one-of [time-entered-service - time-entered-queue] of my-tags))
        set total-queue-throughput (total-queue-throughput + (count my-tags))
        set next-start-LM-time ticks + TM-to-LM-time
        ; if more than one all going to start at the same time => random (0,5ms) in 11 steps
      ] ; else [ all pallets are read and the reader must be free for more trucks
    ] ;ask
  ]
end


to-report random11steps [ minLM ]
  let step random 11 + 1
  let step-value (minLM / 11)
  report step * step-value
end


to-report compute-reader-gain-interf [ other-reader height-diff distance-to-r ]
  ;set distance-to-r (distance-to-r * 10)
  ;show distance-to-r
  let phi asin ( abs ( (ycor - min-pycor) - ([ycor] of other-reader - min-pycor) ) / (distance-to-r / distance-multiplicative) )
  set phi 90 - phi

  ;let alpha ifelse-value even-frame? [inclination_angle_1_tx + asin ( height-diff / distance-to-r ) ][ inclination_angle_2_tx + asin ( height-diff / distance-to-r ) ]
  let alpha ifelse-value even-frame? [inclination_angle_1_tx + asin ( height-diff / distance-to-r )  ][ inclination_angle_2_tx + asin ( height-diff / distance-to-r ) ]
  ;show (word "[self,other-reader]= " (list self other-reader) " , phi= " phi " , alpha = " alpha)
  if alpha = 90 or alpha = 270 [set alpha (alpha + 1e-6)]
  report 3.136 * ( (tan alpha) * (sin ( 90 * (cos alpha) * (sin phi) ) ) ) ^ 2
end

;; compute the interf power received from other TM? readers
;; context of the other readers
to-report compute-interf-power
  ;let x-pos xcor let y-pos ycor
  let current-r-height 1.5
  ifelse even-frame?  [
    set current-r-height ( reader-height_1_tx )
  ] [
    set current-r-height ( reader-height_2_tx )
  ]

  let D (distance myself) ; distance to myself
  set D (D * distance-multiplicative)
  let height-of-myself (ifelse-value [even-frame?] of myself [ [reader-height_1_tx] of myself][ [reader-height_2_tx] of myself ])
  let distance-to-r sqrt ( ( current-r-height - height-of-myself ) ^ 2 + (D ^ 2) )
  let H ( sqrt( 1 - (4 * current-r-height * height-of-myself ) / ( (D ^ 2) + (( current-r-height + height-of-myself ) ) ^ 2) ) )
  let theta 2 * pi / (c / reader-frequency ) * ( sqrt((D ^ 2) + ( current-r-height + height-of-myself  ) ^ 2 ) - sqrt( ( (D ^ 2) + ( current-r-height - height-of-myself ) ^ 2) ) )
  let q_e  ( (H ^ 2) * ( sin (theta * radians-to-degrees) ) ^ 2 ) + (( 1 - H * cos (theta * radians-to-degrees) ) ^ 2)
  ;show (word "distance-to-r= " distance-to-r " , H= " H " , theta= " theta " , q_e= " q_e )
  ; SHADOWING parameter
  let shadow ( 10 ^ (-1 * ( random-normal 0 sigma ) / 10 ) )
  ;

  let reader-gain-tx-interf ( compute-reader-gain-interf myself (abs ( current-r-height - height-of-myself ))  distance-to-r )
  let this-reader self
  let reader-gain-rx-interf reader-gain-tx-interf
  ask myself [ set reader-gain-rx-interf ( compute-reader-gain-interf this-reader  (abs ( current-r-height - height-of-myself ))  distance-to-r ) ]
  ;
  ;;-----Rician only-------
  ;let tag-power-rx-linear ( ([ reader-power-tx * reader-gain-tx-rx * ((c / reader-frequency) ^ 2) ] of myself ) * tag-gain * polarz-mismatch * pow-tx-coefficient )  /
  ;    (( ( 4 * pi * distance-to-r ) ^ 2) * on-object-gain-penalty * path-blockages * fading-factor-fw ) * ( q_e_rcn_fw * shadow_fw ); loss-by-rician-fading-fw
  ;;-----Rician only-------
  ;;------Two Rays Model (No Rician fading) --------
  let r2r-power-rx-linear (  reader-power-tx * (reader-gain-tx-interf * reader-gain-rx-interf) * ((c / reader-frequency) ^ 2)   )  /
      (( ( 4 * pi * distance-to-r ) ^ 2) ) * ( q_e * shadow ) ;/ ACPR_linear ;
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
  report r2r-power-rx-linear
end


;; The reader start listening the channel
;; if another reader uses the channel, then it has to wait a random time [.05s 0.1s]
;; and try again.
to start-LM [ ?reader ]
  ask ?reader [
    if collide? [set collide? false ]
    ask my-rris [ die ]
    let TM-neighbors other readers with [TM?]
    ifelse not any? TM-neighbors [
      set next-start-TM-time (next-start-LM-time + min-LM)
      ;set contention? false
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
        set next-start-TM-time (next-start-LM-time + min-LM)
        set LM? true
      ] ; ifelse (not empty? interf-power-list)

    ] ; ifelse not any? TM-neighbors
  ] ;ask ?reader
end



to start-TM [ ?reader ]
  ask ?reader [
    set TM? true   set LM? false
    ;ask my-rris with [[color = white] of other-end ][die]
    if contention? [ set contention? false ]
    ;ask my-rris [ die ]
    let interf-threshold-linear (10 ^ (interf-threshold / 10) ) / 1000
    let TM-neighbors other readers with [TM?]
    ifelse not any? TM-neighbors [
      ; Reader can transmit
      ;print (word "tx_reader_no_neigh_TM " ?reader)
      let k my-FSA
      ask pallet-being-served [ set reading-pallet-time (reading-pallet-time + k) ]
      ;show (list k count my-tags with [inventoried? and outage-count-of-this-tag < 2] count my-tags ); <<------OJO "Not Remove"
      ;set next-completion-time (ticks + k ) ;my-FSA)
      set next-completion-time ( ticks + k + empty-frames-TM )
      set LM-time (LM-time + (ticks - next-start-LM-time))
    ] [
      ; Collision or Contention but depending on times and interf signal level
      ; let start with interf signal levels:
      let interf-power-list (list )
      let readers-over-threshold (turtle-set )
      ask TM-neighbors [
        set interf-power-list lput (compute-interf-power ) interf-power-list
        if (last interf-power-list > interf-threshold-linear) [ set readers-over-threshold (turtle-set readers-over-threshold self) ]
      ];ask
      set interf-from-neighbors_TM-linear (sum interf-power-list)

      ifelse any? readers-over-threshold [
        let readers-with-RRI readers-over-threshold with [
           next-start-TM-time < ([next-start-TM-time] of myself) and
               ;([next-start-TM-time] of myself) - next-start-TM-time <= (distance myself) * 10 * tau ]
               ([next-start-TM-time] of myself) - next-start-TM-time <= (distance myself) * distance-multiplicative * tau ]
        ifelse any? readers-with-RRI [
          print "collision"
          manage-collision readers-with-RRI ] [ manage-contention ]
      ] [
        ; Not any reader over TM threshold then reader can transmit
        ;print (word "tx_reader_no_neigh_dB " ?reader)
        let k my-FSA
        ask pallet-being-served [ set reading-pallet-time (reading-pallet-time + k) ]
        ;show (list k count my-tags with [inventoried? and outage-count-of-this-tag < 2] count my-tags ); <<------OJO "Not Remove"
        ;set next-completion-time (ticks + k ) ;my-FSA)
        set next-completion-time ( ticks + k + empty-frames-TM )
        set LM-time (LM-time + (ticks - next-start-LM-time))
      ]

    ]


  ]

end

;; other readers has started TM before and we collide
;; must re-schedule the time to start TM and increment collisions
to manage-collision [ rdr-with-rri ]
  set next-completion-time 0
  set TM? false set LM? false ;set collide? true
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

;;
;; Updates time-in-system statistics, removes current pallet or truck agent, returns
;; the server to the idle state, and attempts to start service on another
;; pallet or truck.
to complete-service [ ?reader ]
  ask ?reader [
    ifelse not collide? [
      let tagson my-tags with [ not inventoried? ]
      if not any? tagson [
        set total-time-in-system (total-time-in-system + ticks
          - one-of [time-entered-queue] of my-tags) ; [time-entered-queue] of one-of my-tags
        ;set total-system-throughput (total-system-throughput + count my-tags) ; this is from before the including outages of tags
        set total-outages ( total-outages + count my-tags with [ (outage-count-of-this-tag >= max-num-of-outages) ] )
        let num-tags-singulated ( count ( my-tags with [ inventoried? and (outage-count-of-this-tag < max-num-of-outages) ] ) )
        set total-system-throughput (total-system-throughput + num-tags-singulated )
        ;set total-pallets-thoughput (total-pallets-thoughput + 1)
        set total-pallets-thoughput ( total-pallets-thoughput + (num-tags-singulated / (count my-tags)) )
        ;;--
        set total-reading-time (total-reading-time + ([reading-pallet-time] of pallet-being-served) )
        set total-reading-time-square (total-reading-time-square + ([reading-pallet-time] of pallet-being-served) ^ 2 )
        ifelse (num-tags-singulated = (count my-tags)) [ ; is to count the reading time of pallets but only the ones completely read
          ;set total-reading-time (total-reading-time + ([reading-pallet-time] of pallet-being-served) )
          set num-pallets-completely-read (num-pallets-completely-read + 1)
        ] [ ; count the tags not inventoried even with 100 tries
          ; print "pallet is not read completely" ; <<<--------------------------------------------------OJO
          set num-pallets-not-completely-read (num-pallets-not-completely-read + 1)
          set total-tags-not-inventoried ( total-tags-not-inventoried + (mean-tags-per-pallet - num-tags-singulated) )
          set mean-tags-not-inventoried (total-tags-not-inventoried / num-pallets-not-completely-read)
        ]
        set total-pallets-th (num-pallets-completely-read + num-pallets-not-completely-read)
        set mean-reading-time-of-pallets (total-reading-time / total-pallets-th)
        set variance-reading-time-of-pallets  ifelse-value total-pallets-th > 1 [
          ( total-reading-time-square - ((total-reading-time) ^ 2 / total-pallets-th) ) / (total-pallets-th - 1 )
        ] [ 0 ]
        set read-failures-probability (num-pallets-not-completely-read / total-pallets-th)
        set total-mytags (total-mytags + count my-tags)
        set mean-of-tags (total-mytags / total-pallets-th)

        set tags-with-one-outage ( count my-tags with [outage-count-of-this-tag = 1] + tags-with-one-outage)
        set tags-with-two-outage ( count my-tags with [outage-count-of-this-tag = 2] + tags-with-two-outage)
        ;;--
        ask my-tags [ die ]
        set my-tags nobody
        ask pallet-being-served [ die ]
        set pallet-being-served nobody
        ask my-rris [ set color 5 ] ;default color of link
        ask truck-being-served [
          ifelse not any? pallets-in-truck [ ; with [ still-not-inventoried = true ] NOT NECCESSARY B THEY DIE
            ask myself [
              set truck-being-served nobody
              set color green
              set next-completion-time 0
            ]
            ask self [ die ]
          ] [
            ; re-schedule the start-LM-time
            ask myself [ set next-start-LM-time (ticks + TM-to-LM-time) ]
            ; set a new pallet in the reader is made in begin service
          ]
        ] ; ask truck-
      ]
    ] [
        ; have to repeat the inventory of actual pallet
        manage-collision nobody ; with myself
      ]
    set TM? false
    ;ask my-rris with [ [ not TM? ] of other-end ] [ set color gray ]
    ask my-rris [ die ]
  ]
  begin-service ; Note that begin-service is made even when there are collision or the pallet is not finished
end

;; Reports the busy reader with the earliest start-LM-time.
;; considering the state of the reader (contention?, LM?)
to-report next-reader-LM
  report (min-one-of
      (readers with [ is-agent? pallet-being-served and ( not LM? ) and (next-start-LM-time >= ticks) ])
    [ next-start-LM-time ])
end

;; Reports the busy reader with the earliest start-TM-time.
to-report next-reader-TM
  report (min-one-of
    (readers with [ is-agent? pallet-being-served and (LM? or contention? )
      and (next-start-TM-time >= ticks) ]) [ next-start-TM-time ])
end

;; Reports the busy reader with the earliest scheduled completion.
to-report next-reader-complete
  report (min-one-of
    (readers with [is-agent? pallet-being-served and TM?
      and (next-completion-time >= ticks) ]) [next-completion-time])
end

;; Updates the usage/utilization statistics and advances the clock to the
;; specified event time.
to update-usage-stats [event-time] ;event-time is the next event time <<--OJO with NAMES
  let delta-time (event-time - ticks)
  let busy-readers (readers with [is-agent? truck-being-served])
  ;let in-queue (length queue)
  let in-queue ifelse-value multiple-input-queues? [mean [length queue-r] of readers][length queue] ;;
  let in-process (count busy-readers)
  let in-system (in-queue + in-process)
  set total-truck-queue-time
    (total-truck-queue-time + delta-time * in-queue)
  set total-truck-service-time
    (total-truck-service-time + delta-time * in-process)
  if event-time > ticks [
    tick-advance (event-time - ticks) ]
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
  set total-offered-load-of-tags-sg ( total-offered-load-of-tags / (ticks - stats-start-time))
  set total-offered-load-of-pallets-sg ( total-offered-load-of-pallets / (ticks - stats-start-time))
  ;
  set total-system-throughput-sg (total-system-throughput / (ticks - stats-start-time))
  set total-pallets-thoughput-sg ( total-pallets-thoughput / (ticks - stats-start-time))
  set total-tags-inventoried  total-system-throughput
  set reader-utilization-percent (100 * total-truck-service-time / (ticks - stats-start-time) / count readers)
  set avg-queue-length ( total-truck-queue-time / (ticks - stats-start-time) )
  set total-num-arrivals arrival-count
  set avg-time-queue-of-tags ( total-time-in-queue / total-queue-throughput )
  set avg-time-in-system-of-tags ( total-time-in-system / total-system-throughput )
  set total-simulation-time-sg ticks
  set mean-num-collisions-sg ( mean [ num-of-collisions ] of readers / (ticks - stats-start-time) )
  set total-num-of-collisions ( sum [ num-of-collisions ] of readers )
  ;; Network
  set mean-num-links ( mean  [ count my-rris] of readers )
  set final-length-queue ifelse-value multiple-input-queues? [
    [length queue-r] of readers
  ][length queue]
  set average-S1 (sum [TM-time] of readers) / ticks / (count readers)
  set average-S2 ((sum [cs-t] of readers) * 0.00258 + (sum [cs-t] of readers) * 0.00049 + (sum [ce-t] of readers) * 0.00046) / ticks / count readers
  set average-efficiency (mean [efficiency] of readers)
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
1.0
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
1300
0.0
10
1
m
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
8
250
131
283
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
5
335
177
368
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
74
381
137
414
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
7
430
72
475
tot cs /s
mean [cs-t] of readers / ticks
1
1
11

MONITOR
73
430
138
475
tot ce /s
mean [ce-t] of readers / ticks
1
1
11

MONITOR
142
429
207
474
tot cc /s
mean [cc-t] of readers / ticks
1
1
11

MONITOR
7
486
81
531
Efficiency %
precision ((mean [efficiency] of readers) * 100) 4
17
1
11

MONITOR
91
486
209
531
Thorughput tgs/ms
precision ((sum [throughput] of readers) * 0.001) 4
17
1
11

MONITOR
141
377
205
422
#frames
mean [ frame ] of readers
1
1
11

MONITOR
8
539
112
584
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
2
0.1218
0.0001
1
per tick
HORIZONTAL

SLIDER
1115
10
1336
43
max-run-time
max-run-time
10
100000
100000.0
1
1
seconds
HORIZONTAL

BUTTON
6
381
69
414
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
1199
105
1328
150
Current time
ticks
3
1
11

MONITOR
1202
153
1330
198
Next arrival time
next-arrival-time
3
1
11

MONITOR
1212
219
1352
264
MIN,MAX Queue length
(list (min [length queue-r] of readers) (max [length queue-r] of readers) )
1
1
11

SLIDER
832
52
1059
85
mean-pallets-per-truck
mean-pallets-per-truck
0
50
18.0
1
1
pallets
HORIZONTAL

SLIDER
1073
52
1302
85
mean-tags-per-pallet
mean-tags-per-pallet
1
300
2.32
1
1
tags
HORIZONTAL

MONITOR
839
441
956
486
Avg. Queue Length
total-truck-queue-time / (ticks - stats-start-time)
3
1
11

MONITOR
962
440
1077
485
Avg. Time in Queue
total-time-in-queue / total-queue-throughput
3
1
11

MONITOR
1081
440
1199
485
Avg. Time in System
total-time-in-system / total-system-throughput
3
1
11

MONITOR
979
493
1138
538
Tot.System Throughput /s
total-system-throughput / ticks
4
1
11

MONITOR
840
493
973
538
Reader Utilization %
100 * total-truck-service-time / (ticks - stats-start-time) / count readers
3
1
11

MONITOR
115
539
197
584
#Collisions
sum [num-of-collisions] of readers
17
1
11

CHOOSER
8
287
146
332
size-of-frame
size-of-frame
"SFSA" "DFSA"
1

MONITOR
1105
172
1202
217
Num. Arrivals
arrival-count
17
1
11

TEXTBOX
13
601
203
645
- Links Green: one of both ends has TM?\n- Links Red: both ends has TM? -> contention
9
0.0
1

TEXTBOX
1234
202
1312
220
OF TRUCKS
11
0.0
1

TEXTBOX
856
420
922
438
OF TRUCKS
11
0.0
1

TEXTBOX
990
397
1071
439
OF TAGS\nuntil pallet is \nput in service
11
0.0
1

TEXTBOX
1095
398
1170
440
OF TAGS\nuntil pallet is\ncompleted
11
0.0
1

SLIDER
6
135
207
168
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
8
223
218
251
ON : new network and save in 'locations.txt'\nOFF: load network from 'locations.txt'
9
0.0
1

BUTTON
842
551
940
584
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
1142
493
1280
538
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
9
172
206
216
When a pallet has many tags, e.g. 850, the time to inventory is greater than the max-time-of-tag-powered
9
0.0
1

SWITCH
13
676
152
709
two-readers?
two-readers?
1
1
-1000

TEXTBOX
16
648
166
670
two-readers? 'On' means we use two extreme readers
9
0.0
1

MONITOR
1185
548
1295
593
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
1002
549
1171
594
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
-20
-10
-19.0
0.5
1
dBm
HORIZONTAL

MONITOR
998
645
1174
682
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
572
703
distance-var-x
distance-var-x
1
30
12.0
1
1
(m)
HORIZONTAL

MONITOR
1207
442
1349
483
Total Pallet Throughput /s
total-pallets-thoughput / ticks
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
834
171
1006
204
sigma
sigma
0
5
1.94
0.01
1
NIL
HORIZONTAL

SLIDER
833
204
1005
237
portal-width
portal-width
1
5
2.0
0.1
1
NIL
HORIZONTAL

SLIDER
970
323
1100
356
height_1_tx
height_1_tx
0.5
3.5
1.2
0.1
1
m
HORIZONTAL

SLIDER
1099
358
1230
391
height_1_rx
height_1_rx
0.5
3.5
1.0
0.1
1
m
HORIZONTAL

SLIDER
970
358
1102
391
height_2_rx
height_2_rx
0.5
3.5
1.0
0.1
1
m
HORIZONTAL

SLIDER
1102
323
1230
356
height_2_tx
height_2_tx
0.5
3.5
1.2
0.1
1
m
HORIZONTAL

SWITCH
833
239
959
272
dislocated?
dislocated?
0
1
-1000

TEXTBOX
1021
306
1106
324
Portal LEFT
11
0.0
1

TEXTBOX
1125
304
1203
322
Portal RIGHT
11
0.0
1

TEXTBOX
1020
231
1150
273
If not dislocated? then \"2_rx\" is right and\n\"1_rx\" left
11
0.0
1

MONITOR
827
648
984
693
Total offered load (tags/s)
total-offered-load-of-tags / ticks
4
1
11

MONITOR
826
697
993
742
Total offered load (pallets/s)
total-offered-load-of-pallets / ticks
4
1
11

TEXTBOX
1134
87
1315
109
rand-normal mu=2.32 y sigma=1.29
9
0.0
1

SLIDER
401
708
573
741
distance-var-y
distance-var-y
0
100
22.0
1
1
[m]
HORIZONTAL

SLIDER
586
666
758
699
readers-per-row
readers-per-row
1
100
8.0
1
1
NIL
HORIZONTAL

SLIDER
585
703
766
736
readers-per-column
readers-per-column
1
100
5.0
1
1
NIL
HORIZONTAL

TEXTBOX
191
685
304
740
CLOSE:\ndistance-var-x 1\ndistance-var-x 1\nreaders-per-row 20\nreaders-per-column 5
9
0.0
1

TEXTBOX
292
684
416
739
FAR: \n distance-var-x 12\n distance-var-x 22\n readers-per-row 8\n readers-per-column 5
9
0.0
1

SWITCH
596
629
699
662
close?
close?
1
1
-1000

SWITCH
1036
135
1167
168
cart-traffic?
cart-traffic?
0
1
-1000

SWITCH
1010
691
1217
724
random-queue-assignation?
random-queue-assignation?
1
1
-1000

MONITOR
1252
689
1309
734
S chn
(sum [TM-time] of readers) / ticks / (count readers)
3
1
11

SLIDER
837
324
970
357
incli_1tx
incli_1tx
0
90
30.0
1
1
degrees
HORIZONTAL

SLIDER
835
359
970
392
incli_2rx
incli_2rx
0
90
30.0
1
1
degrees
HORIZONTAL

SLIDER
1233
323
1366
356
incli_2tx
incli_2tx
0
90
30.0
1
1
degrees
HORIZONTAL

SLIDER
1232
357
1367
390
incli_1rx
incli_1rx
0
90
30.0
1
1
degrees
HORIZONTAL

SLIDER
1187
394
1371
427
reader-sensitivity-g
reader-sensitivity-g
-100
-40
-80.0
1
1
dBm
HORIZONTAL

SLIDER
1350
91
1534
124
interf-threshold
interf-threshold
-200
-40
-96.0
1
1
dBm
HORIZONTAL

SLIDER
1352
55
1532
88
distance-multiplicative
distance-multiplicative
1
200
25.0
1
1
m
HORIZONTAL

TEXTBOX
1369
10
1500
54
physical world distance between readers\nInterferences depends on this parameter
9
0.0
1

SLIDER
1351
182
1529
215
transmitter-power
transmitter-power
0.05
1
0.8
0.01
1
W
HORIZONTAL

TEXTBOX
1367
130
1517
174
    tx_pw     ->     Threshold\n[0:100mW]         <=-83dBm\n[101:500mW]     <=-90dBm\n[0.501:2W]         <=-96dBm\n
9
0.0
1

MONITOR
1311
688
1396
733
S-per reader
((sum [cs-t] of readers) * 0.00258 + (sum [cs-t] of readers) * 0.00049 + (sum [ce-t] of readers) * 0.00046) / ticks / count readers
4
1
11

SWITCH
8
719
185
752
multiple-input-queues?
multiple-input-queues?
1
1
-1000

MONITOR
1393
223
1524
260
horizontal-separation [m]
distance-multiplicative * distance-var-x
4
1
9

MONITOR
1393
263
1525
300
vertical-separation [m]
distance-multiplicative * distance-var-y
4
1
9

MONITOR
1219
266
1294
303
Queue length
length queue
17
1
9

SLIDER
1281
490
1520
523
min-tag-inclination-angle
min-tag-inclination-angle
0
90
30.0
0.1
1
degrees
HORIZONTAL

SLIDER
403
760
575
793
dispersion-var
dispersion-var
0
100
0.0
1
1
%
HORIZONTAL

TEXTBOX
412
747
562
765
dispersion of tags in the volume
9
0.0
1

MONITOR
1334
531
1505
568
NIL
mean-reading-time-of-pallets
4
1
9

MONITOR
1334
569
1500
606
NIL
variance-reading-time-of-pallets
4
1
9

MONITOR
1335
608
1479
645
NIL
read-failures-probability
4
1
9

SWITCH
612
754
715
787
PLN?
PLN?
1
1
-1000

MONITOR
1334
646
1419
683
NIL
mean-of-tags
4
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
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="pru2_PLNoff" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-reading-time-of-pallets</metric>
    <metric>variance-reading-time-of-pallets</metric>
    <metric>read-failures-probability</metric>
    <metric>num-pallets-completely-read</metric>
    <metric>num-pallets-not-completely-read</metric>
    <metric>total-pallets-th</metric>
    <metric>total-offered-load-of-tags</metric>
    <metric>total-offered-load-of-tags-sg</metric>
    <metric>total-offered-load-of-pallets</metric>
    <metric>total-offered-load-of-pallets-sg</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>total-pallets-thoughput-sg</metric>
    <metric>total-tags-inventoried</metric>
    <metric>reader-utilization-percent</metric>
    <metric>avg-queue-length</metric>
    <metric>total-num-arrivals</metric>
    <metric>avg-time-queue-of-tags</metric>
    <metric>avg-time-in-system-of-tags</metric>
    <metric>total-simulation-time-sg</metric>
    <metric>mean-num-collisions-sg</metric>
    <metric>total-num-of-collisions</metric>
    <metric>mean [ce-t] of readers / ticks</metric>
    <metric>mean [cs-t] of readers / ticks</metric>
    <metric>mean [cc-t] of readers / ticks</metric>
    <metric>final-length-queue</metric>
    <metric>average-S1</metric>
    <metric>average-S2</metric>
    <metric>average-efficiency</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PLN?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dispersion-var" first="0" step="5" last="100"/>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-queue-assignation?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_1rx">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cart-traffic?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.1218"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="2.32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_1tx">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_2tx">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="100000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="multiple-input-queues?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_2rx">
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="pru2_PLNon" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-reading-time-of-pallets</metric>
    <metric>variance-reading-time-of-pallets</metric>
    <metric>read-failures-probability</metric>
    <metric>num-pallets-completely-read</metric>
    <metric>num-pallets-not-completely-read</metric>
    <metric>total-pallets-th</metric>
    <metric>total-offered-load-of-tags</metric>
    <metric>total-offered-load-of-tags-sg</metric>
    <metric>total-offered-load-of-pallets</metric>
    <metric>total-offered-load-of-pallets-sg</metric>
    <metric>total-system-throughput-sg</metric>
    <metric>total-pallets-thoughput-sg</metric>
    <metric>total-tags-inventoried</metric>
    <metric>reader-utilization-percent</metric>
    <metric>avg-queue-length</metric>
    <metric>total-num-arrivals</metric>
    <metric>avg-time-queue-of-tags</metric>
    <metric>avg-time-in-system-of-tags</metric>
    <metric>total-simulation-time-sg</metric>
    <metric>mean-num-collisions-sg</metric>
    <metric>total-num-of-collisions</metric>
    <metric>mean [ce-t] of readers / ticks</metric>
    <metric>mean [cs-t] of readers / ticks</metric>
    <metric>mean [cc-t] of readers / ticks</metric>
    <metric>final-length-queue</metric>
    <metric>average-S1</metric>
    <metric>average-S2</metric>
    <metric>average-efficiency</metric>
    <enumeratedValueSet variable="Q">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PLN?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="1.94"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dislocated?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-threshold">
      <value value="-90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reader-sensitivity-g">
      <value value="-80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interf-rri-radius">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dispersion-var" first="0" step="5" last="100"/>
    <enumeratedValueSet variable="new-netw?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-queue-assignation?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_1rx">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-row">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-pallets-per-truck">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-readers">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_tx">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-multiplicative">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cart-traffic?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transmitter-power">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-x">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-arrival-rate">
      <value value="0.1218"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-var-y">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-time-of-tag-powered">
      <value value="3.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-tags-per-pallet">
      <value value="2.32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-topology?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_2_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_1tx">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-tag-inclination-angle">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="height_1_rx">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_2tx">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="portal-width">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-power-to-feed-tag-IC">
      <value value="-19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="readers-per-column">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-run-time">
      <value value="100000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="multiple-input-queues?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="two-readers?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-frame">
      <value value="&quot;DFSA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incli_2rx">
      <value value="30"/>
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
