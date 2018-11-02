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

/*Parametros*/

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

/*Variables de decision*/

/*Relacion de contenedores en vagones*/
var CV {c in CONTENEDORES_TODOS, v in VAGONES_TODOS}, binary;
/*Relacion de contenedores en rutas*/
var CR {c in CONTENEDORES_TODOS, r in RUTAS}, binary;
/*Relacion de vagones en rutas*/
var VR {v in VAGONES_TODOS, r in RUTAS}, binary;
/*Relacion de locomotoras en rutas*/
var LR {l in LOCOMOTORAS, r in RUTAS}, binary;



minimize coste: sum{r in RUTAS}(sum{ct in CONTENEDORES_TIPOS,c in CONTENEDORES[ct]}CR[c,r]*Traslado[ct,r])*Distancia[r];

s.t. SatisfaceMercancias {r in RUTAS}: sum{ct in CONTENEDORES_TIPOS}(sum{c in CONTENEDORES[ct]}CR[c,r])*LimiteContenedor[ct] >= Mercancias[r];
s.t. VagonesCumplenLimitesContenedores {vt in VAGONES_TIPOS, v in VAGONES[vt], ct in CONTENEDORES_TIPOS}: sum{c in CONTENEDORES[ct]}CV[c,v] <= LimiteVagon[vt,ct];
s.t. EvitaUsoInnecesario {r in RUTAS}: -1+sum{c in CONTENEDORES_TODOS}CR[c,r]>=sum{v in VAGONES_TODOS}VR[v,r];

s.t. RutaCumpleLimitesContenedores {r in RUTAS,ct in CONTENEDORES_TIPOS}: sum{c in CONTENEDORES[ct]}CR[c,r]<=sum{vt in VAGONES_TIPOS}(sum{v in VAGONES[vt]}VR[v,r])*LimiteVagon[vt,ct];
s.t. CoherenciaTotalidadContenedores {c in CONTENEDORES_TODOS}: sum{r in RUTAS} CR[c,r] = sum{v in VAGONES_TODOS}CV[c,v];
s.t. Coherencia_CV_CR{r in RUTAS, c in CONTENEDORES_TODOS, v in VAGONES_TODOS}:CR[c,r]+CV[c,v]-1<=VR[v,r];

s.t. alMenosUnaLocomotoraPorRuta {r in RUTAS}: sum{l in LOCOMOTORAS}LR[l,r] >= 1;

s.t. unaRutaPorContenedor {c in CONTENEDORES_TODOS}: sum{r in RUTAS}CR[c,r] <= 1;
s.t. unaRutaPorVagon {v in VAGONES_TODOS}: sum{r in RUTAS}VR[v,r] <= 1;
s.t. unaRutaPorLocomotora {l in LOCOMOTORAS}: sum{r in RUTAS} LR[l,r]<= 1;
s.t. unVagonPorContenedor {c in CONTENEDORES_TODOS}: sum{v in VAGONES_TODOS}CV[c,v] <= 1;

solve;


printf "Disposición de contenedores en vagones:\n" > "res.txt";
for{c in CONTENEDORES_TODOS}
{
	for{v in VAGONES_TODOS}
	{
		printf if CV[c,v] then '\t' else '' >> "res.txt";
		printf if CV[c,v] then c else '' >> "res.txt";
		printf if CV[c,v] then ' --> ' else '' >> "res.txt";
		printf if CV[c,v] then v else '' >> "res.txt";
		printf if CV[c,v] then "\n" else "" >> "res.txt";
	}
}

printf "Disposición de vagones en rutas:\n" >> "res.txt";
for{v in VAGONES_TODOS}
{
	for{r in RUTAS}
	{
		printf if VR[v,r] then '\t' else '' >> "res.txt";
		printf if VR[v,r] then v else '' >> "res.txt";
		printf if VR[v,r] then ' --> ' else '' >> "res.txt";
		printf if VR[v,r] then r else '' >> "res.txt";
		printf if VR[v,r] then "\n" else "" >> "res.txt";
	}
}

printf "Disposición de locomotoras en rutas:\n" >> "res.txt";
for{l in LOCOMOTORAS}
{
	for{r in RUTAS}
	{
		printf if LR[l,r] then '\t' else '' >> "res.txt";
		printf if LR[l,r] then l else '' >> "res.txt";
		printf if LR[l,r] then ' --> ' else '' >> "res.txt";
		printf if LR[l,r] then r else '' >> "res.txt";
		printf if LR[l,r] then "\n" else "" >> "res.txt";
	}
}

printf "\nCoste Minimizado: %i\n", coste >> "res.txt";









