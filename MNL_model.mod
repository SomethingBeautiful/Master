int I = ...;
int M = ...;
int J = ...;
int r = ...;
float beta = ...;

range I_range = 1..I;
range J_range  = 1..J;
range K_range = 1..(M-J);

tuple potrosac_lok{
float x;
float y;
}

tuple objekat_lok{
float x;
float y;
}

tuple konkurencija_lok{
float x;
float y;
}

potrosac_lok potrosac[I_range] = ...;
objekat_lok  objekat[J_range] = ...;
konkurencija_lok konkurencija[K_range] = ...;

float fi_brojilac[I_range][J_range];
float fi_imenilac [I_range];
float fi[I_range][J_range];


execute{
for(var i in I_range)
for(var j in J_range)
fi_brojilac[i][j] = Math.exp(beta*(Math.abs(potrosac[i].x - objekat[j].x)+Math.abs(potrosac[i].y - objekat[j].y)))
}


execute{
for(var i in I_range)
{
fi_imenilac[i] = 0;
for(var k in K_range)
fi_imenilac[i] = fi_imenilac[i] + Math.exp(beta*(Math.abs(potrosac[i].x-konkurencija[k].x)+Math.abs(potrosac[i].y-konkurencija[k].y)));
}
}

execute{
for(var i in I_range)
for(var j in J_range)
fi[i][j] = fi_brojilac[i][j]/fi_imenilac[i];
}



dvar boolean y[J_range];
dvar float+ x[I_range][J_range];


maximize sum(i in I_range, j in J_range) (fi[i][j]*(y[j]-x[i][j]));
subject to{


ogranicenje1:
sum(j in J_range) y[j] == r;


forall (i in I_range, j in J_range)
  ogranicenje2:
   y[j] + (sum(k in J_range) fi[i][k]*(y[k]-x[i][k])) - 1 <= x[i][j];


forall(i in I_range, j in J_range)
  ogranicenje3:
   x[i][j] <= 0.999900*y[j];


}

 
