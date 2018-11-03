#################################
#	Built using Python 3.7.0	#
#################################

import sys

f = open(sys.argv[1],'r')
conts = f.read()
f.close()
conts = [line.split(' ') for line in conts.split('\n')]
		
C = 3000
T = []
T.append([0 for i in range(C+1)])
for i in range(len(conts)):
	T.append([0,])
	for j in range(C):
		if int(conts[i][1]) > j+1:
			T[i+1].append(T[i][j+1])
		else:
			T[i+1].append(max(T[i][j+1],T[i][j+1-int(conts[i][1])]+int(conts[i][2])))
j = C
ans = []
for i in range(len(conts),0,-1):
	if T[i][j] != T[i-1][j]:
		ans.append(i)
		j -= int(conts[i-1][1])

print("Valor total: {0}".format(T[len(conts)][C]))
print("Contenedores: "+"".join(conts[i-1][0]+' ' for i in ans[::-1]))
