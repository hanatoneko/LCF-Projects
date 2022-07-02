function diet(m)
% Minimize the cost of a diet meeting nutritional constraints
%
% An argument is required:
%   'r' to build the problem by rows
%   'c' to build the problem by columns
%   'i' to build the problem by arrays and to require integral food values
%
% Data is read from the file '../../data/diet.dat'

% ---------------------------------------------------------------------------
% File: diet.m
% Version 12.9.0
% ---------------------------------------------------------------------------
% Licensed Materials - Property of IBM
% 5725-A06 5725-A29 5724-Y48 5724-Y49 5724-Y54 5724-Y55 5655-Y21
% Copyright IBM Corporation 2008, 2019. All Rights Reserved.
%
% US Government Users Restricted Rights - Use, duplication or
% disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
% ---------------------------------------------------------------------------

% Input data:
% foodMin[j]      minimum amount of food j to use
% foodMax[j]      maximum amount of food j to use
% foodCost[j]     cost for one unit of food j
% nutrMin[i]      minimum amount of nutrient i
% nutrMax[i]      maximum amount of nutrient i
% nutrPer[i][j]   nutrition amount of nutrient i in food j
%
% Modeling variables:
% Buy[j]          amount of food j to purchase
% Objective:
% minimize sum(j) Buy[j] * foodCost[j]
%
% Constraints:
% forall foods i: nutrMin[i] <= sum(j) Buy[j] * nutrPer[i][j] <= nutrMax[j]

try
   % Read the data
  foodCost= [1.84, 2.19, 1.84, 1.44, 2.29, 0.77, 1.29, 0.6, 0.72];
foodMin=[0, 0, 0, 0, 0, 0, 0, 0, 0];
foodMax=[10, 10, 10, 10, 10, 10, 10, 10, 10];
nutrMin=[2000, 350, 55, 100, 100, 100, 100];
nutrMax=[9999, 375, 9999, 9999, 9999, 9999, 9999];
nutrPer=[[510, 370, 500, 370, 400, 220, 345, 110, 80];...
 [34, 35, 42, 38, 42, 26, 27, 12, 20];...
 [28, 24, 25, 14, 31, 3,  15, 9,  1];...
 [15, 15, 6,  2,  8 , 0,  4 , 10, 2];...
 [6,  10, 2,  0,  15, 15, 0 , 4,  120];...
 [30, 20, 25, 15, 15, 0,  20, 30, 2];...
 [20, 20, 20, 10, 8 , 2,  15, 0,  2]];
size(foodCost)
size(foodMin)
size(foodMax)
size(nutrMin)
size(nutrMax)
size(nutrPer)
   
%    [foodCost, foodMin, foodMax, nutrMin, nutrMax, nutrPer] ...
%       = inputdata('C:\Users\horneh\Google Drive\RPI\Research\toy code\diet.dat');
%    
   nFood = length (foodCost);
   
   % Build model
   cplex = Cplex('diet');
   cplex.Model.sense = 'minimize';
   
   % The variables are the amount of each food to purchase
   
   % Populate by column
   if m == 'c'
      cplex.addRows(nutrMin, [], nutrMax);
      for k = 1:nFood;
         cplex.addCols(foodCost(k), nutrPer(:,k), foodMin(k), foodMax(k));
      end
      
      % Populate by row
   elseif m == 'r'
      cplex.addCols(foodCost, [], foodMin, foodMax);
      
      % We can add rows as a set
      cplex.addRows(nutrMin, nutrPer, nutrMax);
      
      % Or, we can add them one by one
      %     for i = 1:nNutr
      %         cplex.addRows(nutrMin(i), nutrPer(i,:), nutrMax(i));
      %     end
      
      % Populate using arrays
      % Also require foods to be integral quantities
   elseif m == 'i'
      cplex.Model.obj   = foodCost;
      cplex.Model.lb    = foodMin;
      cplex.Model.ub    = foodMax;
      cplex.Model.lhs   = nutrMin;
      cplex.Model.rhs   = nutrMax;
      cplex.Model.A     = nutrPer;
      cplex.Model.ctype = char (ones ([1, nFood]) * ('I'));
   end
   
   % Solve model
   cplex.solve();
   
   % Display solution
   %fprintf ('\nSolution status = %s\n',cplex.Solution.statusstring);
   %fprintf ('Diet Cost: %f\n', cplex.Solution.objval);
   %disp ('Buy Food:');
   disp (cplex.Solution.x(1:nFood)');
catch m
   disp (m.message);
   throw (m);
end
