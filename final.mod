/* Productos a comprar en la fabrica 1*/
set PRODUCTOS;

/*Tipos de contenedores*/
set CONTENEDORES_TIPOS;
/*Todos los contenedores*/
set CONTENEDORES_TODOS;
/*Contenedores ordenados por tipos*/
set CONTENEDORES {CONTENEDORES_TIPOS} within CONTENEDORES_TODOS;
/*Tipos de vagones*/
set VAGONES_TIPOS;
/*Todos los vagones*/
set VAGONES_TODOS;
/*Vagones ordenados por tipos*/
set VAGONES {VAGONES_TIPOS} within VAGONES_TODOS;
/*Locomotoras*/
set LOCOMOTORAS;
/*Rutas*/
set RUTAS;

/* parametros */

/*Necesidad de articulos que se tienen que satisfacer*/
param Necesidad {p in PRODUCTOS};
/*Limite de productos que puede satisfacer cada fabrica*/
param StockPrimera {p in PRODUCTOS};
param StockSegunda {p in PRODUCTOS};
/*Coste de comprar un producto en una fabrica(con precio de compra y traslado incluido)*/
param CostePrimera {p in PRODUCTOS};
param CosteSegunda {p in PRODUCTOS};

/*Distancia que tiene que se tiene que recorrer en cada ruta*/
param Distancia {r in RUTAS};
/*Mercancias que se tienen que mover en cada ruta*/
param Mercancias {r in RUTAS};
/*Coste de trasladar un contenedor 1km en una ruta*/
param Traslado {c in CONTENEDORES_TIPOS, r in RUTAS};
/*Numero de contenedores tipo c que puede transportar un vagon de tipo v*/
param LimiteVagon {v in VAGONES_TIPOS, c in CONTENEDORES_TIPOS};
/*Limite de cargamento que puede mover cada contenedor*/
param LimiteContenedor {c in CONTENEDORES_TIPOS};

/* variables de decision */

/*Unidades a comprar en la primera fabrica*/
var units {p in PRODUCTOS} >= 0, integer;

/*Relacion de contenedores en vagones*/
var CV {c in CONTENEDORES_TODOS, v in VAGONES_TODOS}, binary;
/*Relacion de contenedores en rutas*/
var CR {c in CONTENEDORES_TODOS, r in RUTAS}, binary;
/*Relacion de vagones en rutas*/
var VR {v in VAGONES_TODOS, r in RUTAS}, binary;
/*Relacion de locomotoras en rutas*/
var LR {l in LOCOMOTORAS, r in RUTAS}, binary;

/* funcion objetivo */
minimize coste: 
	/*minimizar coste de compra*/
	sum{p in PRODUCTOS} (units[p]*CostePrimera[p] + (Necesidad[p] - units[p])*CosteSegunda[p]) + 
	/*minimizar coste de traslado*/
	sum{r in RUTAS}(sum{ct in CONTENEDORES_TIPOS,c in CONTENEDORES[ct]}CR[c,r]*Traslado[ct,r])*Distancia[r];

/* restricciones compra*/

s.t. prioridadTiempo: -1 + sum{p in PRODUCTOS} units[p] >= sum{p in PRODUCTOS} (Necesidad[p] - units[p]);

s.t. monopolio_1a: 1.1*sum{p in PRODUCTOS} units[p]*CostePrimera[p] >= sum{p in PRODUCTOS} (Necesidad[p] - units[p])*CosteSegunda[p];
s.t. monopolio_2a: sum{p in PRODUCTOS} units[p]*CostePrimera[p] <= 1.1*sum{p in PRODUCTOS} (Necesidad[p] - units[p])*CosteSegunda[p];

s.t. SeCumpleStockPrimera {p in PRODUCTOS}: units[p] <= StockPrimera[p];
s.t. SeCumpleStockSegunda {p in PRODUCTOS}: Necesidad[p]-units[p] <= StockSegunda[p];

/* restricciones transporte */

s.t. SatisfaceMercancias {r in RUTAS}: sum{ct in CONTENEDORES_TIPOS}(sum{c in CONTENEDORES[ct]}CR[c,r])*LimiteContenedor[ct] >= Mercancias[r];
s.t. RutaCumpleLimitesContenedores {r in RUTAS,ct in CONTENEDORES_TIPOS}: sum{c in CONTENEDORES[ct]}CR[c,r]<=sum{vt in VAGONES_TIPOS}(sum{v in VAGONES[vt]}VR[v,r])*LimiteVagon[vt,ct];
s.t. EvitaUsoInnecesario {r in RUTAS}: -1+sum{c in CONTENEDORES_TODOS}CR[c,r]>=sum{v in VAGONES_TODOS}VR[v,r];


s.t. VagonesCumplenLimitesContenedores {vt in VAGONES_TIPOS, v in VAGONES[vt], ct in CONTENEDORES_TIPOS}: sum{c in CONTENEDORES[ct]}CV[c,v] <= LimiteVagon[vt,ct];
s.t. CoherenciaTotalidadContenedores {c in CONTENEDORES_TODOS}: sum{r in RUTAS} CR[c,r] = sum{v in VAGONES_TODOS}CV[c,v];
s.t. Coherencia_CV_CR{r in RUTAS, c in CONTENEDORES_TODOS, v in VAGONES_TODOS}:CR[c,r]+CV[c,v]-1<=VR[v,r];

s.t. alMenosUnaLocomotoraPorRuta {r in RUTAS}: sum{l in LOCOMOTORAS}LR[l,r] >= 1;

s.t. unaRutaPorContenedor {c in CONTENEDORES_TODOS}: sum{r in RUTAS}CR[c,r] <= 1;
s.t. unaRutaPorVagon {v in VAGONES_TODOS}: sum{r in RUTAS}VR[v,r] <= 1;
s.t. unaRutaPorLocomotora {l in LOCOMOTORAS}: sum{r in RUTAS} LR[l,r]<= 1;
s.t. unVagonPorContenedor {c in CONTENEDORES_TODOS}: sum{v in VAGONES_TODOS}CV[c,v] <= 1;

solve;

printf "Productos comprados en la Fabrica 1:\n" > "res.txt";
printf{p in PRODUCTOS}: "\t%s: %i\n", p, units[p] >> "res.txt";

printf "\nProductos comprados en la Fabrica 2:\n" >> "res.txt";
printf{p in PRODUCTOS}: "\t%s: %i\n", p, Necesidad[p]-units[p] >> "res.txt";

printf "\nDisposición de contenedores en vagones:\n" >> "res.txt";
for{c in CONTENEDORES_TODOS}
{
	printf{v in VAGONES_TODOS: CV[c,v]}: "\t%s --> %s\n",c,v >> "res.txt";
	printf {1..1: sum{v in VAGONES_TODOS} CV[c,v] == 0}: "\t%s --> No Asignado\n",c >> "res.txt";
}

printf "\nDisposición de contenedores en rutas:\n" >> "res.txt";
for{c in CONTENEDORES_TODOS}
{
	printf{r in RUTAS: CR[c,r]}: "\t%s --> %s\n",c,r >> "res.txt";	
	printf {1..1: sum{r in RUTAS} CR[c,r] == 0}: "\t%s --> No Asignado\n",c >> "res.txt";
}

printf "\nDisposición de vagones en rutas:\n" >> "res.txt";
for{v in VAGONES_TODOS}
{
	printf {r in RUTAS: VR[v,r]}:"\t%s --> %s\n",v,r >> "res.txt";
	printf {1..1: sum{r in RUTAS} VR[v,r] == 0}: "\t%s --> No Asignado\n",v >> "res.txt";
}

printf "\nDisposición de locomotoras en rutas:\n" >> "res.txt";
for{l in LOCOMOTORAS}
{
	printf {r in RUTAS: LR[l,r]}: "\t%s --> %s\n",l,r >> "res.txt";
	printf {1..1: sum{r in RUTAS} LR[l,r] == 0}: "\t%s --> No Asignado\n",l >> "res.txt";
}

printf "\nCoste Minimizado de la compra: %i\n", sum{p in PRODUCTOS} (units[p]*CostePrimera[p] + (Necesidad[p] - units[p])*CosteSegunda[p]) >> "res.txt";
printf "Coste Minimizado del traslado: %i\n", sum{r in RUTAS}(sum{ct in CONTENEDORES_TIPOS,c in CONTENEDORES[ct]}CR[c,r]*Traslado[ct,r])*Distancia[r] >> "res.txt";
printf "Coste Minimizado total       : %i\n", sum{p in PRODUCTOS} (units[p]*CostePrimera[p] + (Necesidad[p] - units[p])*CosteSegunda[p]) + sum{r in RUTAS}(sum{ct in CONTENEDORES_TIPOS,c in CONTENEDORES[ct]}CR[c,r]*Traslado[ct,r])*Distancia[r]>> "res.txt";

end;
