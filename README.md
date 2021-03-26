# sn_lc2cosmo_tutorials

This is a set of tutorials to get an end-to-end analysis of LSST SNIa light curves.

It steps through fitting light curves with SALT2 (within SNANA), fitting
nuisance cosmological parameters, fitting cosmology, doing simulations with
SNANA for bias corrections using the BBC framework, and propagating everything
to w.

These tutorials are intended to be run by DESC SNWG members on Cori at NERSC.

To get setup to use them, add this to your `.bashrc.ext` file
```
source /global/cfs/cdirs/lsst/groups/SN/software/setup_sn_all.sh
```

then verify the following:

```
python --version
Python 3.7.4
echo $SNANA_DIR
/global/cfs/cdirs/lsst/groups/SN/snana/SNANA
```

Once that's done, follow the directions in each individual tutorial, typically in an `AAA_README.TXT` file
