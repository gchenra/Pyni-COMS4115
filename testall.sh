#!/bin/bash

# authors: MicroC testall.sh modified by Yitao Chen

# Regression testing script for Pyni
# Step through a list of files
#  Compile, run, and check the output of each expected-to-work test
#  Compile and check the error of each expected-to-fail test
#  reference: Edwards' MicroC testall.sh

# Path to the LLVM interpreter
LLI="lli"

# Path to the LLVM compiler
LLC="llc"

# Path to the C compiler
CC="cc"

# Path to the pyni compiler.  Usually "./pyni.native"
# Try "_build/pyni.native" if ocamlbuild was unable to create a symbolic link.
PYNI="./pyni.native"

# Set time limit for all operations
ulimit -t 30

globallog=testall.log
rm -f $globallog
error=0
globalerror=0
passed=0
total=0
keep=0

Usage() {
    echo "Usage: testall.sh [options] [.shoo files]"
    echo "-k    Keep intermediate files"
    echo "-h    Print this help"
    exit 1
}

SignalError() {
    if [ $error -eq 0 ] ; then
	error=1
    fi
}

# Compare <outfile> <reffile> <difffile>
# Compares the outfile with reffile.  Differences, if any, written to difffile
Compare() {
    generatedfiles="$generatedfiles $3"
    echo diff -b $1 $2 ">" $3 1>&2
    diff -b "$1" "$2" > "$3" 2>&1 || {
	SignalError "$1 differs"
	echo "FAILED $1 differs from $2" 1>&2
    }
}

# Run <args>
# Report the command, run it, and report any errors
Run() {
    echo $* 1>&2
    eval $* || {
	SignalError "$1 failed on $*"
	return 1
    }
}

# RunFail <args>
# Report the command, run it, and expect an error
RunFail() {
    echo $* 1>&2
    eval $* && {
	SignalError "failed: $* did not report an error"
	return 1
    }
    return 0
}

Check() {
    error=0
    basename=`echo $1 | sed 's/.*\\///
                             s/.pn//'`
    reffile=`echo $1 | sed 's/.pn$//'`
    basedir="`echo $1 | sed 's/\/[^\/]*$//'`/."

    echo 1>&2
    echo "###### Testing $basename" 1>&2

    generatedfiles=""

    # generatedfiles="$generatedfiles ${basename}.ll ${basename}.s ${basename}.exe ${basename}.out" &&
    
    generatedfiles="$generatedfiles ${basename}.out" &&
    
    Run "$PYNI -l" "$1" ">" "${basename}.out" &&
    Compare ${basename}.out ${reffile}.out ${basename}.diff

    # Run "$PYNI" "$1" ">" "${basename}.ll" &&
    # Run "$LLC" "-relocation-model=pic" "${basename}.ll" ">" "${basename}.s" &&
    # Run "$CC" "-o" "${basename}.exe" "${basename}.s" "builtins.o" "-lm" &&
    # Run "./${basename}.exe" > "${basename}.out" &&
    # Compare ${basename}.out ${reffile}.out ${basename}.diff

    # Report the status and clean up the generated files

    #echo "before error check"
    total=$((total+1))
    if [ $error -eq 0 ] ; then
        if [ $keep -eq 0 ] ; then
            rm -f $generatedfiles
        fi
        echo -n "."
        echo "###### SUCCESS" 1>&2
        passed=$((passed+1))
    else
    	printf "\n"
    	echo -n "$basename..."
        echo "failed"
        echo "###### FAILED" 1>&2
        globalerror=$error
    fi
}

CheckFail() {
    error=0
    basename=`echo $1 | sed 's/.*\\///
                             s/.pyni//'`
    reffile=`echo $1 | sed 's/.pyni$//'`
    basedir="`echo $1 | sed 's/\/[^\/]*$//'`/."

    echo 1>&2
    echo "###### Testing $basename" 1>&2

    generatedfiles=""

    generatedfiles="$generatedfiles ${basename}.err ${basename}.diff" &&
    RunFail "$PYNI" "<" $1 "2>" "${basename}.err" ">>" $globallog &&
    Compare ${basename}.err ${reffile}.err ${basename}.diff

    # Report the status and clean up the generated files
    total=$((total+1))
    if [ $error -eq 0 ] ; then
        if [ $keep -eq 0 ] ; then
            rm -f $generatedfiles
        fi
        echo -n "."
        echo "###### SUCCESS" 1>&2
        passed=$((passed+1))
    else
    	printf "\n"
    	echo -n "$basename..."
        echo "failed"
        echo "###### FAILED" 1>&2
        globalerror=$error
    fi
}

while getopts kdpsh c; do
    case $c in
	k) # Keep intermediate files
	    keep=1
	    ;;
	h) # Help
	    Usage
	    ;;
    esac
done

shift `expr $OPTIND - 1`

LLIFail() {
  echo "Could not find the LLVM interpreter \"$LLI\"."
  echo "Check your LLVM installation and/or modify the LLI variable in testall.sh"
  exit 1
}

which "$LLI" >> $globallog || LLIFail

if [ $# -ge 1 ]
then
    files=$@
else
    files="tests/test-*.pn"
fi

for file in $files
do
    case $file in
	*test-*)
	    Check $file 2>> $globallog
	    ;;
	*failed-*)
	    CheckFail $file 2>> $globallog
	    ;;
	*)
	    echo "unknown file type $file"
	    globalerror=1
	    ;;
    esac
done
printf "\n"
echo $passed" out of "$total" tests passed!"

exit $globalerror