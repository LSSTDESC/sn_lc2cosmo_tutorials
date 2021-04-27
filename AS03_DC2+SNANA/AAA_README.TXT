
    Starter Kit to Perform Cosmology Analysis with
            DC2 Light curves and SNANA

             R. Kessler, B.Sanchez
     	     Session 1:  Mar 12, 2021
	     Session 2:  Mar 19, 2021
	     Session 3:  Mar 26, 2021
	      skip    :  Apr 02, 2021
	     Session 4:  Apr 09, 2021
	     Session 5:  Apr 16, 2021
	     

             **** OVERVIEW ****
	     
Here is an overview of several analysis sequences (AS) described in this
starter kit note, where each successive AS adds complexity. Most AS
starts with light curves and end with cosmology constraints; the
exception is a data-prep stage (AS3).

The primary aim is learning to use science codes shown in the bottom of
AAA_3LayerPipeline.pdf; e.g., light curve fitting, simulation , BBC,
cosmology fitting. The pippin pipeline is an example pipeline, but is not 
"THE" pipeline as many different pipelines (or AS) will be needed to 
perform different kinds of tasks.

Beware that several real-data steps are skipped, or have been already done,
and therefore these AS examples are overlay simplistic. For example, the
behind-the-scences effort to run DIA and prepare "merged" data files far
exceeds the effort to prepare and run this tutorial. 
Also beware that short batch times (<1 hr) are specified to improve
priority for tutorial; longer batch time limits will be needed for more
realistic analyses.


AS1) SIMPLE/NAIVE
   + LCFIT
   + HubbleFit for nuissance params (alpha,beta,sigma_int)
   + cosmology fit using old-and-fast wFit minimizer
       [no biasCor, no classifier, old WMAP prior, mostly interactive]

AS2) PLUS_BIASCOR-1D
   + repeat with bias corrections and BBC
   + incude simulated data set

AS3) ANALYSIS_PREP
   + prepare flux-uncertainty corrections
   + prepare PHOTFLAG cut to reject flux-outliers

AS4) PLUS_BIASCOR-5D
    + repeat AS2 with BBC5D, and using ANALYSIS_PREP results
    
AS5) PIPPIN
   repeat with Pippin end-to-end-pipeline;
   include create_covariance and CosmoMC(+Planck prior)


             ***** PRELIMINARIES *****

* Copy the starter kit,
        $SNANA_LSST_ROOT/starterKits/DC2+SNANA
  to your personal directory under $SNANA_LSST_USERS, and define ENV
  (here with pwd, or in your .bashrc.ext file with {pwd})
     export SNANA_DC2_DIR=`pwd`

* Check DC2 light curve data (prepared by Bruno):
     $SNANA_LSST_ROOT/lcmerge/DC2_run22i_FITS
     $SNANA_LSST_ROOT/lcmerge/DC2_run22i_TEXT

    + Note that data files are gzipped (TEXT and FITS)
    + Check unix command zmore, zless, zcat, zgrep.
    + README has YAML-compliant DOCUMENTATION block.
  
* more generally, SNANA environment is organized as follows:
   + "DESC-public" files are under
        $SNANA_LSST_ROOT    # inform group when installing/updating here
   + sharable user directories ('lsst' group with r+w access for all):
        $SNANA_LSST_USERS   # do whatever you want here
   + and public files are under
        $SNDATA_ROOT        # downloaded from https://zenodo.org/record/4015340
     (do NOT copy files here; contact RK/Dillon/D.Jones to make things public)
  
*  Here we analyze the FITS format to mimic reality. While text files
   are sometimes convenient, storing 1 text file per event is not practical
   for LSST. However, it is easy to extract problematic events into TEXT
   format for debugging.

* Help on configuring batch inputs,
     submit_batch_jobs.sh  -H  SIM
     submit_batch_jobs.sh  -H  FIT
     submit_batch_jobs.sh  -H  BBC

* Limited help with science codes:
     https://github.com/RickKessler/SNANA/blob/master/doc/snana_manual.pdf


        ***** Analysis 1) SIMPLE/NAIVE *****

Quick command summary:
AS1:    submit_batch_jobs.sh  LCFIT_DATA-ONLY.NML
AS1:    submit_batch_jobs.sh  SALT2mu_DC2_M11.INPUT 

Detailed explanation:

Before launching batch job, make sure that interactive job runs without
aborting for silly reasons; you don't want to wait in the queue, only
to immediately abort because of a typing mistake. Check that interactive
job doesn't abort,

    snlc_fit.exe LCFIT_DATA-ONLY.NML  MXEVT_PROCESS 10
    ls OUT_*         # see output tables in TEXT and ROOT format

Ready to launch SALT2 light curve fit :
    submit_batch_jobs.sh  LCFIT_DATA-ONLY.NML -n  # init, but NO launch
    submit_batch_jobs.sh  LCFIT_DATA-ONLY.NML     # run for real
    cat OUT1_SALT2FITS_DATAONLY/MERGE.LOG         # view summary
    
Check batch queue status with
     squeue -u <userName>

Next, fit for binned distances, nuissance params,
cosmology with interactive jobs:
     SALT2mu.exe SALT2mu_DC2_M11.INPUT             # a, b, sigma_int, MU(z_i)
     wfit.exe OUT1_SALT2mu_DC2_M11.M0DIF -cmb_sim  # cosmo fit with WMAP prior
     cat OUT1_SALT2mu_DC2_M11.M0DIF.cospar         # view cosmo results

Repeat using submit_batch (BBC+wfit together):
    submit_batch_jobs.sh SALT2mu_DC2_M11.INPUT   # SALT2mu fit + wfit together
    ls OUT1_SALT2mu_DC2_M11                      # check results here


             *** DEBUG TOOLS ***

  cd DEBUG_EXAMPLES/
  
  ./DEBUG_EXAMPLE-01a_FLUX_OUTLIERS         # create tables with flux-outliers
       more OUT_DEBUG_50sigma.OUTLIER.TEXT

  ./DEBUG_EXAMPLE-01b_VIEW_FLUX_OUTLIERS    # nicer views of OUTLIER tables
      visually compare  OUTLIERS_DC2_run22i.DAT  vs.  OUTLIERS_DESY3_DIFFIMG.DAT

  ./DEBUG_EXAMPLE-02_makeLCplots            # make a few light curve plots (pdf file)

  ./DEBUG_EXAMPLE-03_makeTEXTfiles          # extract a few LC into text format

  ./DEBUG_EXAMPLE-04_LCfit                  # LC fit 2 SN with 10sigma outliers
    grep FAILED OUT_LCFIT*LOG
    
  ./DEBUG_EXAMPLE-05_wishList               # I wish we had this in previous surveys

  Homework:
     + for a few extreme OUTLIERS, find images & stamps for Search/Template/Diff
     + examine OUTLIER tables and look for correlations
       (hint: create table with NSIG>=0 and compare distributions for outliers vs. bulk)
       
  
       ***** Analysis 2) PLUS_BIASCOR-1D *****

Quick command summary:
AS2:    submit_batch_jobs.sh  SIMGEN_MASTER_DC2.INPUT  # run once to avoid clobber
AS2:    submit_batch_jobs.sh  LCFIT_DATA+BIASCOR.NML
AS2:    submit_batch_jobs.sh  SALT2mu_DC2_BBC1D.INPUT 

WARNING: need 1 volunteer to run SIMGEN to avoid clobbering;
         everyone can run the LCFIT and SALT2mu jobs from their user dir.
	 
Detailed explanation:

Here we start by generating sims for bias corrections, and also a
simulated data sample to check the analysis. Simplifications include
  + redshift efficiency = 100%
  + purity = 100%

Check that short interactive sim job does not abort:
    snlc_sim.exe SIMGEN_LSST_DC2.INPUT NGENTOT_LC 10
    [our knowledge of DC2 is in SIMGEN_LSST_DC2.INPUT]

Check SIMLIB/Cadence properties:
   snlc_sim.exe SIMGEN_LSST_DC2.INPUT SIMLIB_DUMP 1  
   more SIMLIB_DUMP_SUMMARY_LSST-ugrizY.TEXT           # one row per cadence
   
Check maps used in sim with dashboard util:
   snlc_sim.exe SIMGEN_LSST_DC2.INPUT DASHBOARD

Submit sims to batch:
   submit_batch_jobs.sh SIMGEN_MASTER_DC2.INPUT
   squeue -u <userName>
   cat SIMLOGS_DC2/MERGE.LOG                      # check status

Submit LC fits to batch for DC2 data, sim data, sim biasCor:
   submit_batch_jobs.sh LCFIT_DATA+BIASCOR.NML
   cat OUT2_SALT2FITS_DATA+BIASCOR/MERGE.LOG      # check status

Submit BBC fits:
   submit_batch_jobs.sh  SALT2mu_DC2_BBC.INPUT
   cat OUT2_SALT2mu_DC2_BBC/MERGE.LOG             # check status
   

       ***** Analysis 3) ANALYSIS_PREP *****

AS3:  ./outlier_optimize_PHOTFLAG.sh
AS3:  make_fluxerr_model.py  fluxerr_model.input
AS3:  make_fluxerr_model.py  fluxerr_model.input --verify
AS3:  ./install_fluxerrmodel.sh

Detailed explanation:

        *** Reject Outliers using PHOTFLAG Bits ***
	
First, optimize rejecting outlier fluxes using PHOTFLAG bits.
To see the PHOTFLAG bit definitions,
   more $SNANA_LSST_ROOT/lcmerge/DC2_run22i_FITS/DC2_run22i_FITS.README 

From the DEBUG_EXAMPLES back in AS1, let's start by regenerating an
overview of 10 sigma outliers,
    ./outlier_overview.sh
From the screen output, visually check which PHOTFLAG bits are efficient at
rejecting outliers, and also efficient at keeping BULK (non-outlier)
observations. Goal is to maximize both EFF(OUTLIER) and EFF(BULK).

Next, try various combinations of PHOTFLAG bits with this embarassingly
simple optimizer script,
   ./outlier_optimize_PHOTFLAG.sh

For this tutorial, let's proceed with rejecting on bit 16 that has the
following performance metrics:
    Non-outlier (BULK) loss is 824/86534 < 1%
    10 sigma outlier reduction:
       u:  86 -> 84    :(
       g:  16 ->  8    so-so 
       r:  37 -> 21    so-so
       i:  40 ->  9    good
       z:  28 ->  1    woohoo
       y    5 ->  2    so-so

Since the PHOTFLAG-reject mask is just one number (and was stable for DES),
it is not publicly installed like the flux-error maps (below), SIMLIB,
HOSTLIB, etc ... ; instead, it is part of the NML input file,
    grep PHOTFLAG_MSKREJ ../AS4/LCFIT_DATA.NML
However, this implementation procedure may cause synchronizing problems if 
the PHOTFLAG reject mask changes. Should we create a public file
(e.g, PHOTFLAG_BITLIST_DC2.DAT) for analysis codes to read ? Should
a BITLIST file be associated with each data folder ?

Would anyone like to create a more optimal/rigorous procedure to
determine which PHOTFLAG bits we should use to reject observations ?
From DES experience, DIA-based cuts may not be enough ... may need ML.

             *** Flux-Uncertainty Maps ***
	     
Next we use fakes, which is our DC2 data, to create maps that correct
flux uncertainties for both data (DC2) and sims; see Sec 6.4 of
https://arxiv.org/pdf/1811.02379.pdf . For normal analysis, the "fakes"
are separate from the real data ... but for DC2, the  fakes and data are
the same. Two maps are created with command

   make_fluxerr_model.py  fluxerr_model.input      # create FAKE and SIM maps

Here the maps depend only on band, and PSF is a dummy variable with just
1 bin ... until we get SBMAG. Examine uncertainty scales with

   more OUT3_FLUXERRMODEL/FLUXERRMODEL_FAKE.DAT
   more OUT3_FLUXERRMODEL/FLUXERRMODEL_SIM.DAT
   grep ROW OUT3_FLUXERRMODEL/FLUXERRMODEL_*   # quick view 

Verify maps by repeating the process using the maps in both the data
and sim, and checking that the resulting error scales are 1:
   make_fluxerr_model.py  fluxerr_model.input --verify  # idiot check
   grep ROW OUT3_FLUXERRMODEL_VERIFY/FLUXERRMODEL_*

Install maps in DESC-public location with standard file names that
never changes:
   cat install_fluxerrmodel.sh
   ./install_fluxerrmodel.sh

To see how these maps are used in the input analysis files,
     grep FLUXERRMODEL_FILE  ../AS4/*.*  | grep ROOT

Another implementation option is to re-make data files with uncertainties
inflated by the FLUXERRMODEL map ... and we should definitely do this for
public light curve data releases. For internal analysis, however, it may be
more practical to use FLUXERRMODEL_FILE that updates asynchronously w.r.t.
data updates. Note that FLUXERRMODEL_FILE for sim is always needed.

         *** REDCOV ***
Next, check for reduced covariances among excess scatter in flux.
Sim model is
     (Scale*sigma_stat)^2 = sigma_stat^2 + sigma_anom^2
     Flux scatter is uncorrelated from sigma_stat;
     Flux scatter can have correlations for sigma_anom.
There is no calculation to determin REDCOV, so instead we compare data
to sims with different REDCOV values. To compare DC2 data and sim,
for each event and passband we define 
   CHI2_TRUEFLUX = Sum [ (F - F_true)^2 / sigma^2 ] 
   PROB_TRUEFLUX = PROB(chi2,Ndof)
evince AS3/prob_truflux_vs_redcov.pdf
grep   REDCOV grep REDCOV AS4/SIMGEN_MASTER_DC2.INPUT


       ***** Analysis 4) PLUS_BIASCOR-5D *****

Quick command summary:

AS4:  submit_batch_jobs.sh   SIMGEN_MASTER_DC2.INPUT
AS4:  submit_batch_jobs.sh   LCFIT_DATA.NML
AS4:  submit_batch_jobs.sh   LCFIT_BIASCOR.NML
AS4:  submit_batch_jobs.sh   SALT2mu_DC2_BBC5D.INPUT 
AS4:  snlc_efficiency.py   OUT4_SALT2FITS_DATA

Detailed explanation:

Compared with AS2, here we used BBC5D (instead of BBC1D), the flux-uncertainties
are inflated using maps created in AS3, and observations with PHOTFLAG bit 16 are
rejected (see AS3). The biasCor-5D sim is fairly large (few E5 after cuts) in order
to use the BBC5D formalism that determines distance bias as a function of
{z,c,x1,alpha,beta}. The simulated alpha/beta grid is determined by
    grep GRID SIMGEN_MASTER_DC2.INPUT 

The sim job generates both sim data and large BiasCor,
    submit_batch_jobs.sh  SIMGEN_MASTER_DC2.INPUT

For light curve fitting, the DATA (DC2 and sim) and BIASCOR are
launched as separate batch jobs to make efficient use of CPUs,

     submit_batch_jobs.sh  LCFIT_DATA.NML
     submit_batch_jobs.sh  LCFIT_BIASCOR.NML

[problem is that short-data and long-biasCor jobs get same NCPU;
 still thinking about how to auto-compute more efficient NCPU]

Check data/sim overlays ; e.g., as shown in OUT4_ovdatasim.pdf
  [can we make these overlays every few weeks during LSST operations?]

Compute efficiency vs. redshift for DC2 and sim when LCFIT_DATA
finishes (no need to wait for LCFIT_BIASCOR):
   snlc_efficiency.py   OUT4_SALT2FITS_DATA

Finally, run the BBC5D job after both LCFIT jobs finish:
    submit_batch_jobs.sh  SALT2mu_DC2_BBC5D.INPUT
    more OUT4_SALT2mu_DC2_BBC5D/BBC_SUMMARY_FITPAR.YAML


       ***** Analysis 5) PIPPIN *****

Quick command summary:
AS5:    pippin.sh  <TBD ...>

# === END ===

