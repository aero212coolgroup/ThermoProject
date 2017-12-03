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
%%  Initial Values

    pr2s = P2/P0*pr1;
   
    %Find Higher Properties for Interpolation
    rows = find(IdealPropertiesofAir.T>T0,1);
    Temp2 = IdealPropertiesofAir.T(rows);
    h2 = IdealPropertiesofAir.h(rows);
    
    %Find Lower Properties for Interpolation
    rows = find(IdealPropertiesofAir.T<T0,1,'last');
    Temp3 = IdealPropertiesofAir.T(rows);
    h3 = IdealPropertiesofAir.h(rows);
    
    % Solve for unknown h1 (Initial Enthalpy)
    syms h1
    h1 = vpasolve((T0-Temp3)/(h1-h3) == (Temp2-Temp3)/(h2-h3),h1);
  
    %while 1i < 15
    % 1i = 1;
    %%
        %Find Higher Properties for Interpolation
    rows = find(IdealPropertiesofAir.pf>pr2s,1);
    pf4 = IdealPropertiesofAir.pf(rows);
    h4 = IdealPropertiesofAir.h(rows);
    
        %Find Lower Properties for Interpolation
    rows = find(IdealPropertiesofAir.pf<pr2s,1,'last');
    pf5 = IdealPropertiesofAir.pf(rows);
    h5 = IdealPropertiesofAir.h(rows);
    
        %solve for unknown h2s (Ideal enthalpy after compression)
    syms h2s
    h2s = vpasolve((h2s-h5)/(pr2s - pf5)==(h4-h5)/(pf4-pf5),h2s)
    
    % solve for unknown h2w (actual h2 after compression)
    
    syms h2w
    h2w = vpasolve(ce == (h2s - h1)/(h2w - h1),h2w)
    
    %% Solve for Temperature after stage 1 of compressor
         %Interpolate T from h
    
    syms t2 %t2=temperature after 1st compressor
    
     %Find Higher Properties for Interpolation
    rows6 = find(IdealPropertiesofAir.h>h2w,1);
    tgreater = IdealPropertiesofAir.T(rows6);
    hgreater = IdealPropertiesofAir.h(rows6);
    
        %Find Lower Properties for Interpolation
    rows7 = find(IdealPropertiesofAir.h<h2w,1,'last');
    tlesser = IdealPropertiesofAir.T(rows7);
    hlesser = IdealPropertiesofAir.h(rows7);
    
    t2 = vpasolve((tgreater-tlesser)/(hgreater-hlesser) == (t2-tlesser)/(h2w-hlesser),t2);
    %% Solve for specific entropy after stage 1 of compressor
            %Find Higher Properties for Interpolation
    rows4 = find(IdealPropertiesofAir.h>h2w,1);
    vars4 = {'h', 's'};
    T6 = IdealPropertiesofAir(rows4, vars4);
    h6 = IdealPropertiesofAir.h(rows4);
    s6 = IdealPropertiesofAir.s(rows4);
    
        %Find Lower Properties for Interpolation
    rows5 = find(IdealPropertiesofAir.h<h2w,1,'last');
    vars5 = {'h', 's'};
    T7 = IdealPropertiesofAir(rows5, vars5);
    h7 = IdealPropertiesofAir.h(rows5);
    s7 = IdealPropertiesofAir.s(rows5);
    
        syms ent
    ent = vpasolve((h2w-h7)/(ent - s7)==(h6-h7)/(s6-s7),ent);
    
    %% Solve for specific colume after stage 1 of compressor
    %% Solve for pressure after first stage of compressor
    %p2 = P0 * Temperature / T0
    %% Put in loop to iterate 14 times
    %%