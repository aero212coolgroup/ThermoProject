% Velocity in (m/s)
vin = 76.38888;
% Air Mass Flow Rate (kg/s)
mdot = 51.6083;
% Fuel + Air Mass Flow Rate (kg/hr)
FAmdot = 3338.4583;

%% Assumptions
% Air Density (kg/m^3)
ro = .6756;
% Initial Temperature (K)
T0 = 255.65;
% Initial Pressure (kPa)
P0 = 49.586;
% Compressor Pressure Ratio Per Stage
cpr = 40/14;
% Compressor Efficiency 
ce = 0.97;
% Initial Pressure/Pressure after first compressor?
P2 = cpr * P0;
% Initial Reduced Pressure 
pr1 = .7937;
%%  Initial Values

    pr2s = P2s/P0*pr1;
   
    %Find Higher Properties for Interpolation
    rows = find(IdealPropertiesofAir.T>T0,1);
    Temp2 = IdealPropertiesofAir.T(rows);
    h2 = IdealPropertiesofAir.h(rows);
    
    %Find Lower Properties for Interpolation
    rows1 = find(IdealPropertiesofAir.T<T0,1,'last');
    Temp3 = IdealPropertiesofAir.T(rows1);
    h3 = IdealPropertiesofAir.h(rows1);
    
    % Solve for unknown h1
    syms h1
    h1 = vpasolve((T0-Temp3)/(h1-h3) == (Temp2-Temp3)/(h2-h3),h1);
  
    %while 1i < 15
    % 1i = 1;
    
        %Find Higher Properties for Interpolation
    rows2 = find(IdealPropertiesofAir.pf>pr2s,1);
    pf4 = IdealPropertiesofAir.pf(rows2);
    h4 = IdealPropertiesofAir.h(rows2);
    
        %Find Lower Properties for Interpolation
    rows3 = find(IdealPropertiesofAir.pf<pr2s,1,'last');
    pf5 = IdealPropertiesofAir.pf(rows3);
    h5 = IdealPropertiesofAir.h(rows3);
    
        %solve for unknown h2s
    syms h2s
    h2s = vpasolve((h2s-h5)/(pr2s - pf5)==(h4-h5)/(pf4-pf5),h2s);
    
    % solve for unknown h2w
    
    syms h2w
    h2w = vpasolve(ce == (h2s - h1)/(h2w - h1),h2w)
    
    
            %Find Higher Properties for Interpolation
    rows3 = find(IdealPropertiesofAir.pf>pr2s,1);
    Tf6 = IdealPropertiesofAir.T(rows3);
    pf6 = IdealPropertiesofAir.pf(rows3);
    
        %Find Lower Properties for Interpolation
    rows4 = find(IdealPropertiesofAir.pf<pr2s,1,'last');
    Tf7 = IdealPropertiesofAir.T(rows4);
    pf7 = IdealPropertiesofAir.pf(rows4);
    syms T2s
    T2s = vpasolve((T2s-Tf6)/(pr2s-pf7)==(Tf6-Tf6)/(pf6-pf7),T2s)
    
    %Interpolate T from h
    
    syms t2 %t2=temperature after 1st compressor
    
     %Find Higher Properties for Interpolation
    rows3 = find(IdealPropertiesofAir.h>h2w,1);
    tgreater = IdealPropertiesofAir.T(rows3);
    hgreater = IdealPropertiesofAir.h(rows3);
    
        %Find Lower Properties for Interpolation
    rows4 = find(IdealPropertiesofAir.h<h2w,1,'last');
    tlesser = IdealPropertiesofAir.T(rows4);
    hlesser = IdealPropertiesofAir.h(rows4);
    
    t2 = vpasolve((tgreater-tlesser)/(hgreater-hlesser) == (t2-tlesser)/(h2w-hlesser),t2)
    h2w = vpasolve(ce == (h2s - h1)/(h2w - h1),h2w);
    
    %% Solve for Temperature after stage 1 of compressor
    
    
    %% Solve for specific entropy after stage 1 of compressor
            %Find Higher Properties for Interpolation
    rows4 = find(IdealPropertiesofAir.h>h2w,1);

    h6 = IdealPropertiesofAir.h(rows4);
    s6 = IdealPropertiesofAir.s(rows4);
    
        %Find Lower Properties for Interpolation
    rows5 = find(IdealPropertiesofAir.h<h2w,1,'last');

    h7 = IdealPropertiesofAir.h(rows5);
    s7 = IdealPropertiesofAir.s(rows5);
    
        syms ent
    ent = vpasolve((h2w-h7)/(ent - s7)==(h6-h7)/(s6-s7),ent);
    
    %% Solve for specific volume after stage 1 of compressor
    %% Solve for pressure after first stage of compressor
    %p2 = P0 * Temperature / T0
    %% Put in loop to iterate 14 times
    %%
    
        