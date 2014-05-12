import sys

if hasattr(sys, 'real_prefix'):
    print "true"
else:
    print "flase"
