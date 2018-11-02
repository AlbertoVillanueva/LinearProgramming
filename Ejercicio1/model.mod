/* Productos a comprar en la fabrica 1*/
set PRODUCTOS;

/* parametros */

param Necesidad {p in PRODUCTOS};
param StockPrimera {p in PRODUCTOS};
param StockSegunda {p in PRODUCTOS};
param CostePrimera {p in PRODUCTOS};
param CosteSegunda {p in PRODUCTOS};

/* variables de decision */
var units {p in PRODUCTOS} >= 0, integer;

/* funcion objetivo */
minimize coste: sum{p in PRODUCTOS} (units[p]*CostePrimera[p] + (Necesidad[p] - units[p])*CosteSegunda[p]);

/* restricciones */
s.t. prioridadTiempo: -1 + sum{p in PRODUCTOS} units[p] >= sum{p in PRODUCTOS} (Necesidad[p] - units[p]);

s.t. monopolio_1a: 1.1*sum{p in PRODUCTOS} units[p]*CostePrimera[p] >= sum{p in PRODUCTOS} (Necesidad[p] - units[p])*CosteSegunda[p];
s.t. monopolio_2a: sum{p in PRODUCTOS} units[p]*CostePrimera[p] <= 1.1*sum{p in PRODUCTOS} (Necesidad[p] - units[p])*CosteSegunda[p];

s.t. SeCumpleStockPrimera {p in PRODUCTOS}: units[p] <= StockPrimera[p];
s.t. SeCumpleStockSegunda {p in PRODUCTOS}: Necesidad[p]-units[p] <= StockSegunda[p];
end;
