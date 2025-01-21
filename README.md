# Listen-Before-Talk Multiclass, LBTM
Multiclass-Traffic-RFID-Simulator

Simulates the operation in supermarket and hospital plant with different traffic classes. The implementation is carried out through the [Netlogo](https://ccl.northwestern.edu/netlogo/) modeling environment. Netlogo is multiplatform and open source.

- *hospital.nlogo* is the main simulator for the dense RFID network for the hospital scenario.
- *supermarket.nlogo* is the main simulator for the dense RFID network for the grocery shop scenario.

- *Experiments_Hospital* and Experiments_Shop. These folders contain the experiments for the RFID network scenarios investigated in the publication


> **P. López-Matencio, J. Vales-Alonso, JJ Alcaraz**
> "LBTM: Listen-before-Talk Protocol for Multiclass UHF RFID Networks," 
> **Sensors 2020**, 20, 2313. 
> [https://doi.org/10.3390/s20082313](https://doi.org/10.3390/s20082313) 


## Example
Simple usage 
```
java -Xmx1024m -Dfile.encoding=UTF-8 -cp netlogo-6.4.0.jar \
 org.nlogo.headless.Main \
 --model ~/utl500/hospital.nlogo \
 --experiment utl1_500 \
 --table ~/utl500/_utl1_500.csv \
 --threads 8 &
```

where 
- `netlogo-6.4.0.jar` is the name of the Netlogo executable.
- `--model ~/utl500/hospital.nlogo` is the path to our built simulator.
- `--experiment utl1_500` is the name that have our experiment and contains all the initial configuration paramenters. We can set the configuration parameteres (e.g., number of reader, separatation distance, height of antennas, or the number of slots used to acces the medium) in the *Netlogo BahaviorSpace* (`CTRL+B`).
- ` --table ~/utl500/_utl1_500.csv` is the file name of the results file.
- `--threads 8` sets the number of simultaneous simulations. Can be increased or decreased with the server capacity.
