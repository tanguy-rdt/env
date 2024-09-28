#!/bin/bash

CDEF=" \033[0m"                                     # default color
CCIN=" \033[0;36m"                                  # info color
CGSC=" \033[0;32m"                                  # success color
CRER=" \033[0;31m"                                  # error color
CWAR=" \033[0;33m"                                  # waring color
b_CDEF=" \033[1;37m"                                # bold default color
b_CCIN=" \033[1;36m"                                # bold info color
b_CGSC=" \033[1;32m"                                # bold success color
b_CRER=" \033[1;31m"                                # bold error color
b_CWAR=" \033[1;33m"                                # bold warning color

print () {
  TYPE=${1}
  shift
  case ${TYPE} in
    "-s")
        echo -e "${b_CGSC}$@${CDEF}";;    
    "-e")
        echo -e "${b_CRER}$@${CDEF}";;   
    "-w")
        echo -e "${b_CWAR}$@${CDEF}";;  
    "-i")
        echo -e "${b_CDEF}$@${CDEF}";; 
    "-d")
        echo -e "${b_CCIN}$@${CDEF}";; 
    "-ns")
        echo -e -n "${b_CGSC}$@${CDEF}";;    
    "-ne")
        echo -e -n "${b_CRER}$@${CDEF}";;   
    "-nw")
        echo -e -n "${b_CWAR}$@${CDEF}";;  
    "-ni")
        echo -e -n "${b_CDEF}$@${CDEF}";; 
    "-nd")
        echo -e -n "${b_CCIN}$@${CDEF}";; 
    "-ss")
        echo -e "${b_CGSC}SUCCESS: $@${CDEF}";;    
    "-se")
        echo -e "${b_CRER}ERROR: $@${CDEF}";;   
    "-sw")
        echo -e "${b_CWAR}WARNING: $@${CDEF}";;  
    "-si")
        echo -e "${b_CDEF}INFO: $@${CDEF}";; 
    "-sd")
        echo -e "${b_CCIN}DEBUG: $@${CDEF}";; 
    "-sns")
        echo -e -n "${b_CGSC}SUCCESS: $@${CDEF}";;    
    "-sne")
        echo -e -n "${b_CRER}ERROR: $@${CDEF}";;   
    "-snw")
        echo -e -n "${b_CWAR}WARNING: $@${CDEF}";;  
    "-sni")
        echo -e -n "${b_CDEF}INFO: $@${CDEF}";; 
    "-snd")
        echo -e -n "${b_CCIN}DEBUG: $@${CDEF}";; 
    *)
        echo -e "${b_CDEF}$@${CDEF}";; 
  esac
}

root_privilege() {
    if [ "$EUID" -ne 0 ]; then        
        sudo -v
        if [ $? -ne 0 ]; then
            print -se "Wrong password"
            exit 1
        fi
    fi
}