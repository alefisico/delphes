HEPTopTagger
============

Source code for HEPTopTagger and MultiR-HEPTopTagger top-tagging algorithms.


Example usage
============

Fastjet available
-----------------

If fastjet is available (fastjet-config can be called):  
`make`  
`./example`  

The final two lines of the output should be:  
`Input fatjet: 1  pT = 408.338`  
`Output: pT = 337.119 Mass = 177.188 f_rec = 0.0472206`  


Install fastjet
---------------

If fastjet is not available you have to install it first (we will install it under `$HOME/fastjet`):  
`export INSTALLDIR=$HOME/fastjet`  
`mkdir $INSTALLDIR`  
`curl -O http://fastjet.fr/repo/fastjet-3.1.0.tar.gz`  
`tar xfvz fastjet-3.1.0.tar.gz`  
`cd fastjet-3.1.0`  
`./configure --prefix=$INSTALLDIR`  
`make`  
`make install`  

This will need to be done once per shell-session (or you add it to your init file):  
`export PATH=$HOME/fastjet/bin:$PATH`  

If `fastjet-config` outputs a lengthy help message everything is fine. Now the example should work.
