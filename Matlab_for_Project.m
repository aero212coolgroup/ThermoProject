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
%  Ideal pressure after first compressor
P2s = cpr * P0;
% Initial Reduced Pressure 
pr1 = .7937;
% Critical Temp of air
Tc = 132.65;
% Critical Pressure of Air (Pa)
Pc = 3774356;
% R constant
R = 8.314;
%%  Initial Values

    pr2s = P2s/P0*pr1;
   
    %Find Higher Properties for Interpolation
    rows = find(IdealPropertiesofAir.T>T0,1);
    THigh = IdealPropertiesofAir.T(rows);
    hHigh = IdealPropertiesofAir.h(rows);
    
    %Find Lower Properties for Interpolation
    rows = find(IdealPropertiesofAir.T<T0,1,'last');
    TLow = IdealPropertiesofAir.T(rows);
    hLow = IdealPropertiesofAir.h(rows);
    
    % Solve for unknown h1 (Initial Enthalpy)
    syms h1
    h1 = vpasolve((T0-TLow)/(h1-hLow) == (THigh-TLow)/(hHigh-hLow),h1);
  
    %while 1i < 15
    % 1i = 1;
    %%
        %Find Higher Properties for Interpolation
    rows = find(IdealPropertiesofAir.pf>pr2s,1);
    prHigh = IdealPropertiesofAir.pf(rows);
    hHigh = IdealPropertiesofAir.h(rows);
    
        %Find Lower Properties for Interpolation
    rows = find(IdealPropertiesofAir.pf<pr2s,1,'last');
    prLow = IdealPropertiesofAir.pf(rows);
    hLow = IdealPropertiesofAir.h(rows);
    
        %solve for unknown h2s (Ideal enthalpy after compression)
    syms h2s
    h2s = vpasolve((h2s-hLow)/(pr2s - prLow)==(hHigh-hLow)/(prHigh-prLow),h2s)
    
    % solve for unknown h2w (actual h2 after compression)
    
    syms h2w
    h2w = vpasolve(ce == (h2s - h1)/(h2w - h1),h2w)
    
    %% Solve for Temperature after stage 1 of compressor
         %Interpolate T from h
    
    syms t2 %t2=temperature after 1st compressor
    
     %Find Higher Properties for Interpolation
    rows = find(IdealPropertiesofAir.h>h2w,1);
    THigh = IdealPropertiesofAir.T(rows);
    hHigh = IdealPropertiesofAir.h(rows);
    
        %Find Lower Properties for Interpolation
    rows = find(IdealPropertiesofAir.h<h2w,1,'last');
    TLow = IdealPropertiesofAir.T(rows);
    hLow = IdealPropertiesofAir.h(rows);
    
    t2 = vpasolve((THigh-TLow)/(hHigh-hLow) == (t2-TLow)/(h2w-hLow),t2);
    %% Solve for specific entropy after stage 1 of compressor
            %Find Higher Properties for Interpolation
    rows = find(IdealPropertiesofAir.h>h2w,1);
    hHigh = IdealPropertiesofAir.h(rows);
    sHigh = IdealPropertiesofAir.s(rows);
    
        %Find Lower Properties for Interpolation
    rows = find(IdealPropertiesofAir.h<h2w,1,'last');
    hLow = IdealPropertiesofAir.h(rows);
    sLow = IdealPropertiesofAir.s(rows);
    
        syms ent
    ent = vpasolve((h2w-hLow)/(ent - sLow)==(hHigh-hLow)/(sHigh-sLow),ent);
    
    %% Solve for specific volume after stage 1 of compressor
    %% Put in loop to iterate 14 times
    %%