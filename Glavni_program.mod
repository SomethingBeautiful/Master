main{


//zajednicki podaci: parametri za ulazne podatke i fajl za izlaz
var I_niz = new Array(20, 40);
var J_niz = new Array(5, 10, 15);
var beta_niz = new Array(0.2, 0.4, 0.5);

var f = new IloOplOutputFile("rezultati.txt");



//prvi model - bez tezina 

f.writeln("");
f.writeln("===================================================================================");
f.writeln("                               BEZ TEZINA                   ");
f.writeln("===================================================================================");

// I MNL model
var source_mnl = new IloOplModelSource("MNL_model.mod");
var def_mnl = new IloOplModelDefinition(source_mnl);
var cplex_mnl = new IloCplex();

// I MCI model
var source_mci = new IloOplModelSource("MCI_model.mod");
var def_mci = new IloOplModelDefinition(source_mci);
var cplex_mci = new IloCplex();

for(var i_ind = 0; i_ind < I_niz.length; i_ind++)
{
for(var j_ind = 0; j_ind < J_niz.length; j_ind++)
{
for(var beta_ind = 0; beta_ind < beta_niz.length; beta_ind++)
{
var opl_mnl = new IloOplModel(def_mnl, cplex_mnl);
var opl_mci = new IloOplModel(def_mci, cplex_mci);

var fajl_sa_ulaznim_podacima = "dat" + I_niz[i_ind] + "_" + J_niz[j_ind] + "_" + beta_niz[beta_ind] + ".dat";
var data = new IloOplDataSource(fajl_sa_ulaznim_podacima);

opl_mnl.addDataSource(data);
opl_mci.addDataSource(data);

opl_mnl.generate();
opl_mci.generate();

if(cplex_mnl.solve())
{
f.writeln("I = " + opl_mnl.I + ", J = " + opl_mnl.J + ", beta = " + opl_mnl.beta + ", r = " + opl_mnl.r);
f.writeln("\n")


f.writeln("Status resenja: " + cplex_mnl.getCplexStatus());


var opt_lokacije_koordinate = "";
var opt_lokacije_indeksi = "";

for(var j in opl_mnl.y)
{
if(opl_mnl.y[j] > 0){
opt_lokacije_koordinate = opt_lokacije_koordinate + opl_mnl.objekat[j];
opt_lokacije_indeksi = opt_lokacije_indeksi + j + " ";
}
}
f.writeln("Optimalne MNL lokacije - indeksi: " + opt_lokacije_indeksi);
f.writeln("Optimalne MNL lokacije - koordinate: " + opt_lokacije_koordinate);
f.writeln("MNL funkcija cilja za optimalno MNL resenje: " + cplex_mnl.getObjValue());

var suma = 0;
for(var i = 1; i <= opl_mci.I; i++)
{
var brojilac = 0;
for(var j = 1; j <= opl_mci.J; j++)
brojilac = brojilac + opl_mnl.y[j]*Math.pow(Math.abs(opl_mci.potrosac[i].x - opl_mci.objekat[j].x) + Math.abs(opl_mci.potrosac[i].y - opl_mci.objekat[j].y), opl_mci.beta);

var imenilac_konkurencija = 0;
for(var k = 1; k <= 7; k++)
imenilac_konkurencija = imenilac_konkurencija + Math.pow(Math.abs(opl_mci.potrosac[i].x - opl_mci.konkurencija[k].x) + Math.abs(opl_mci.potrosac[i].y - opl_mci.konkurencija[k].y), opl_mci.beta);

suma = suma + brojilac/(imenilac_konkurencija + brojilac);
}

f.writeln("MCI funckija cilja za optimalno MNL resenje: " + suma);
f.writeln("MCI/MNL za MNL opt resenje: " + suma/cplex_mnl.getObjValue());
f.writeln("Vreme izvrsavanja resavaca (MNL): " + cplex_mnl.getSolvedTime());
f.writeln("\n");

}

else {f.writeln("MNL: " + fajl_sa_ulaznim_podacima + " nema resenje.");}

if(cplex_mci.solve())
{

f.writeln("Status resenja: " + cplex_mci.getCplexStatus());

var opt_lokacije_koordinate = "";
var opt_lokacije_indeksi = "";

for(var j in opl_mci.y)
{
if(opl_mci.y[j] > 0){
opt_lokacije_koordinate = opt_lokacije_koordinate + opl_mci.objekat[j];
opt_lokacije_indeksi = opt_lokacije_indeksi + j + " ";
}
}
f.writeln("Optimalne MCI lokacije - indeksi: " + opt_lokacije_indeksi);
f.writeln("Optimalne MCI lokacije - koordinate: " + opt_lokacije_koordinate);
f.writeln("MCI funkcija cilja za optimalno MCI resenje: " + cplex_mci.getObjValue());

var suma = 0;
for(var i = 1; i <= opl_mnl.I; i++)
{
var brojilac = 0;
for(var j = 1; j <= opl_mnl.J; j++)
brojilac = brojilac + opl_mci.y[j]*Math.exp(opl_mnl.beta*(Math.abs(opl_mnl.potrosac[i].x - opl_mnl.objekat[j].x) + Math.abs(opl_mnl.potrosac[i].y - opl_mnl.objekat[j].y)));

var imenilac_konkurencija = 0;
for(var k = 1; k <= 7; k++)
imenilac_konkurencija = imenilac_konkurencija + Math.exp(opl_mnl.beta*(Math.abs(opl_mnl.potrosac[i].x - opl_mnl.konkurencija[k].x) + Math.abs(opl_mnl.potrosac[i].y - opl_mnl.konkurencija[k].y)));

suma = suma + brojilac/(imenilac_konkurencija + brojilac);
}

f.writeln("MNL funckija cilja za optimalno MCI resenje: " + suma);
f.writeln("MNL/MCI za MCI opt resenje: " + suma/cplex_mci.getObjValue());
f.writeln("Vreme izvrsavanja resavaca (MCI): " + cplex_mci.getSolvedTime());
f.writeln();
f.writeln("---------------------------------------------------------------------");

}


else {f.writeln("MCI: " + fajl_sa_ulaznim_podacima + " nema resenje.");}

data.end();
opl_mnl.end();
opl_mci.end();

}
}
}


cplex_mnl.end();
def_mnl.end();
source_mnl.end(); 

cplex_mci.end();
def_mci.end();
source_mci.end();



// drugi model - sa tezinama

f.writeln("");
f.writeln("");
f.writeln("===================================================================================");
f.writeln("                               SA TEZINAMA                    ");
f.writeln("===================================================================================");

// II MNL model
var source_mnl = new IloOplModelSource("T_MNL_model.mod");
var def_mnl = new IloOplModelDefinition(source_mnl);
var cplex_mnl = new IloCplex();

// II MCI model
var source_mci = new IloOplModelSource("T_MCI_model.mod");
var def_mci = new IloOplModelDefinition(source_mci);
var cplex_mci = new IloCplex();

for(var i_ind = 0; i_ind < I_niz.length; i_ind++)
{
for(var j_ind = 0; j_ind < J_niz.length; j_ind++)
{
for(var beta_ind = 0; beta_ind < beta_niz.length; beta_ind++)
{
var opl_mnl = new IloOplModel(def_mnl, cplex_mnl);
var opl_mci = new IloOplModel(def_mci, cplex_mci);

var fajl_sa_ulaznim_podacima = "dat" + I_niz[i_ind] + "_" + J_niz[j_ind] + "_" + beta_niz[beta_ind] + "_t.dat";
var data = new IloOplDataSource(fajl_sa_ulaznim_podacima);

opl_mnl.addDataSource(data);
opl_mci.addDataSource(data);

opl_mnl.generate();
opl_mci.generate();

if(cplex_mnl.solve())
{

f.writeln("I = " + opl_mnl.I + ", J = " + opl_mnl.J + ", beta = " + opl_mnl.beta + ", r = " + opl_mnl.r);
f.writeln("\n")

f.writeln("Status resenja: " + cplex_mnl.getCplexStatus());


var opt_lokacije_koordinate = "";
var opt_lokacije_indeksi = "";

for(var j in opl_mnl.y)
{
if(opl_mnl.y[j] > 0){
opt_lokacije_koordinate = opt_lokacije_koordinate + opl_mnl.objekat[j];
opt_lokacije_indeksi = opt_lokacije_indeksi + j + " ";
}
}
f.writeln("Optimalne MNL lokacije - indeksi: " + opt_lokacije_indeksi);
f.writeln("Optimalne MNL lokacije - koordinate: " + opt_lokacije_koordinate);
f.writeln("MNL funkcija cilja za optimalno MNL resenje: " + cplex_mnl.getObjValue());

var suma = 0;
for(var i = 1; i <= opl_mci.I; i++)
{
var brojilac = 0;
for(var j = 1; j <= opl_mci.J; j++)
brojilac = brojilac + opl_mnl.y[j]*Math.pow(Math.abs(opl_mci.potrosac[i].x - opl_mci.objekat[j].x) + Math.abs(opl_mci.potrosac[i].y - opl_mci.objekat[j].y), opl_mci.beta);

var imenilac_konkurencija = 0;
for(var k = 1; k <= 7; k++)
imenilac_konkurencija = imenilac_konkurencija + Math.pow(Math.abs(opl_mci.potrosac[i].x - opl_mci.konkurencija[k].x) + Math.abs(opl_mci.potrosac[i].y - opl_mci.konkurencija[k].y), opl_mci.beta);

suma = suma + opl_mci.q[i]*brojilac/(imenilac_konkurencija + brojilac);
}

f.writeln("MCI funckija cilja za optimalno MNL resenje: " + suma);
f.writeln("MCI/MNL za MNL opt resenje: " + suma/cplex_mnl.getObjValue());
f.writeln("Vreme izvrsavanja resavaca (MNL): " + cplex_mnl.getSolvedTime());
f.writeln("\n");

}

else {f.writeln("MNL: " + fajl_sa_ulaznim_podacima + " nema resenje.");}

if(cplex_mci.solve())
{

f.writeln("Status resenja: " + cplex_mci.getCplexStatus());

var opt_lokacije_koordinate = "";
var opt_lokacije_indeksi = "";

for(var j in opl_mci.y)
{
if(opl_mci.y[j] > 0){
opt_lokacije_koordinate = opt_lokacije_koordinate + opl_mci.objekat[j];
opt_lokacije_indeksi = opt_lokacije_indeksi + j + " ";
}
}
f.writeln("Optimalne MCI lokacije - indeksi: " + opt_lokacije_indeksi);
f.writeln("Optimalne MCI lokacije - koordinate: " + opt_lokacije_koordinate);
f.writeln("MCI funkcija cilja za optimalno MCI resenje: " + cplex_mci.getObjValue());

var suma = 0;
for(var i = 1; i <= opl_mnl.I; i++)
{
var brojilac = 0;
for(var j = 1; j <= opl_mnl.J; j++)
brojilac = brojilac + opl_mci.y[j]*Math.exp(opl_mnl.beta*(Math.abs(opl_mnl.potrosac[i].x - opl_mnl.objekat[j].x) + Math.abs(opl_mnl.potrosac[i].y - opl_mnl.objekat[j].y)));

var imenilac_konkurencija = 0;
for(var k = 1; k <= 7; k++)
imenilac_konkurencija = imenilac_konkurencija + Math.exp(opl_mnl.beta*(Math.abs(opl_mnl.potrosac[i].x - opl_mnl.konkurencija[k].x) + Math.abs(opl_mnl.potrosac[i].y - opl_mnl.konkurencija[k].y)));

suma = suma + opl_mnl.q[i]*brojilac/(imenilac_konkurencija + brojilac);
}

f.writeln("MNL funckija cilja za optimalno MCI resenje: " + suma);
f.writeln("MNL/MCI za MCI opt resenje: " + suma/cplex_mci.getObjValue());
f.writeln("Vreme izvrsavanja resavaca (MCI): " + cplex_mci.getSolvedTime());
f.writeln();
f.writeln("---------------------------------------------------------------------");

}


else {f.writeln("MCI: " + fajl_sa_ulaznim_podacima + " nema resenje.");}

data.end();
opl_mnl.end();
opl_mci.end();

}
}
}


cplex_mnl.end();
def_mnl.end();
source_mnl.end(); 

cplex_mci.end();
def_mci.end();
source_mci.end();


f.close();



}

