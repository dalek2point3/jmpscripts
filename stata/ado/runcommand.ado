** this ado takes a XT regression, runs it with "fe vce(robust)" and then saves it in a file

program runcommand

clear all
set more off
set matsize 11000
global path "/mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/"
global rawosm "/mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/"
global osmchange "/mnt/nfs6/wikipedia.proj/jmp/rawdata/osmchange/"
global rawmaps "/mnt/nfs6/wikipedia.proj/jmp/rawdata/maps/"
global rawtrips "/mnt/nfs6/wikipedia.proj/jmp/rawdata/trips/"
global stash "/mnt/nfs6/wikipedia.proj/jmp/rawdata/stash/"
global myestimates "/mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/estimates/"
global tables "/mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/tables/"

adopath + "/mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/ado"

cd ${path}

args datafile command saveas

di "ADO: datafile: `datafile'"
di "ADO: model: `command'"
di "ADO: saveas: `saveas'"

//shell qsub -b y stata "`command'" 
shell qsub -b y -cwd -pe statape 8 stata -b 'runcommand.do `datafile' \"`command'\" `saveas''
end
