echo ' Very rough optimization grid for PHOTFLAG bits '

BITLIST='-9'
PREFIX='OUT_OPTIMIZE-00'
echo "# ============================================= "
echo " $PREFIX with BITLIST = $BITLIST ... "
snana.exe NOFILE \
    VERSION_PHOTOMETRY DC2_run22i_FITS \
    PRIVATE_DATA_PATH  $SNANA_LSST_ROOT/lcmerge \
    SNTABLE_LIST       'OUTLIER(nsig:10)' \
    TEXTFILE_PREFIX     $PREFIX \
    PHOTFLAG_BITLIST_REJECT $BITLIST \
  > ${PREFIX}.LOG

grep Bad ${PREFIX}.LOG
grep Outlier ${PREFIX}.LOG

BITLIST='10'
PREFIX='OUT_OPTIMIZE-01'
echo "# ============================================= "
echo " $PREFIX with BITLIST = $BITLIST ... "
snana.exe NOFILE \
    VERSION_PHOTOMETRY DC2_run22i_FITS \
    PRIVATE_DATA_PATH  $SNANA_LSST_ROOT/lcmerge \
    SNTABLE_LIST       'OUTLIER(nsig:10)' \
    TEXTFILE_PREFIX     $PREFIX \
    PHOTFLAG_BITLIST_REJECT $BITLIST \
  > ${PREFIX}.LOG

grep Bad ${PREFIX}.LOG
grep Outlier ${PREFIX}.LOG


BITLIST='10,11'
PREFIX='OUT_OPTIMIZE-02'
echo "# ============================================= "
echo " $PREFIX with BITLIST = $BITLIST ... "
snana.exe NOFILE \
    VERSION_PHOTOMETRY DC2_run22i_FITS \
    PRIVATE_DATA_PATH  $SNANA_LSST_ROOT/lcmerge \
    SNTABLE_LIST       'OUTLIER(nsig:10)' \
    TEXTFILE_PREFIX     $PREFIX \
    PHOTFLAG_BITLIST_REJECT $BITLIST \
  > ${PREFIX}.LOG

grep Bad ${PREFIX}.LOG
grep Outlier ${PREFIX}.LOG


BITLIST='16'
PREFIX='OUT_OPTIMIZE-03'
echo "# ============================================= "
echo " $PREFIX with BITLIST = $BITLIST ... "
snana.exe NOFILE \
    VERSION_PHOTOMETRY DC2_run22i_FITS \
    PRIVATE_DATA_PATH  $SNANA_LSST_ROOT/lcmerge \
    SNTABLE_LIST       'OUTLIER(nsig:10)' \
    TEXTFILE_PREFIX     $PREFIX \
    PHOTFLAG_BITLIST_REJECT $BITLIST \
  > ${PREFIX}.LOG

grep Bad ${PREFIX}.LOG
grep Outlier ${PREFIX}.LOG


BITLIST='16,17'
PREFIX='OUT_OPTIMIZE-04'
echo "# ============================================= "
echo " $PREFIX with BITLIST = $BITLIST ... "
snana.exe NOFILE \
    VERSION_PHOTOMETRY DC2_run22i_FITS \
    PRIVATE_DATA_PATH  $SNANA_LSST_ROOT/lcmerge \
    SNTABLE_LIST       'OUTLIER(nsig:10)' \
    TEXTFILE_PREFIX     $PREFIX \
    PHOTFLAG_BITLIST_REJECT $BITLIST \
  > ${PREFIX}.LOG

grep Bad ${PREFIX}.LOG
grep Outlier ${PREFIX}.LOG
