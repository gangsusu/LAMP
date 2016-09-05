#!/bin/bash
# Version: 1.0.0# Version: 1.0.0
# Author: Mr_miao
# Date: 2016/9/1
# Description: LANMP Install Script
ml=$(cd `dirname $0`; pwd)
if [ "$UID" -ne 0 ]  
then  
    printf "Error: You must be root to run this script!\n"  
    exit 1  
fi
echo "
             Please Select Install
    # ---------------------------------------
                     __               
              _____ |__|____    ____  
             /     \|  \__  \  /  _ \ 
            |  Y Y  \  |/ __ \(  <_> )
            |__|_|  /__(____  /\____/ 
                  \/        \/      

    1 --- Linux + Apache + MySql + PHP5.3 ---
    2 ---     don't install is now    ---
    # ---------------------------------------
"
sleep 0.1
read -p "Please Input 1,2: " Select_Id
if [ $Select_Id == 1 ]; then
    sh $ml/lamp/instal.sh
else
    echo 'no select id,bybe! exit...'
    exit 1
fi
