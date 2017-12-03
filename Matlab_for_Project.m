% Values for table: T h u s pf vf
% Velocity in (m/s)
vin = 76.38888;
% Air Mass Flow Rate (kg/s)
mdot = 51.6083;
% Fuel + Air Mass Flow Rate (kg/hr)
FAmdot = 3338.4583;

%% Assumptions
% Air Density (kg/m^3)
ro = 0.6756;
% Initial Temperature (K)
T0 = 255.65;
% Initial Pressure (kPa)
P0 = 49.586;
% Compressor Pressure Ratio Per Stage
cpr = 40/14;
% Compressor Efficiency 
ce = 0.97;
% Pressure after first compressor
P2 = cpr * P0;
% Initial Reduced Pressure 
pr1 = .7937;
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
    
    % Solve for unknown h1 (Initial Enthalpy)
    syms h1
    h1 = vpasolve((T0-Temp3)/(h1-h3) == (Temp2-Temp3)/(h2-h3),h1);
  
    %while 1i < 15
    % 1i = 1;
    %%
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
    
        %solve for unknown h2s (Ideal enthalpy after compression)
    syms h2s
    h2s = vpasolve((h2s-h5)/(pr2s - pf5)==(h4-h5)/(pf4-pf5),h2s);
    
    % solve for unknown h2w (actual h2 after compression)
    
    syms h2w
    h2w = vpasolve(ce == (h2s - h1)/(h2w - h1),h2w);
    
    %% Solve for Temperature after stage 1 of compressor
    %% Solve for specific entropy after stage 1 of compressor
    %% Solve for specific colume after stage 1 of compressor
    %% Solve for pressure after first stage of compressor
    %% Put in lood to iterate 14 times
    %%
    
        