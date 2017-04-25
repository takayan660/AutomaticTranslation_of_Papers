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

#set -eu

PDFNAME=$1
FOLDERNAME=$(echo $1 | sed 's/\.pdf//')
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
sed -e ':loop; N; $!b loop; s/\([a-z]\)-/\1/g' ${TMPFILE1} > ${TMPFILE2}
sed -e ':loop; N; $!b loop; s/\([a-z]\)\n/\1 /g' ${TMPFILE2} > ${TMPFILE1}
sed 's/\([a-z]\)\(\.\)/\1\2\n/g' ${TMPFILE1} > ${FILENAME}

### trans ###
echo "\\documentclass{jsarticle}\n\\\begin{document}\n" > ${FILENAME}.tex
trans -b -i ${FILENAME} :${LANGUAGE} >> ${FILENAME}.tex
echo "\\end{document}" >> ${FILENAME}.tex

### LaTeX ###
ptex2pdf -l ${FILENAME}.tex

### PDF display ###
evince ${FILENAME}.pdf
