#! /bin/sh

echo ""
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Close github issue with cli"
echo "Author: LeeLee"
echo "Date: 2023-02-19"
echo "This script is for closing github issue with cli"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo ""


echo "Enter the biggest issue number you want to close" 
read my_var 

my_int_var=$((my_var))

issue=0 

while [ "$issue" -lt "$my_int_var" ]
do 
	gh issue close $issue
	((issue++))
done 

echo "Completely closed github issue."
