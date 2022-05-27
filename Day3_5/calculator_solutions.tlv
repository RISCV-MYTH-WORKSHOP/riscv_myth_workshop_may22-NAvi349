\m4_TLV_version 1d: tl-x.org
\SV
//Calculator labs solutions here

\TLV

   //$val1[31:0] = $rand1[3:0];
   $val2[31:0] = $rand2[3:0];
   
   //$num[31:0] = $reset ? 0 : (>>1$num + 1);
   
   $sum[31:0] = $out + $val2;  //00
   $diff[31:0] = $out - $val2; //01
   $prod[31:0] = $out * $val2; //10
   $quot[31:0] = $out / $val2; //11
   
   $tout[31:0] = ($op[1:0] == 2'b00) ? $sum :
               ($op[1:0] == 2'b01) ? $diff :
               ($op[1:0] == 2'b10) ? $prod :
               ($op[1:0] == 2'b11) ? $quot : 32'b0;
   
   $out[31:0] = $reset ? 0 : >>1$tout;
   


   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
