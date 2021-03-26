
    Starter Kit to Perform Cosmology Analysis with
            DC2 Light curves and SNANA

             R. Kessler, B.Sanchez
     	     Session 1:  Mar 12, 2021
	     Session 2:  Mar 19, 2021


             **** OVERVIEW ****
	     
Here is an overview of three analysis sequences (AS) described in this
starter kit note, where each successive AS adds complexity. Each AS
starts with light curves and end with cosmology constraints. The primary
aim is learning to use the science codes shown in the bottom of
AAA_3LayerPipeline.pdf; e.g., light curve fitting, simulation , BBC,
cosmology fitting. The pippin pipeline (AS4) is an example pipeline,
but is not "THE" pipeline as many different pipelines (or AS) will be
needed to perform different kinds of tasks.

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

AS2) PLUS_BIASCOR
   + repeat with bias corrections and BBC
   + incude simulated data set

AS3) PLUS_FLUXERR_MAP
    + repeat with FLUXERR corrections for both DC2 data and sims.
    
AS4) PIPPIN
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
     (do NOT install here; contact RK/Dillon/D.Jones to make things public)
  
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
       
  
       ***** Analysis 2) PLUS_BIASCOR *****

Quick command summary:
AS2:    submit_batch_jobs.sh  SIMGEN_MASTER_DC2.INPUT  # run once to avoid clobber
AS2:    submit_batch_jobs.sh  LCFIT_DATA+BIASCOR.NML
AS2:    submit_batch_jobs.sh  SALT2mu_DC2_BBC.INPUT 

WARNING: need 1 volunteer to run SIMGEN to avoid clobbering;
         everyone can run the LCFIT and SALT2mu jobs from their user dir.
	 
Detailed explanation:

Here we start by generating sims for bias corrections, and also a
simulated data sample to check the analysis. Simplifications include
  + redshift efficiency = 100%
  + purity = 100%

Check that short interactive sim job does not abort:
    snlc_sim.exe SIMGEN_LSST_DC2.INPUT NGENTOT_LC 10

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
   

       ***** Analysis 3) PLUS_FLUXERR_MAP *****

Quick command summary:
AS3:  <TBD ...>


       ***** Analysis 4) PIPPIN *****

Quick command summary:
AS4:    pippin.sh  <TBD ...>

# === END ===

