objave=[-0.567901;
-0.452675;
-0.292181;
-0.329218;
-0.18107;
-0.390947;
-0.349794;
-0.63786;
-0.522634;
-0.765432;
-0.395062;
-0.148148;
-0.341564;
-0.1893;
-0.403292;
0.028807;
-0.17284;
-0.300412;
-0.432099;
-0.012346;
-0.27572;
-0.065844;
0;
0.00823;
-0.028807;
-0.36214;
-0.395062;
-0.547325;
-0.160494;
-0.024691;
-0.024691;
-0.123457;
-0.049383;
-0.004115;
-0.065844;
-0.012346;
-0.078189;
0.016461;
0.024691;
-0.197531];

dupave=[0.855967
0.817558
0.76406
0.776406
0.727023
0.796982
0.783265
0.879287
0.840878
0.921811
0.798354
0.716049
0.780521
0.729767
0.801097
0.657064
0.72428
0.766804
0.8107
0.670782
0.758573
0.688615
0.666667
0.663923
0.676269
0.78738
0.798354
0.849108
0.720165
0.674897
0.674897
0.707819
0.683128
0.668038
0.688615
0.670782
0.69273
0.66118
0.658436
0.73251];

rejave=[2.855967
2.817558
2.76406
2.776406
2.727023
2.796982
2.783265
2.879287
2.840878
2.921811
2.798354
2.716049
2.780521
2.729767
2.801097
2.657064
2.72428
2.766804
2.8107
2.670782
2.758573
2.688615
2.666667
2.663923
2.676269
2.78738
2.798354
2.849108
2.720165
2.674897
2.674897
2.707819
2.683128
2.668038
2.688615
2.670782
2.69273
2.66118
2.658436
2.73251];

objsd=[2.232653
2.180904
2.034309
2.151854
2.025964
2.132809
2.103047
2.182723
2.133548
2.101441
2.173208
2.116134
2.203877
2.051493
2.078617
1.985661
2.008301
2.085142
2.134518
2.014674
2.078666
2.198538
2.007541
1.99517
2.069
2.135002
2.193967
2.163831
2.068943
2.186232
2.117287
2.086353
2.065621
2.008563
2.198538
2.008529
2.037608
1.936422
2.066064
2.03255];

dupsd=[0.830296
0.83923
0.700685
0.732445
0.725021
0.722436
0.71652
0.792632
0.757329
0.747287
0.733198
0.743305
0.792204
0.724155
0.770471
0.667398
0.706699
0.713254
0.779085
0.666081
0.712438
0.72278
0.66918
0.667805
0.687006
0.75415
0.731322
0.77513
0.742095
0.718621
0.695305
0.743807
0.741066
0.66678
0.72278
0.664016
0.723593
0.702538
0.699245
0.71947];

rejsd=[0.964961
0.941077
0.943033
0.973942
0.930761
0.970692
0.962023
0.961753
0.957577
0.949655
0.981531
0.95663
0.969935
0.940368
0.931853
0.937809
0.931426
0.956726
0.949173
0.94853
0.95468
0.994708
0.944911
0.941023
0.960483
0.95937
0.989893
0.961771
0.939746
0.99169
0.974926
0.945467
0.938934
0.946121
0.994708
0.94708
0.93554
0.90732
0.954997
0.935296];



x=vertcat(5*ones(10,1),10*ones(10,1),20*ones(10,1),30*ones(10,1));

% scatter(x,objave)
% xlabel('Samples')
% ylabel('Ave. Objective Value')
% title('Objective Value')
% xlim([0 35])


scatter(x,objsd,'o')
hold on
scatter(x,dupsd,'.')
hold on
scatter(x,rejsd,'+')
xlabel('Samples')
ylabel('Standard Deviation')
title('Standard Deviation')
legend('Obj. Val.','Duplicates','Rejections','Location','best')
%legend('Location','best')
xlim([0 35])

% scatter(x,dupave)
% xlabel('Samples')
% ylabel('Ave. Duplicates')
% title('Duplicates')
% xlim([0 35])

% scatter(x,rejave)
% xlabel('Samples')
% ylabel('Ave. Rejections')
% title('Rejected Requests')
% xlim([0 35])


