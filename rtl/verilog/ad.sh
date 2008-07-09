for i in `seq 0 31`
do
       echo "   bufif0 AD_buf$i   ( PCI_AD[$i],  AD_out[$i], AD_en[$i]);"
done

for i in `seq 0 31`
do
       echo "   bufif0 AD64_buf$i   ( PCI_AD64[$i],  AD64_out[$i], AD64_en[$i]);"
done
