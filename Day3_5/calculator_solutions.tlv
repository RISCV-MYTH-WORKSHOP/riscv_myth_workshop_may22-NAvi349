\m4_TLV_version 1d: tl-x.org
\SV
//Calculator labs solutions here

$val1 = $rand1[3:0];
$val2 = $rand2[3:0];

$sum[31:0] = $val1 + $val2;  //00
$diff[31:0] = $val1 - $val2; //01
$prod[31:0] = $val1 * $val2; //10
$quot[31:0] = $val1 / $val2; //11

$out[31:0] = ($op[1:0] == 2'b00) ? $sum :
           ($op[1:0] == 2'b01) ? $diff :
           ($op[1:0] == 2'b10) ? $prod :
           ($op[1:0] == 2'b11) ? $quot : 32'b0;
