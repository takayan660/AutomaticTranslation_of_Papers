#!/bin/bash

if [ -z $1 ]; then
    echo 'no'
    exit 1
fi

if [ -z $2 ]; then
    filename=$(echo $1 | sed 's/\.pdf//')
elif [ -n $2 ]; then
    filename=$2
fi

#set -eu

pdfname=$1
language=ja

atexit() {
    [[ -n ${tmpfile}* ]] && rm -f "${tmpfile}*"
}
tmpfile1=`mktemp`
tmpfile2=`mktemp`
trap atexit EXIT
trap '[[ -n ${tmpfile-} ]] && rm -f "${tmpfile}"' SIGHUP SIGINT SIGTERM

### PDF to text ###
pdftotext ${pdfname} ${tmpfile1}

### Shaping ###
sed -e ':loop; N; $!b loop; s/\([a-z]\)-/\1/g' ${tmpfile1} > ${tmpfile2}
sed -e ':loop; N; $!b loop; s/\([a-z]\)\n/\1 /g' ${tmpfile2} > ${tmpfile1}
sed 's/\([a-z]\)\(\.\)/\1\2\n/g' ${tmpfile1} > ${filename}

### trans ###
echo "\\documentclass{jsarticle}\n\\\begin{document}\n" > ${filename}.tex
trans -b -i ${filename} :${language} >> ${filename}.tex
echo "\\end{document}" >> ${filename}.tex

### LaTeX ###
if [ ! -d LaTeX ]; then
    mkdir LaTeX
fi

cd LaTeX
mv ../${filename}.tex ./

ptex2pdf -l ${filename}.tex

### PDF display ###
evince ${filename}.pdf
