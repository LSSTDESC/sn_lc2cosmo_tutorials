echo ' Count 10 sigma outliers ... '

snana.exe NOFILE \
    VERSION_PHOTOMETRY DC2_run22i_FITS \
    PRIVATE_DATA_PATH  $SNANA_LSST_ROOT/lcmerge \
    SNTABLE_LIST       'OUTLIER(nsig:10)' \
    TEXTFILE_PREFIX    OUT_DEBUG_10sigma \
  > OUT_DEBUG_10sigma.LOG

tail -90 OUT_DEBUG_10sigma.LOG
