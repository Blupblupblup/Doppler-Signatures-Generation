### Repository description

- This repository contains a simple MATLAB simulation code that generates pulse Doppler radar signatures
for four classes of helicopter-like targets. The dataset thus created is used to investigated AD
deep and non-deep methods in a dedicated [paper](https://hal.archives-ouvertes.fr/hal-03660033). The code of the associated AD experiments is available in this
github [repository](https://github.com/Blupblupblup/Near-OOD-Doppler-Signatures), which also suggests potential extensions of this simulation (use lower Doppler resolution, increase intra and inter-class diversity, etc).
- These scripts were directly inspired by MATLAB examples, 
notably https://fr.mathworks.com/help/radar/ug/introduction-to-micro-doppler-effects.html and https://fr.mathworks.com/help/phased/ug/designing-a-basic-monostatic-pulse-radar.html.
- To generate the samples used in the companion repository and paper, launch the script `generate_target_dataset.m`. You need to create a `data/` folder in the code directory beforehand, the
files created by the simulation will be stored in `data/` by `target.m`.

![four classes](four_classes.png)

If you found this code useful, please consider citing the [paper](https://hal.archives-ouvertes.fr/hal-03660033/document):

```
@unpublished{bauw:hal-03660033,
  TITLE = {{Near out-of-distribution detection for low-resolution radar micro-Doppler signatures}},
  AUTHOR = {Bauw, Martin and Velasco-Forero, Santiago and Angulo, Jesus and Adnet, Claude and Airiau, Olivier},
  URL = {https://hal.archives-ouvertes.fr/hal-03660033},
  NOTE = {working paper or preprint},
  YEAR = {2022},
  HAL_ID = {hal-03660033},
  HAL_VERSION = {v1},
}
```

### License

MIT
