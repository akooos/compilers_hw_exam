#!/bin/sh
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

make
m=$?
if [ $m != 0 ]; then
 exit;
fi
good=0
bad=0
h=hibas
for k in tesztfajlok
do
    for i in `ls -1 $k/*.ok $k/*.szemantikus-hibas $k/*.szintaktikus-hibas $k/*.lexikalis-hibas`
    do
       printf "\033[33m-> Testing $i\n ${NC}"
#        printf   "\033[94m"
        if [ $# -ne 0 ]; then
          ./bead4 "$i" > /dev/null 
        else
          ./bead4 "$i" > /dev/null 2> /dev/null 
        fi
        v=$?
        if [ $v = 0 ];
        then
	   case "$i" in
           *.ok)
          ./bead4 "$i" > "$i.asm" 2>/dev/null
           printf "\033[33mAssembly and linking...${NC}\n"
          ./asmbly "$i"
           if [ $? = 0 ];
           then
printf ""
#              printf "\033[33mRunning...$i.out${NC}\n"
#              eval $i.out
#               good=$((good+1))
#               printf "${GREEN} == OK == $i\n ${NC}"
           else
               bad=$((bad+1))
               printf  "\033[31mAssembly vagy linkelés hiba: $i ${NC}\n"
           fi
           continue;
;;           
	   *lexikalis-hibas*)
               printf  "\033[31mJO-nak kaptam, de HIBAS[Lexikalis]: $k/$i ${NC}\n"
            bad=$((bad+1))
            continue;
;;
	   *szintaktikus-hibas*)
               printf "\033[31mJO-nak kaptam, de HIBAS[Szintaktikus]: $k/$i ${NC}\n"
            bad=$((bad+1))
            continue;
;;
	   *szemantikus-hibas*)
                printf  "\033[31mJO-nak kaptam, de HIBAS[Szemantikus]: $k/$i ${NC}\n"
            bad=$((bad+1))
            continue;
;;
	   *)

            good=$((good+1))
            printf "${GREEN} == OK == $i\n ${NC}"
           esac
        else
	   case "$i" in
	   *lexikalis-hibas*)
	    if [ $v != 1 ]; then
                printf  "\033[31mElméletileg lexikálisan hibás, de nem 1 a visszatérés($v) ${NC}\n"
            else
              printf "${GREEN} == OK == $i\n ${NC}"
	    fi
            good=$((good+1))
            continue;
;;
	   *szintaktikus-hibas*)    
	    if [ $v != 2 ]; then
                printf  "\033[31mElméletileg szintaktikailag hibás, de nem 2 a visszatérés($v)${NC}\n"
            else
              printf "${GREEN} == OK == $i\n ${NC}"
	    fi
            good=$((good+1))
            continue;
;;	   *szemantikus-hibas*)    
	    if [ $v != 3 ]; then
                printf  "\033[31mElméletileg szemantikus hibás, de nem 3 a visszatérés($v)${NC}\n"
            else
              printf "${GREEN} == OK == $i\n ${NC}"
	    fi
            good=$((good+1))
            continue;
;;
	   *)
            printf  "\033[31mHIBAS-nak kaptam, de elméletileg JO($v): $k/$i ${NC}\n"
            bad=$((bad+1))
            continue;
           esac
        fi
    done
done
for k in tesztfajlok/vizsga4
do
    for i in `ls -1 $k/*.ok $k/*.szemantikus-hibas $k/*.szintaktikus-hibas $k/*.lexikalis-hibas`
    do
       printf "\033[33m-> Testing $i\n ${NC}"
#        printf   "\033[94m"
        if [ $# -ne 0 ]; then
          ./bead4 "$i" > /dev/null 
        else
          ./bead4 "$i" > /dev/null 2> /dev/null 
        fi
        v=$?
        if [ $v = 0 ];
        then
	   case "$i" in
           *.ok)
          ./bead4 "$i" > "$i.asm" 2>/dev/null
           printf "\033[33mAssembly and linking...${NC}\n"
          ./asmbly "$i"
           if [ $? = 0 ];
           then
printf ""
#              printf "\033[33mRunning...$i.out${NC}\n"
#              eval $i.out
#               good=$((good+1))
#               printf "${GREEN} == OK == $i\n ${NC}"
           else
               bad=$((bad+1))
               printf  "\033[31mAssembly vagy linkelés hiba: $i ${NC}\n"
           fi
           continue;
;;           
	   *lexikalis-hibas*)
               printf  "\033[31mJO-nak kaptam, de HIBAS[Lexikalis]: $k/$i ${NC}\n"
            bad=$((bad+1))
            continue;
;;
	   *szintaktikus-hibas*)
               printf "\033[31mJO-nak kaptam, de HIBAS[Szintaktikus]: $k/$i ${NC}\n"
            bad=$((bad+1))
            continue;
;;
	   *szemantikus-hibas*)
                printf  "\033[31mJO-nak kaptam, de HIBAS[Szemantikus]: $k/$i ${NC}\n"
            bad=$((bad+1))
            continue;
;;
	   *)

            good=$((good+1))
            printf "${GREEN} == OK == $i\n ${NC}"
           esac
        else
	   case "$i" in
	   *lexikalis-hibas*)
	    if [ $v != 1 ]; then
                printf  "\033[31mElméletileg lexikálisan hibás, de nem 1 a visszatérés($v) ${NC}\n"
            else
              printf "${GREEN} == OK == $i\n ${NC}"
	    fi
            good=$((good+1))
            continue;
;;
	   *szintaktikus-hibas*)    
	    if [ $v != 2 ]; then
                printf  "\033[31mElméletileg szintaktikailag hibás, de nem 2 a visszatérés($v)${NC}\n"
            else
              printf "${GREEN} == OK == $i\n ${NC}"
	    fi
            good=$((good+1))
            continue;
;;	   *szemantikus-hibas*)    
	    if [ $v != 3 ]; then
                printf  "\033[31mElméletileg szemantikus hibás, de nem 3 a visszatérés($v)${NC}\n"
            else
              printf "${GREEN} == OK == $i\n ${NC}"
	    fi
            good=$((good+1))
            continue;
;;
	   *)
            printf  "\033[31mHIBAS-nak kaptam, de elméletileg JO($v): $k/$i ${NC}\n"
            bad=$((bad+1))
            continue;
           esac
        fi
    done
done

printf  "\033[33mJo: $good, Rossz: $bad ${NC}\n"
