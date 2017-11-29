% Velocity in (m/s)
vin = 76.38888;
% Air Mass Flow Rate (kg/s)
mdot = 97.4264;
% Fuel + Air Mass Flow Rate (kg/hr)
FAmdot = 5858.451;

%% Assumptions
% Air Density (kg/m^3)
ro = 1.2754;
% Initial Temperature (K)
T0 = 273.15;
% Initial Pressure (kPa)
P0 = 100;
% Compressor Pressure Ratio Per Stage
cpr = 40/14;
% Compressor Efficiency 
ce = 0.97;
% Initial Pressure
P2 = cpr * P0;
% Initial Reduced Pressure 
pr1 = 1;
%%  Initial Values

    pr2s = P2/P0*pr1;
   
    %Find Higher Properties for Interpolation
    rows = find(IdealPropertiesofAir.T>T0,1);
    vars = {'T', 'h'};
    T2 = IdealPropertiesofAir(rows, vars);
    Temp2 = IdealPropertiesofAir.T(rows);
    h2 = IdealPropertiesofAir.h(rows);
    
    %Find Lower Properties for Interpolation
    rows1 = find(IdealPropertiesofAir.T<T0,1,'last');
    vars1 = {'T', 'h'};
    T3 = IdealPropertiesofAir(rows1, vars1);
    Temp3 = IdealPropertiesofAir.T(rows1);
    h3 = IdealPropertiesofAir.h(rows1);
    
    % Solve for unknown h1
    syms h1
    h1 = vpasolve((T0-Temp3)/(h1-h3) == (Temp2-Temp3)/(h2-h3),h1);
  
    %while 1i < 15
    % 1i = 1;
    
        %Find Higher Properties for Interpolation
    rows2 = find(IdealPropertiesofAir.pf>pr2s,1);
    vars2 = {'pf', 'h'};
    T4 = IdealPropertiesofAir(rows2, vars2);
    pf4 = IdealPropertiesofAir.pf(rows2);
    h4 = IdealPropertiesofAir.h(rows2);
    
        %Find Lower Properties for Interpolation
    rows3 = find(IdealPropertiesofAir.pf<pr2s,1,'last');
    vars3 = {'pf', 'h'};
    T5 = IdealPropertiesofAir(rows3, vars3);
    pf5 = IdealPropertiesofAir.pf(rows3);
    h5 = IdealPropertiesofAir.h(rows3);
    
        %solve for unknown h2s
    syms h2s
    h2s = vpasolve((h2s-h5)/(pr2s - pf5)==(h4-h5)/(pf4-pf5),h2s);
    
    % solve for unknown h2w
    
    syms h2w
    h2w = vpasolve(ce == (h2s - h1)/(h2w - h1),h2w);
    
    
            %Find Higher Properties for Interpolation
    rows3 = find(IdealPropertiesofAir.pf>pr2s,1);
    vars3 = {'T', 'pf'};
    T6 = IdealPropertiesofAir(rows3, vars3);
    Tf6 = IdealPropertiesofAir.T(rows3);
    pf6 = IdealPropertiesofAir.[f(rows3);
    
        %Find Lower Properties for Interpolation
    rows4 = find(IdealPropertiesofAir.pf<pr2s,1,'last');
    vars4 = {'T', 'pf'};
    T7 = IdealPropertiesofAir(rows4, vars4);
    Tf7 = IdealPropertiesofAir.T(rows4);
    pf7 = IdealPropertiesofAir.pf(rows4);
    syms T2s
    T2s = vpasolve((T2s-Tf6)/(pr2s-pf7)==(Tf6-Tf6)/(pf6-pf7),T2s);
    
    
        