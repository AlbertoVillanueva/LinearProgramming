# Heuristics and Optimization - Linear Programming
Linear programming assignment for the Heuristics and Optimization course at Universidad Carlos III.

An extensive report of the assignment in Spanish can be found in the memoria.pdf file.

This assignment consists of 2 parts:
## Linear Programming
The Linear Programming task is to minimize the cost of buying a set of elements between 2 factories taking into consideration its inventory limits where the price of the element and the transportation varies for each factory.

This has been modelled using GLPK, final.mod has the task definition, final.dat has the actual numerical values for the specific problem to solve, and res.txt has the solved values.

## Dynamic Programming
The dynamic programming task consists on the knapsack problem where there is a bag of a certain capacity and a set of items with a given weight, and importance, and the objective is to find the optimal combination of items that fit inside the bag that maximizes the utility.

The problem is solved in the file dinamica.py which takes as an input the path to a file that contains one line for each item, which in itself contains the weight and utility separated by a space.