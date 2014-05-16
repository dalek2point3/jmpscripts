clear
set more off

global path "/mnt/nfs6/wikipedia.proj/jmp/"
global rawosm "/mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/"
global rawmaps "/mnt/nfs6/wikipedia.proj/jmp/rawdata/maps/"
global rawtrips "/mnt/nfs6/wikipedia.proj/jmp/rawdata/trips/"
global stash "/mnt/nfs6/wikipedia.proj/jmp/rawdata/stash/"
global myestimates "/mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/estimates/"
global tables "/mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/tables/"

cd `path'

********************************************
*************** datasets ********************
********************************************

insheet using ${rawosm}ne_final.csv, clear

