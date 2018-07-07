main{

/*MNL model */
var source_mnl = new IloOplModelSource("MNL_model_tezine.mod");
var def_mnl = new IloOplModelDefinition(source_mnl);
var cplex_mnl = new IloCplex();
var opl_mnl = new IloOplModel(def_mnl, cplex_mnl);


/*MCI model */
var source_mci = new IloOplModelSource("MCI_model_tezine.mod");
var def_mci = new IloOplModelDefinition(source_mci);
var cplex_mci = new IloCplex();
var opl_mci = new IloOplModel(def_mci, cplex_mci);

/*Data file */
var input_file_name = "dat40_15_0.6.dat";
var data = new IloOplDataSource(input_file_name);
var position = input_file_name.indexOf(".dat");
var output_file_name = input_file_name.substring(0,position)+".txt";

var f = new IloOplOutputFile(output_file_name);

/*MNL data object*/
opl_mnl.addDataSource(data);
opl_mnl.generate();

/*MCI data object*/
opl_mci.addDataSource(data);
opl_mci.generate();

if(cplex_mnl.solve())
{
f.writeln("I = " + opl_mnl.I);
f.writeln("J = " + opl_mnl.J);
f.writeln("beta = " + opl_mnl.beta);
f.writeln("r = " + opl_mnl.r);
f.writeln("q = ", opl_mnl.q);
f.writeln("\n\n");

f.writeln("MNL obj = " + cplex_mnl.getObjValue());
f.writeln("Vreme izvrsavanja resavaca (MNL):" + cplex_mnl.getSolvedTime());
f.writeln("y = "+opl_mnl.y);
}

else
{
f.writeln("MNL: " + input_file_name + ": Nema resenja");
}

f.writeln("\n\n")

// ------------------------
if(cplex_mci.solve())
{
f.writeln("MCI obj = " + cplex_mci.getObjValue());
f.writeln("Vreme izvrsavanja resavaca (MCI):" + cplex_mci.getSolvedTime());
f.writeln("y = "+opl_mci.y);
}
else{
f.writeln("MCI: "+input_file_name+": Nema resenja");
}

f.writeln("\n\n");

// -------------------------
data.end();
opl_mnl.end();
cplex_mnl.end();
source_mnl.end();
def_mnl.end();

//----------------------------
opl_mci.end();
cplex_mci.end();
source_mci.end();
def_mci.end();

//-----------------------------
f.close();

}


 
