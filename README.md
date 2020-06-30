## Step 1: Language Tutorial How to install Pyni
Install OCaml and LLVM. The optimal LLVM version is 10.0. Different LLVM version will affect the output of test cases! \
On Mac system: 
```
  $ brew install opam 
  $ brew install llvm 
  $ opam install llvm 
```
On linux system: 
```
  $ sudo apt-get install opam 
  $ sudo apt-get install llvm 
  $ opam install llvm 
```

## Step 2: Download Pyni and compile the Pyni compiler:
```
  $ git clone https://github.com/peachchen0716/COMS4115/ $ cd COMS4115 
  $ make 
```

## Step 3: Write a simple Pyni program:

The following implementation of greatest command divider is a simple code written in Pyni syntax.
```
  def gcd(int a, int b) : int { while (a != b) { 
     if (a > b) a = a - b; else b = b - a; 
  } 
  return a; 
  } 
  print( gcd(99, 121) );
```

save the code into gcd.pn file and compile the file by following command. 
```
  $./pyni.native -l gcd.pn > gcd.out 
  $ lli gcd.out 
  # 11 
```
OR test the code directly with the compiler 
```
  $./pyni.native 
```
Copy the code above in the following space and press **Control + D** when finished. 
