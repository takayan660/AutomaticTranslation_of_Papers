#!/bin/bash

if [[ -z $1 ]]; then
    echo 'no'
    exit 1
fi

if [[ -z $2 ]]; then
    FILENAME=$(echo $1 | sed 's/\.pdf//')
elif [[ -n $2 ]]; then
    FILENAME=$2
fi

set -eu

PDFNAME=$1
FOLDERNAME=${1%.*}
LANGUAGE=ja

atexit() {
    [[ -n ${TMPFILE}* ]] && rm -f "${TMPFILE}*"
}
TMPFILE1=`mktemp`
TMPFILE2=`mktemp`
trap atexit EXIT
trap '[[ -n ${TMPFILE-} ]] && rm -f "${TMPFILE}"' SIGHUP SIGINT SIGTERM

if [ ! -d $FOLDERNAME ]; then
    mkdir -p $FOLDERNAME
fi

cd ${FOLDERNAME}

### PDF to text ###
pdftotext ../${PDFNAME} ${TMPFILE1}

### Shaping ###
sed -e ':loop; N; $!b loop; s/\([0-9,A-z,-,",¨]\)\n/\1 /g' ${TMPFILE1} > ${TMPFILE2}
sed 's/\(\.\) \([A-Z]\)/\1\n\2/g' ${TMPFILE2} > ${FILENAME}

### trans ###
echo "\documentclass{jsarticle}" > ${FILENAME}.tex
echo "\begin{document}" >> ${FILENAME}.tex
trans -b -i ${FILENAME} :${LANGUAGE} >> ${FILENAME}.tex 
echo "\end{document}" >> ${FILENAME}.tex

### LaTeX ###
ptex2pdf -l ${FILENAME}.tex
if [ -f ${FILENAME}.dvi ]; then
    dvipdfmx ${FILENAME}.dvi
fi

### PDF display ###
evince ${FILENAME}.pdf
