%% ================================================================
%  MT7006 - Examen Parcial II
%  Variante 1 - Grupo 1
%  Diseño de transmisión: bandas V + engranes rectos + ejes + rodamientos
%
%  Autor: [Nombre del grupo]
%  Fecha: [Completar]
%
%  NOTA IMPORTANTE:
%  Este script está parametrizado para que los valores leídos de gráficas
%  o tablas del curso se puedan modificar fácilmente en la sección 2.
%  En la entrega final, adjuntar las tablas/gráficas usadas para justificar:
%  - potencia por banda
%  - Ktheta, KL
%  - factores AGMA J, I, Ko, Km, Kv
%  - propiedades del material
%  - catálogo de rodamientos
%% ================================================================

clear; clc; close all;

%% ================================================================
%  1. DATOS DE LA VARIANTE 1
%% ================================================================

inp.P_hp        = 10;        % Potencia del motor [hp]
inp.n_motor     = 1750;      % Velocidad del motor [rpm]
inp.n_s_req     = 292;       % Velocidad requerida de salida [rpm]
inp.tol_ns      = 0.03;      % Tolerancia de velocidad de salida [+/- 3 %]

inp.FS_eng_min  = 1.50;      % FS minimo engranes
inp.FS_band_min = 1.15;      % FS minimo bandas
inp.FS_eje_min  = 1.60;      % FS minimo ejes
inp.Lcoj_h      = 30000;     % Vida minima rodamientos [h]

inp.Cmax_band   = 28;        % Distancia maxima entre centros bandas [in]
inp.Dmax_pulley = 15;        % Diametro maximo polea mayor [in]
inp.Ltot_max    = 18;        % Longitud maxima arbol principal [in]

g = 386.09;                  % Aceleracion gravedad [in/s^2], referencia

%% ================================================================
%  2. VARIABLES DE DISENO
%% ================================================================

% ------------------------------------------------
% 2.1 Transmision por bandas V
% ------------------------------------------------
belt.section       = "C";
belt.d_motor       = 9.0;     % Diametro polea motriz menor [in]
belt.D_driven      = 15.0;    % Diametro polea conducida mayor [in]
belt.Li            = 85.0;    % Longitud interior comercial de banda C85 [in]
belt.pitch_corr    = 2.9;     % Correccion aproximada Li -> Lp para seccion C [in]
belt.N_bands       = NaN;     % Se calcula con NB no redondeado y se redondea hacia arriba

% Valores leidos/asumidos de tablas y graficas.
% Reemplazar por los valores exactos leidos en las graficas del curso.
belt.K_service     = 1.50;    % Factor de servicio para trituradora / impacto pesado
belt.hp_per_belt   = NaN;     % Se interpola de la tabla para seccion C, d=9 in, V real
belt.Ktheta        = NaN;     % K1 se interpola usando la columna Plana en V
belt.KL            = 0.90;    % Factor por longitud de banda
belt.f_eff         = 0.5123;  % Coeficiente efectivo para relacion de tensiones

% ------------------------------------------------
% 2.2 Engranes rectos
% ------------------------------------------------
gear.phi_deg       = 20;      % Angulo de presion [deg]
gear.Np            = 20;      % Numero de dientes del pinon
gear.Ng            = 72;      % Numero de dientes de la rueda
gear.Pd            = 5;       % Paso diametral [dientes/in]
gear.F             = 2.50;    % Ancho de cara [in]
gear.Qv            = 7;       % Calidad AGMA

% Factores AGMA. Deben justificarse en memoria.
gear.Ko            = 1.75;    % Factor de sobrecarga
gear.Ks            = 1.00;    % Factor de tamano
gear.Km            = 1.155;    % Factor de distribucion de carga
gear.KB            = 1.00;    % Factor de espesor de borde
gear.Cf            = 1.00;    % Factor condicion superficial contacto
gear.KT            = 1.00;    % Factor temperatura
gear.KR            = 1.25;    % Factor confiabilidad AGMA aprox. 99 %

% Factores geometricos de flexion.
% Deben leerse de las graficas AGMA/presentacion para el par Np-Ng.
gear.Jp            = 0.33;    % Factor geometrico flexion piñon
gear.Jg            = 0.41;    % Factor geometrico flexion rueda

% Coeficiente elastico para acero-acero en unidades inglesas.
gear.Cp            = 2300;    % [sqrt(psi)]

% Material de engranes.
% Ejemplo: AISI 4140 OQT 1000 aprox. HB = 341.
matGear.name       = "AISI 4140 OQT 1000";
matGear.HB         = 341;     % Dureza Brinell
matGear.Sut_psi    = 168e3;   % Resistencia ultima [psi]
matGear.Sy_psi     = 152e3;   % Fluencia [psi]

% Ciclos de diseno del pinon
gear.Ncycles_pinion = 1e8;

% ------------------------------------------------
% 2.3 Material de ejes
% ------------------------------------------------
matShaft.name      = "AISI 4140 OQT 1300";
matShaft.Sut_psi   = 117e3;   % Resistencia ultima [psi]
matShaft.Sy_psi    = 100e3;   % Fluencia [psi]
matShaft.surface   = "machined";
matShaft.reliability_ke = 0.814;  % Confiabilidad 99 % para fatiga

% ------------------------------------------------
% 2.4 Posiciones axiales del arbol principal
%     Eje x medido desde el extremo izquierdo del arbol [in]
% ------------------------------------------------
layoutMain.x_leftEnd  = 0.0;
layoutMain.x_pulley   = 1.0;
layoutMain.x_A        = 3.0;
layoutMain.x_pinion   = 8.0;
layoutMain.x_B        = 13.0;
layoutMain.x_rightEnd = 16.0;

% ------------------------------------------------
% 2.5 Posiciones axiales del eje de salida
%     Se propone un eje de salida con rueda entre dos apoyos.
% ------------------------------------------------
layoutOut.x_leftEnd   = 0.0;
layoutOut.x_C         = 2.0;
layoutOut.x_gear      = 6.0;
layoutOut.x_D         = 11.0;
layoutOut.x_rightEnd  = 13.0;

%% ================================================================
%  3. CINEMATICA GENERAL
%% ================================================================

kin.ib = belt.D_driven / belt.d_motor;
kin.n_main = inp.n_motor / kin.ib;

kin.ig = gear.Ng / gear.Np;
kin.itotal = kin.ib * kin.ig;
kin.n_out = inp.n_motor / kin.itotal;

kin.ns_min = inp.n_s_req * (1 - inp.tol_ns);
kin.ns_max = inp.n_s_req * (1 + inp.tol_ns);

fprintf('\n============================================================\n');
fprintf('1. CINEMATICA\n');
fprintf('============================================================\n');
fprintf('Relacion bandas ib        = %.4f\n', kin.ib);
fprintf('Velocidad arbol principal = %.2f rpm\n', kin.n_main);
fprintf('Relacion engranes ig      = %.4f\n', kin.ig);
fprintf('Relacion total iT         = %.4f\n', kin.itotal);
fprintf('Velocidad salida          = %.2f rpm\n', kin.n_out);
fprintf('Rango permitido salida    = %.2f a %.2f rpm\n', kin.ns_min, kin.ns_max);

%% ================================================================
%  4. DISENO DE BANDAS EN V
%% ================================================================

belt.Lp = belt.Li + belt.pitch_corr;
belt.C  = centerDistanceFromPitchLength(belt.Lp, belt.d_motor, belt.D_driven);

belt.theta_small_rad = pi - 2*asin((belt.D_driven - belt.d_motor)/(2*belt.C));
belt.theta_small_deg = belt.theta_small_rad * 180/pi;

belt.V_ftmin = pi * belt.d_motor * inp.n_motor / 12;

% K1 por angulo de contacto. Por criterio del curso se usa la columna
% "Plana en V", interpolando con (D-d)/C.
belt.Dminusd_over_C = (belt.D_driven - belt.d_motor)/belt.C;
belt.Ktheta = KthetaFlatV(belt.Dminusd_over_C);

% Htab individual para seccion C, d = 9 in. Se interpola entre las columnas
% de 4000 y 5000 ft/min de la tabla de potencia tabulada.
belt.Htab_4000 = 7.86;
belt.Htab_5000 = 7.39;
belt.hp_per_belt = interp1([4000, 5000], [belt.Htab_4000, belt.Htab_5000], ...
    belt.V_ftmin, 'linear', 'extrap');

% Potencia base de servicio y potencia exigida para calcular numero de bandas.
belt.H_design_base = inp.P_hp * belt.K_service;
belt.H_design_req  = inp.P_hp * belt.K_service * inp.FS_band_min;

% Procedimiento de la presentacion: primero se calcula NB no redondeado.
belt.Htab_total_req = belt.H_design_req / (belt.Ktheta * belt.KL);
belt.N_unrounded = belt.Htab_total_req / belt.hp_per_belt;
belt.N_required = ceil(belt.N_unrounded);
belt.N_bands = belt.N_required;

% Torque en el arbol principal
T_main_lbin = 63025 * inp.P_hp / kin.n_main;

% Fuerza neta tangencial equivalente en polea conducida
belt.Fnet_lbf = T_main_lbin / (belt.D_driven/2);

% Relacion de tensiones y carga radial real sobre la polea.
belt.tension_ratio = exp(belt.f_eff*belt.theta_small_rad);
belt.T2_lbf = belt.Fnet_lbf/(belt.tension_ratio - 1);
belt.T1_lbf = belt.tension_ratio*belt.T2_lbf;
belt.Fradial_lbf = belt.T1_lbf + belt.T2_lbf;

% Capacidad disponible y factor de seguridad real
belt.H_capacity_per_belt = belt.hp_per_belt * belt.Ktheta * belt.KL;
belt.H_capacity_total = belt.N_bands * belt.H_capacity_per_belt;
belt.FS_real = belt.H_capacity_total / belt.H_design_base;

fprintf('\n============================================================\n');
fprintf('2. BANDAS EN V\n');
fprintf('============================================================\n');
fprintf('Seccion seleccionada      = %s\n', belt.section);
fprintf('Polea motriz menor d      = %.3f in\n', belt.d_motor);
fprintf('Polea conducida mayor D   = %.3f in\n', belt.D_driven);
fprintf('Longitud interior Li      = %.3f in\n', belt.Li);
fprintf('Longitud de paso Lp       = %.3f in\n', belt.Lp);
fprintf('Distancia entre centros C = %.3f in\n', belt.C);
fprintf('Angulo contacto menor     = %.2f deg\n', belt.theta_small_deg);
fprintf('(D-d)/C                   = %.4f\n', belt.Dminusd_over_C);
fprintf('K1 por angulo contacto    = %.4f (columna Plana en V)\n', belt.Ktheta);
fprintf('K2 por longitud           = %.4f\n', belt.KL);
fprintf('Velocidad de banda        = %.2f ft/min\n', belt.V_ftmin);
fprintf('hp tabulada por banda     = %.2f hp\n', belt.hp_per_belt);
fprintf('Potencia base servicio    = %.2f hp\n', belt.H_design_base);
fprintf('Potencia exigida bandas   = %.2f hp\n', belt.H_design_req);
fprintf('Htab total requerido      = %.2f hp\n', belt.Htab_total_req);
fprintf('NB no redondeado          = %.3f\n', belt.N_unrounded);
fprintf('NB requerido              = %d bandas\n', belt.N_required);
fprintf('Numero de bandas          = %d\n', belt.N_bands);
fprintf('Capacidad por banda corr. = %.2f hp\n', belt.H_capacity_per_belt);
fprintf('Capacidad total corregida = %.2f hp\n', belt.H_capacity_total);
fprintf('FS real bandas            = %.3f\n', belt.FS_real);
fprintf('Relacion tensiones T1/T2  = %.3f\n', belt.tension_ratio);
fprintf('T1 = %.2f lbf, T2 = %.2f lbf\n', belt.T1_lbf, belt.T2_lbf);
fprintf('Fuerza radial por bandas  = %.2f lbf\n', belt.Fradial_lbf);

%% ================================================================
%  5. DISENO DE ENGRANES RECTOS AGMA
%% ================================================================

gearOut = calcSpurGearAGMA(inp, gear, matGear, kin.n_main, T_main_lbin);

% Comparacion de pasos diametrales: la grafica de Mott da un valor de prueba
% cercano a Pd = 8, pero el diseño definitivo se acepta solo despues de AGMA.
PdTrials = [8; 6; 5];
PdTrialTable = evaluatePdTrials(inp, gear, matGear, kin.n_main, T_main_lbin, PdTrials);


fprintf('\n============================================================\n');
fprintf('3. ENGRANES RECTOS AGMA\n');
fprintf('============================================================\n');
fprintf('Material engranes             = %s\n', matGear.name);
fprintf('Np, Ng                        = %d, %d dientes\n', gear.Np, gear.Ng);
fprintf('Paso diametral Pd             = %.3f dientes/in\n', gear.Pd);
fprintf('Ancho de cara F               = %.3f in\n', gear.F);
fprintf('dp, dg                        = %.3f in, %.3f in\n', gearOut.dp, gearOut.dg);
fprintf('Centro engranes               = %.3f in\n', gearOut.Ccenter);
fprintf('Velocidad linea de paso       = %.2f ft/min\n', gearOut.V_ftmin);
fprintf('Torque arbol principal        = %.2f lbf*in\n', T_main_lbin);
fprintf('Wt                            = %.2f lbf\n', gearOut.Wt);
fprintf('Wr                            = %.2f lbf\n', gearOut.Wr);
fprintf('Kv                            = %.3f\n', gearOut.Kv);
fprintf('I contacto                    = %.4f\n', gearOut.I);
fprintf('sigma_F pinon                 = %.1f psi\n', gearOut.sigmaF_p);
fprintf('sigma_F rueda                 = %.1f psi\n', gearOut.sigmaF_g);
fprintf('sigma_H contacto              = %.1f psi\n', gearOut.sigmaH);
fprintf('FS flexion pinon              = %.3f\n', gearOut.SF_p);
fprintf('FS flexion rueda              = %.3f\n', gearOut.SF_g);
fprintf('FS contacto pinon             = %.3f\n', gearOut.SH_p);
fprintf('FS contacto rueda             = %.3f\n', gearOut.SH_g);
fprintf('FS engranes critico           = %.3f\n', gearOut.FS_min);

fprintf('\nComparacion preliminar de Pd evaluados:\n');
disp(PdTrialTable);


%% ================================================================
%  5B. OPTIMIZACION DE POSICIONES DEL ARBOL PRINCIPAL
%      Objetivo: minimizar el diametro maximo requerido por Goodman
%% ================================================================

% La optimizacion se realiza sobre el arbol principal porque el enunciado
% pide que el voladizo de la polea, la posicion de los apoyos y el claro
% entre cojinetes sean variables de diseno.

optMain.enable = true;

% Dominio de busqueda.
% Todas las posiciones estan en pulgadas medidas desde el extremo izquierdo
% del arbol principal.
optMain.x_leftEnd = 0.0;

% Paso de busqueda. Puede bajarse a 0.125 para una busqueda mas fina.
optMain.step = 0.25;

% Rango admisible para el centro de la polea conducida.
% La polea queda en voladizo a la izquierda del cojinete A.
optMain.x_pulley_min = 0.75;
optMain.x_pulley_max = 2.00;

% Rango admisible para el cojinete A.
optMain.x_A_min = 2.25;
optMain.x_A_max = 5.00;

% Rango admisible para el pinon.
optMain.x_pinion_min = 5.00;
optMain.x_pinion_max = 11.50;

% Rango admisible para el cojinete B.
optMain.x_B_min = 8.00;
optMain.x_B_max = 16.50;

% Separaciones minimas fisicas para dejar espacio de montaje.
% Estos valores no son de resistencia, sino restricciones de arquitectura.
% Deben revisarse luego contra el ancho real de polea, rodamientos, piñon,
% tapas, retenes y elementos de fijacion.
optMain.min_pulley_to_A   = 1.25;   % separacion centro polea - cojinete A
optMain.min_A_to_pinion   = 2.00;   % separacion cojinete A - centro pinon
optMain.min_pinion_to_B   = 2.00;   % separacion centro pinon - cojinete B
optMain.min_B_to_rightEnd = 1.00;   % extension minima derecha despues de B

% Restriccion global del examen.
optMain.Ltot_max = inp.Ltot_max;

% Para evitar soluciones geometricamente pobres con apoyos demasiado juntos.
optMain.min_bearing_span = 5.00;    % xB - xA minimo
optMain.max_bearing_span = 13.00;   % xB - xA maximo

% Ejecutar optimizacion.
[layoutMain, optMainResult] = optimizeMainShaftLayout( ...
    inp, optMain, belt, gearOut, T_main_lbin, matShaft);

fprintf('\n============================================================\n');
fprintf('5B. OPTIMIZACION DEL ARBOL PRINCIPAL\n');
fprintf('============================================================\n');

fprintf('Numero de configuraciones evaluadas = %d\n', optMainResult.nEvaluated);
fprintf('Numero de configuraciones factibles  = %d\n', optMainResult.nFeasible);

fprintf('\nMejor configuracion encontrada:\n');
fprintf('x_polea   = %.3f in\n', layoutMain.x_pulley);
fprintf('x_A       = %.3f in\n', layoutMain.x_A);
fprintf('x_pinon   = %.3f in\n', layoutMain.x_pinion);
fprintf('x_B       = %.3f in\n', layoutMain.x_B);
fprintf('x_extremo = %.3f in\n', layoutMain.x_rightEnd);
fprintf('L_total   = %.3f in\n', layoutMain.x_rightEnd - layoutMain.x_leftEnd);

fprintf('\nResultado mecanico de la mejor configuracion:\n');
fprintf('Diametro requerido maximo = %.4f in\n', optMainResult.best_d_req_max);
fprintf('Diametro comercial maximo = %.4f in\n', optMainResult.best_d_sel_max);
fprintf('FS minimo Goodman         = %.4f\n', optMainResult.best_FS_min);
fprintf('Momento maximo resultante = %.4f lbf*in\n', optMainResult.best_Mmax);

fprintf('\nTop 10 configuraciones factibles:\n');
disp(optMainResult.top10);



%% ================================================================
%  6. CARGAS SOBRE ARBOL PRINCIPAL OPTIMIZADO
%% ================================================================

% Convencion:
% Plano Y: horizontal.
% Plano Z: vertical.
%
% Se coloca la fuerza de bandas en el plano Y con signo negativo.
% La fuerza radial del engrane se coloca en el plano Y con signo positivo.
% La fuerza tangencial del engrane se coloca en el plano Z con signo negativo.

loadsMainY = [
    layoutMain.x_pulley, -belt.Fradial_lbf;
    layoutMain.x_pinion,  gearOut.Wr
];

loadsMainZ = [
    layoutMain.x_pinion, -gearOut.Wt
];

shaftMain = shaftTwoPlaneAnalysis( ...
    layoutMain.x_leftEnd, layoutMain.x_rightEnd, ...
    layoutMain.x_A, layoutMain.x_B, ...
    loadsMainY, loadsMainZ);

fprintf('\n============================================================\n');
fprintf('6. REACCIONES ARBOL PRINCIPAL OPTIMIZADO\n');
fprintf('============================================================\n');

fprintf('RAy = %.2f lbf, RBy = %.2f lbf\n', shaftMain.RAy, shaftMain.RBy);
fprintf('RAz = %.2f lbf, RBz = %.2f lbf\n', shaftMain.RAz, shaftMain.RBz);
fprintf('FrA = %.2f lbf\n', shaftMain.FrA);
fprintf('FrB = %.2f lbf\n', shaftMain.FrB);
fprintf('Momento maximo resultante = %.2f lbf*in en x = %.2f in\n', ...
    shaftMain.Mmax, shaftMain.x_Mmax);

%% ================================================================
%  7. DISENO POR FATIGA DEL ARBOL PRINCIPAL OPTIMIZADO
%% ================================================================

% NOTA:
% En esta version los Kf y Kfs siguen siendo preliminares.
% Luego se reemplazaran por valores calculados a partir de Kt, Kts, q y qs.

critMain = table( ...
    ["Polea - chavetero"; ...
     "Hombro cojinete A"; ...
     "Pinon - chavetero"; ...
     "Hombro cojinete B"], ...
    [layoutMain.x_pulley; layoutMain.x_A; layoutMain.x_pinion; layoutMain.x_B], ...
    [1.70; 1.50; 1.70; 1.50], ...
    [1.40; 1.25; 1.40; 1.25], ...
    'VariableNames', {'Seccion','x_in','Kf_b','Kfs_t'} );

designMain = designShaftByGoodman( ...
    critMain, shaftMain, T_main_lbin, matShaft, inp.FS_eje_min);

fprintf('\n============================================================\n');
fprintf('7. DISENO ARBOL PRINCIPAL OPTIMIZADO POR GOODMAN\n');
fprintf('============================================================\n');
disp(designMain);

FS_main_min = min(designMain.FS_Goodman);


%% ================================================================
%  8. CARGAS Y DISENO DEL EJE DE SALIDA
%% ================================================================

T_out_lbin = 63025 * inp.P_hp / kin.n_out;

% En la rueda, las fuerzas son opuestas a las del pinon.
loadsOutY = [
    layoutOut.x_gear, -gearOut.Wr
];

loadsOutZ = [
    layoutOut.x_gear, gearOut.Wt
];

shaftOut = shaftTwoPlaneAnalysis( ...
    layoutOut.x_leftEnd, layoutOut.x_rightEnd, ...
    layoutOut.x_C, layoutOut.x_D, ...
    loadsOutY, loadsOutZ);

fprintf('\n============================================================\n');
fprintf('6. REACCIONES EJE DE SALIDA\n');
fprintf('============================================================\n');
fprintf('RCy = %.2f lbf, RDy = %.2f lbf\n', shaftOut.RAy, shaftOut.RBy);
fprintf('RCz = %.2f lbf, RDz = %.2f lbf\n', shaftOut.RAz, shaftOut.RBz);
fprintf('FrC = %.2f lbf\n', shaftOut.FrA);
fprintf('FrD = %.2f lbf\n', shaftOut.FrB);
fprintf('Torque salida = %.2f lbf*in\n', T_out_lbin);
fprintf('Momento maximo resultante = %.2f lbf*in en x = %.2f in\n', ...
    shaftOut.Mmax, shaftOut.x_Mmax);

critOut = table( ...
    ["Hombro apoyo C"; ...
     "Rueda - chavetero"; ...
     "Hombro apoyo D"], ...
    [layoutOut.x_C; layoutOut.x_gear; layoutOut.x_D], ...
    [1.50; 1.70; 1.50], ...
    [1.25; 1.40; 1.25], ...
    'VariableNames', {'Seccion','x_in','Kf_b','Kfs_t'} );

designOut = designShaftByGoodman( ...
    critOut, shaftOut, T_out_lbin, matShaft, inp.FS_eje_min);

fprintf('\n============================================================\n');
fprintf('7. DISENO EJE DE SALIDA POR GOODMAN\n');
fprintf('============================================================\n');
disp(designOut);

FS_out_min = min(designOut.FS_Goodman);
FS_eje_global = min(FS_main_min, FS_out_min);

%% ================================================================
%  9. SELECCION DE RODAMIENTOS DEL ARBOL PRINCIPAL
%% ================================================================

% Catalogo preliminar interno.
% Reemplazar por datos exactos de catalogo SKF/Timken/NSK en la memoria.
bearingCatalog = createBearingCatalog();

% Diametro minimo estimado de asiento de rodamiento.
% Se usa el mayor diametro seleccionado en las secciones de cojinetes A y B.
idxA = designMain.Seccion == "Hombro cojinete A";
idxB = designMain.Seccion == "Hombro cojinete B";
d_journal_min_in = max([designMain.d_sel_in(idxA), designMain.d_sel_in(idxB), 1.00]);

bearingA = selectBallBearing(shaftMain.FrA, 0, kin.n_main, inp.Lcoj_h, ...
    d_journal_min_in, bearingCatalog);

bearingB = selectBallBearing(shaftMain.FrB, 0, kin.n_main, inp.Lcoj_h, ...
    d_journal_min_in, bearingCatalog);

fprintf('\n============================================================\n');
fprintf('8. RODAMIENTOS ARBOL PRINCIPAL\n');
fprintf('============================================================\n');
fprintf('Diametro minimo asiento rodamiento = %.3f in\n', d_journal_min_in);

fprintf('\nRodamiento A:\n');
fprintf('Modelo seleccionado = %s\n', bearingA.model);
fprintf('Bore = %.1f mm = %.3f in\n', bearingA.bore_mm, bearingA.bore_in);
fprintf('Fr = %.2f lbf, Fe = %.2f lbf\n', bearingA.Fr_lbf, bearingA.Fe_lbf);
fprintf('C requerido = %.2f lbf\n', bearingA.Creq_lbf);
fprintf('C catalogo  = %.2f lbf\n', bearingA.C_lbf);
fprintf('Vida 99%% = %.1f h\n', bearingA.life_h_99);

fprintf('\nRodamiento B:\n');
fprintf('Modelo seleccionado = %s\n', bearingB.model);
fprintf('Bore = %.1f mm = %.3f in\n', bearingB.bore_mm, bearingB.bore_in);
fprintf('Fr = %.2f lbf, Fe = %.2f lbf\n', bearingB.Fr_lbf, bearingB.Fe_lbf);
fprintf('C requerido = %.2f lbf\n', bearingB.Creq_lbf);
fprintf('C catalogo  = %.2f lbf\n', bearingB.C_lbf);
fprintf('Vida 99%% = %.1f h\n', bearingB.life_h_99);

%% ================================================================
%  10. VERIFICACION FINAL DE RESTRICCIONES
%% ================================================================

fprintf('\n============================================================\n');
fprintf('9. VERIFICACION FINAL CUMPLE / NO CUMPLE\n');
fprintf('============================================================\n');

check_ns       = kin.n_out >= kin.ns_min && kin.n_out <= kin.ns_max;
check_ib       = kin.ib >= 1.5 && kin.ib <= 2.5;
check_ig       = kin.ig >= 2.5 && kin.ig <= 4.0;
check_no_1to1  = abs(kin.ib - 1) > 1e-6 && abs(kin.ig - 1) > 1e-6;

check_band_FS  = belt.FS_real >= inp.FS_band_min;
check_Nbands   = belt.N_bands == 4 && belt.N_bands >= belt.N_required;
check_Cmax     = belt.C <= inp.Cmax_band;
check_Dmax     = belt.D_driven <= inp.Dmax_pulley;

check_Np       = gear.Np >= 17;
check_Qv       = gear.Qv >= 6 && gear.Qv <= 8;
check_gear_FS  = gearOut.FS_min >= inp.FS_eng_min;

check_main_L   = (layoutMain.x_rightEnd - layoutMain.x_leftEnd) <= inp.Ltot_max;
check_shaft_FS = FS_eje_global >= inp.FS_eje_min;

check_bear_A   = bearingA.life_h_99 >= inp.Lcoj_h;
check_bear_B   = bearingB.life_h_99 >= inp.Lcoj_h;

fprintf('Velocidad salida %.2f rpm dentro de %.2f - %.2f rpm: %s\n', ...
    kin.n_out, kin.ns_min, kin.ns_max, cumple(check_ns));

fprintf('Relacion bandas ib = %.3f en [1.5, 2.5]: %s\n', ...
    kin.ib, cumple(check_ib));

fprintf('Relacion engranes ig = %.3f en [2.5, 4.0]: %s\n', ...
    kin.ig, cumple(check_ig));

fprintf('Ninguna etapa 1:1: %s\n', cumple(check_no_1to1));

fprintf('FS bandas = %.3f >= %.3f: %s\n', ...
    belt.FS_real, inp.FS_band_min, cumple(check_band_FS));

fprintf('Numero de bandas NB = %d, requerido = %d: %s\n', ...
    belt.N_bands, belt.N_required, cumple(check_Nbands));

fprintf('Centro bandas C = %.3f in <= %.3f in: %s\n', ...
    belt.C, inp.Cmax_band, cumple(check_Cmax));

fprintf('Diametro polea mayor D = %.3f in <= %.3f in: %s\n', ...
    belt.D_driven, inp.Dmax_pulley, cumple(check_Dmax));

fprintf('Numero dientes pinon Np = %d >= 17: %s\n', ...
    gear.Np, cumple(check_Np));

fprintf('Calidad AGMA Qv = %d dentro de [6,8]: %s\n', ...
    gear.Qv, cumple(check_Qv));

fprintf('FS engranes critico = %.3f >= %.3f: %s\n', ...
    gearOut.FS_min, inp.FS_eng_min, cumple(check_gear_FS));

fprintf('FS ejes global = %.3f >= %.3f: %s\n', ...
    FS_eje_global, inp.FS_eje_min, cumple(check_shaft_FS));

fprintf('Longitud arbol principal = %.3f in <= %.3f in: %s\n', ...
    layoutMain.x_rightEnd - layoutMain.x_leftEnd, inp.Ltot_max, cumple(check_main_L));

fprintf('Vida rodamiento A = %.1f h >= %.1f h: %s\n', ...
    bearingA.life_h_99, inp.Lcoj_h, cumple(check_bear_A));

fprintf('Vida rodamiento B = %.1f h >= %.1f h: %s\n', ...
    bearingB.life_h_99, inp.Lcoj_h, cumple(check_bear_B));

allChecks = [check_ns, check_ib, check_ig, check_no_1to1, ...
             check_band_FS, check_Nbands, check_Cmax, check_Dmax, ...
             check_Np, check_Qv, check_gear_FS, ...
             check_shaft_FS, check_main_L, check_bear_A, check_bear_B];

fprintf('\nRESULTADO GLOBAL: %s\n', cumple(all(allChecks)));

%% ================================================================
%  11. GRAFICOS DE MOMENTO PARA LA MEMORIA
%% ================================================================

figure('Name','Arbol principal - momento resultante');
plot(shaftMain.x, shaftMain.MR, 'LineWidth', 1.8);
grid on;
xlabel('x [in]');
ylabel('M_R [lbf*in]');
title('Arbol principal - diagrama de momento flector resultante');

figure('Name','Eje de salida - momento resultante');
plot(shaftOut.x, shaftOut.MR, 'LineWidth', 1.8);
grid on;
xlabel('x [in]');
ylabel('M_R [lbf*in]');
title('Eje de salida - diagrama de momento flector resultante');

%% ================================================================
%  FUNCIONES LOCALES
%% ================================================================

function C = centerDistanceFromPitchLength(L, d, D)
% Calcula distancia entre centros a partir de la longitud aproximada:
% L = 2C + pi/2*(D+d) + (D-d)^2/(4C)

    B = 4*L - 2*pi*(D + d);
    disc = B^2 - 32*(D - d)^2;

    if disc < 0
        error('No existe solucion real para C con la longitud de banda seleccionada.');
    end

    C1 = (B + sqrt(disc))/16;
    C2 = (B - sqrt(disc))/16;

    C = max(C1, C2);
end

function K = KthetaFlatV(Dminusd_over_C)
% Factor K1 por angulo de contacto usando la columna "Plana en V".
% La tabla se indexa con (D-d)/C. Se interpola linealmente.
    xTable = [0.00 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00 1.10 1.20 1.30 1.40 1.50];
    kTable = [0.75 0.76 0.78 0.79 0.80 0.81 0.83 0.84 0.85 0.85 0.82 0.80 0.77 0.73 0.70 0.65];
    K = interp1(xTable, kTable, Dminusd_over_C, 'linear', 'extrap');
end

function gearOut = calcSpurGearAGMA(inp, gear, matGear, n_pinion, T_pinion_lbin)
% Calculo AGMA simplificado para engranes rectos externos.
% Unidades inglesas: fuerza [lbf], longitud [in], esfuerzo [psi].

    phi = deg2rad(gear.phi_deg);
    mG = gear.Ng / gear.Np;

    gearOut.dp = gear.Np / gear.Pd;
    gearOut.dg = gear.Ng / gear.Pd;
    gearOut.Ccenter = (gearOut.dp + gearOut.dg)/2;

    gearOut.Wt = 2*T_pinion_lbin / gearOut.dp;
    gearOut.Wr = gearOut.Wt * tan(phi);

    gearOut.V_ftmin = pi * gearOut.dp * n_pinion / 12;

    % Factor dinamico AGMA
    B = 0.25*(gear.Qv-5)^(0.667);
    A = 50 + 56*(1 - B);
    gearOut.Kv = ((A + sqrt(gearOut.V_ftmin))/A)^B;

    % Factor geometrico de contacto para engranes rectos externos
    gearOut.I = 0.104;
   
    % Esfuerzos de flexion AGMA
    gearOut.sigmaF_p = gearOut.Wt * gear.Ko * gearOut.Kv * gear.Ks * ...
        gear.Km * gear.KB * gear.Pd / (gear.F * gear.Jp);

    gearOut.sigmaF_g = gearOut.Wt * gear.Ko * gearOut.Kv * gear.Ks * ...
        gear.Km * gear.KB * gear.Pd / (gear.F * gear.Jg);

    % Esfuerzo de contacto AGMA
    gearOut.sigmaH = gear.Cp * sqrt( ...
        gearOut.Wt * gear.Ko * gearOut.Kv * gear.Ks * gear.Km / ...
        (gearOut.dp * gear.F * gearOut.I) );

    % Numeros permisibles AGMA aproximados para acero templado total, grado 1
    gearOut.Sat = 77.3*matGear.HB + 12800;     % [psi]
    gearOut.Sac = 341*matGear.HB + 23620;      % [psi]

    % Ciclos pinon y rueda
    Np_cycles = gear.Ncycles_pinion;
    Ng_cycles = gear.Ncycles_pinion / mG;

    % Factores de ciclos de esfuerzo aproximados
    gearOut.YN_p = 1.3558 * Np_cycles^(-0.0178);
    gearOut.YN_g = 1.3558 * Ng_cycles^(-0.0178);

    gearOut.ZN_p = 1.4488 * Np_cycles^(-0.023);
    gearOut.ZN_g = 1.4488 * Ng_cycles^(-0.023);

    % Factores de seguridad AGMA
    gearOut.SF_p = (gearOut.Sat * gearOut.YN_p) / ...
        (gear.KT * gear.KR * gearOut.sigmaF_p);

    gearOut.SF_g = (gearOut.Sat * gearOut.YN_g) / ...
        (gear.KT * gear.KR * gearOut.sigmaF_g);

    gearOut.SH_p = (gearOut.Sac * gearOut.ZN_p) / ...
        (gear.KT * gear.KR * gearOut.sigmaH);

    gearOut.SH_g = (gearOut.Sac * gearOut.ZN_g) / ...
        (gear.KT * gear.KR * gearOut.sigmaH);

    gearOut.FS_min = min([gearOut.SF_p, gearOut.SF_g, ...
                          gearOut.SH_p, gearOut.SH_g]);
end

function trialTable = evaluatePdTrials(inp, gear, matGear, n_pinion, T_pinion_lbin, PdTrials)
% Evalua pasos diametrales candidatos conservando Np, Ng, F, material y factores.
% Sirve para justificar que el Pd sugerido por la grafica preliminar debe
% iterarse con AGMA hasta cumplir flexion y contacto.
    n = numel(PdTrials);
    Pd = zeros(n,1);
    dp_in = zeros(n,1);
    Wt_lbf = zeros(n,1);
    V_ftmin = zeros(n,1);
    Kv = zeros(n,1);
    sigmaH_psi = zeros(n,1);
    SH_p = zeros(n,1);
    FS_min = zeros(n,1);
    Cumple = strings(n,1);

    for i = 1:n
        gear_i = gear;
        gear_i.Pd = PdTrials(i);
        out_i = calcSpurGearAGMA(inp, gear_i, matGear, n_pinion, T_pinion_lbin);

        Pd(i) = PdTrials(i);
        dp_in(i) = out_i.dp;
        Wt_lbf(i) = out_i.Wt;
        V_ftmin(i) = out_i.V_ftmin;
        Kv(i) = out_i.Kv;
        sigmaH_psi(i) = out_i.sigmaH;
        SH_p(i) = out_i.SH_p;
        FS_min(i) = out_i.FS_min;

        if out_i.FS_min >= inp.FS_eng_min
            Cumple(i) = "Cumple";
        else
            Cumple(i) = "No cumple";
        end
    end

    trialTable = table(Pd, dp_in, Wt_lbf, V_ftmin, Kv, sigmaH_psi, SH_p, FS_min, Cumple);
end

function shaft = shaftTwoPlaneAnalysis(x0, xEnd, xA, xB, loadsY, loadsZ)
% Analisis de un eje simplemente apoyado con cargas puntuales en dos planos.
% loadsY y loadsZ son matrices [x_i, F_i].

    [RAy, RBy] = supportReactions(loadsY, xA, xB);
    [RAz, RBz] = supportReactions(loadsZ, xA, xB);

    allY = [loadsY; xA, RAy; xB, RBy];
    allZ = [loadsZ; xA, RAz; xB, RBz];

    x = linspace(x0, xEnd, 1001);

    My = momentDistribution(x, allY);
    Mz = momentDistribution(x, allZ);

    MR = sqrt(My.^2 + Mz.^2);

    [Mmax, idx] = max(MR);

    shaft.x = x;
    shaft.My = My;
    shaft.Mz = Mz;
    shaft.MR = MR;

    shaft.RAy = RAy;
    shaft.RBy = RBy;
    shaft.RAz = RAz;
    shaft.RBz = RBz;

    shaft.FrA = sqrt(RAy^2 + RAz^2);
    shaft.FrB = sqrt(RBy^2 + RBz^2);

    shaft.Mmax = Mmax;
    shaft.x_Mmax = x(idx);
end

function [RA, RB] = supportReactions(loads, xA, xB)
% Reacciones de una viga con dos apoyos y cargas puntuales.
% Signo positivo hacia arriba en el plano analizado.

    if isempty(loads)
        RA = 0;
        RB = 0;
        return;
    end

    sumF = sum(loads(:,2));
    sumMA = sum(loads(:,2) .* (loads(:,1) - xA));

    RB = -sumMA / (xB - xA);
    RA = -sumF - RB;
end

function M = momentDistribution(x, allLoads)
% Calcula el momento interno acumulando F*(x-xi) para x >= xi.

    M = zeros(size(x));

    for k = 1:size(allLoads,1)
        xi = allLoads(k,1);
        Fi = allLoads(k,2);

        idx = x >= xi;
        M(idx) = M(idx) + Fi .* (x(idx) - xi);
    end
end

function designTable = designShaftByGoodman(critTable, shaft, T_lbin, matShaft, FS_req)
% Calcula diametro requerido por Goodman en cada seccion critica.

    nSec = height(critTable);

    Seccion = strings(nSec,1);
    x_in = zeros(nSec,1);
    M_lbin = zeros(nSec,1);
    Kf_b = zeros(nSec,1);
    Kfs_t = zeros(nSec,1);
    d_req_in = zeros(nSec,1);
    d_sel_in = zeros(nSec,1);
    Se_psi = zeros(nSec,1);
    FS_Goodman = zeros(nSec,1);
    FS_yield = zeros(nSec,1);

    for i = 1:nSec
        Seccion(i) = critTable.Seccion(i);
        x_in(i) = critTable.x_in(i);
        Kf_b(i) = critTable.Kf_b(i);
        Kfs_t(i) = critTable.Kfs_t(i);

        M_lbin(i) = interp1(shaft.x, shaft.MR, x_in(i), 'linear', 'extrap');

        [d_req_in(i), Se_psi(i)] = requiredDiameterGoodman( ...
            M_lbin(i), T_lbin, matShaft, FS_req, Kf_b(i), Kfs_t(i));

        d_sel_in(i) = roundUpTo(d_req_in(i), 0.125);

        FS_Goodman(i) = goodmanFS( ...
            M_lbin(i), T_lbin, d_sel_in(i), matShaft, Kf_b(i), Kfs_t(i));

        FS_yield(i) = yieldFS( ...
            M_lbin(i), T_lbin, d_sel_in(i), matShaft, Kf_b(i), Kfs_t(i));
    end

    designTable = table(Seccion, x_in, M_lbin, Kf_b, Kfs_t, ...
        d_req_in, d_sel_in, Se_psi, FS_Goodman, FS_yield);
end

function [d_req, Se] = requiredDiameterGoodman(M, T, mat, FS_req, Kfb, Kfs)
% Diametro requerido por Goodman modificado.
% Flexion alternante completamente invertida y torsion media constante.

    d = 1.0;

    for iter = 1:50
        Se = enduranceLimitShaft(mat, d);

        A = Kfb * 32*M / (pi*Se) + ...
            sqrt(3) * Kfs * 16*T / (pi*mat.Sut_psi);

        d_new = (FS_req * A)^(1/3);

        if abs(d_new - d) < 1e-5
            d = d_new;
            break;
        end

        d = d_new;
    end

    d_req = d;
    Se = enduranceLimitShaft(mat, d_req);
end

function FS = goodmanFS(M, T, d, mat, Kfb, Kfs)
% Factor de seguridad de Goodman para una seccion circular maciza.

    Se = enduranceLimitShaft(mat, d);

    sigma_a = Kfb * 32*M / (pi*d^3);
    tau_m   = Kfs * 16*T / (pi*d^3);

    sigma_a_eq = sigma_a;
    sigma_m_eq = sqrt(3) * tau_m;

    FS = 1 / (sigma_a_eq/Se + sigma_m_eq/mat.Sut_psi);
end

function FSy = yieldFS(M, T, d, mat, Ktb, Kts)
% Factor de seguridad estatico por Von Mises.

    sigma_b = Ktb * 32*M / (pi*d^3);
    tau_t   = Kts * 16*T / (pi*d^3);

    sigma_vm = sqrt(sigma_b^2 + 3*tau_t^2);

    FSy = mat.Sy_psi / sigma_vm;
end

function Se = enduranceLimitShaft(mat, d)
% Limite de resistencia a la fatiga corregido por Marin.
% Para acero: Se' = 0.5*Sut si Sut <= 200 ksi.

    Sut_ksi = mat.Sut_psi / 1000;

    if Sut_ksi <= 200
        Se_prime = 0.5 * mat.Sut_psi;
    else
        Se_prime = 100e3;
    end

    % Factor de superficie para maquinado, Sut en ksi
    ka = 2.70 * Sut_ksi^(-0.265);

    % Factor de tamano para flexion, d en pulgadas
    if d <= 2
        kb = 0.879 * d^(-0.107);
    else
        kb = 0.91 * d^(-0.157);
    end

    kc = 1.00;                     % Flexion
    kd = 1.00;                     % Temperatura ambiente
    ke = mat.reliability_ke;       % Confiabilidad 99 %
    kf_misc = 1.00;                % Otros efectos

    Se = ka * kb * kc * kd * ke * kf_misc * Se_prime;
end

function y = roundUpTo(x, increment)
% Redondea hacia arriba al incremento indicado.

    y = ceil(x/increment) * increment;
end

function catalog = createBearingCatalog()
% Catalogo preliminar de rodamientos rigidos de bolas.
% Valores aproximados. Sustituir por catalogo oficial en entrega final.

    model = ["6205"; "6305"; "6206"; "6306"; "6207"; "6307"; "6208"; "6308"];

    bore_mm = [25; 25; 30; 30; 35; 35; 40; 40];

    C_kN  = [14.0; 22.5; 19.5; 28.1; 25.5; 33.2; 30.7; 40.5];
    C0_kN = [7.8; 11.6; 11.2; 16.0; 15.3; 19.0; 19.0; 24.0];

    kN_to_lbf = 224.809;

    C_lbf  = C_kN  * kN_to_lbf;
    C0_lbf = C0_kN * kN_to_lbf;
    bore_in = bore_mm / 25.4;

    catalog = table(model, bore_mm, bore_in, C_lbf, C0_lbf);
end

function bearing = selectBallBearing(Fr_lbf, Fa_lbf, n_rpm, life_h_req, bore_min_in, catalog)
% Seleccion de rodamiento rigido de bolas para carga radial equivalente.
% Para Fa = 0: Fe = Fr.
%
% Vida modificada por confiabilidad:
% Lna = a1 * L10
% Para 99 % se toma a1 = 0.21.

    a_life = 3;       % Exponente para rodamientos de bolas
    a1 = 0.21;        % Factor de confiabilidad aprox. 99 %

    % Carga equivalente. En este examen se supone Fa = 0.
    if Fa_lbf == 0
        Fe_lbf = Fr_lbf;
    else
        % Espacio reservado para carga combinada.
        % Debe completarse con X, Y y e del catalogo si hay empuje axial.
        X = 1.0;
        Y = 0.0;
        Fe_lbf = X*Fr_lbf + Y*Fa_lbf;
    end

    Lreq_mrev_99 = 60*n_rpm*life_h_req / 1e6;
    L10_req_mrev = Lreq_mrev_99 / a1;

    Creq_lbf = Fe_lbf * (L10_req_mrev)^(1/a_life);

    idx = find(catalog.bore_in >= bore_min_in & catalog.C_lbf >= Creq_lbf);

    if isempty(idx)
        error('No hay rodamiento en el catalogo interno que cumpla C requerido y diametro minimo.');
    end

    candidates = catalog(idx,:);
    candidates = sortrows(candidates, {'bore_mm','C_lbf'});

    sel = candidates(1,:);

    L10_mrev = (sel.C_lbf / Fe_lbf)^a_life;
    L99_mrev = a1 * L10_mrev;
    life_h_99 = L99_mrev * 1e6 / (60*n_rpm);

    bearing.model = sel.model;
    bearing.bore_mm = sel.bore_mm;
    bearing.bore_in = sel.bore_in;
    bearing.C_lbf = sel.C_lbf;
    bearing.C0_lbf = sel.C0_lbf;
    bearing.Fr_lbf = Fr_lbf;
    bearing.Fa_lbf = Fa_lbf;
    bearing.Fe_lbf = Fe_lbf;
    bearing.Creq_lbf = Creq_lbf;
    bearing.life_h_99 = life_h_99;
end


function [bestLayout, optResult] = optimizeMainShaftLayout(inp, optSet, belt, gearOut, T_main_lbin, matShaft)
%OPTIMIZEMAINSHaftLAYOUT
% Optimiza las posiciones axiales del arbol principal.
%
% Variables de diseno:
%   x_pulley : centro de la polea conducida en voladizo
%   x_A      : posicion del cojinete A
%   x_pinion : centro del pinon
%   x_B      : posicion del cojinete B
%
% Objetivo:
%   minimizar el diametro maximo requerido por Goodman en las secciones
%   criticas del arbol principal.
%
% Restricciones:
%   - La polea debe quedar antes del cojinete A.
%   - El pinon debe quedar entre A y B.
%   - Deben respetarse separaciones minimas de montaje.
%   - La longitud total debe ser menor o igual a Ltot_max.
%   - El claro entre cojinetes no debe ser demasiado pequeno ni excesivo.
%   - El FS minimo calculado debe ser mayor o igual al FS requerido.

    nEvaluated = 0;
    nFeasible  = 0;

    bestObj = inf;

    records = [];

    xPulleyVec = optSet.x_pulley_min : optSet.step : optSet.x_pulley_max;
    xAVec      = optSet.x_A_min      : optSet.step : optSet.x_A_max;
    xPinVec    = optSet.x_pinion_min : optSet.step : optSet.x_pinion_max;
    xBVec      = optSet.x_B_min      : optSet.step : optSet.x_B_max;

    for xPulley = xPulleyVec
        for xA = xAVec
            for xPinion = xPinVec
                for xB = xBVec

                    nEvaluated = nEvaluated + 1;

                    % -----------------------------
                    % Restricciones geometricas
                    % -----------------------------

                    if xA <= xPulley + optSet.min_pulley_to_A
                        continue;
                    end

                    if xPinion <= xA + optSet.min_A_to_pinion
                        continue;
                    end

                    if xB <= xPinion + optSet.min_pinion_to_B
                        continue;
                    end

                    bearingSpan = xB - xA;

                    if bearingSpan < optSet.min_bearing_span
                        continue;
                    end

                    if bearingSpan > optSet.max_bearing_span
                        continue;
                    end

                    xRightEnd = xB + optSet.min_B_to_rightEnd;
                    Ltotal = xRightEnd - optSet.x_leftEnd;

                    if Ltotal > optSet.Ltot_max
                        continue;
                    end

                    % -----------------------------
                    % Cargas para esta geometria
                    % -----------------------------
                    loadsY = [
                        xPulley, -belt.Fradial_lbf;
                        xPinion,  gearOut.Wr
                    ];

                    loadsZ = [
                        xPinion, -gearOut.Wt
                    ];

                    shaftCandidate = shaftTwoPlaneAnalysis( ...
                        optSet.x_leftEnd, xRightEnd, ...
                        xA, xB, loadsY, loadsZ);

                    % -----------------------------
                    % Secciones criticas preliminares
                    % -----------------------------
                    critCandidate = table( ...
                        ["Polea - chavetero"; ...
                         "Hombro cojinete A"; ...
                         "Pinon - chavetero"; ...
                         "Hombro cojinete B"], ...
                        [xPulley; xA; xPinion; xB], ...
                        [1.70; 1.50; 1.70; 1.50], ...
                        [1.40; 1.25; 1.40; 1.25], ...
                        'VariableNames', {'Seccion','x_in','Kf_b','Kfs_t'} );

                    designCandidate = designShaftByGoodman( ...
                        critCandidate, shaftCandidate, T_main_lbin, matShaft, inp.FS_eje_min);

                    dReqMax = max(designCandidate.d_req_in);
                    dSelMax = max(designCandidate.d_sel_in);
                    FSmin   = min(designCandidate.FS_Goodman);

                    if FSmin < inp.FS_eje_min
                        continue;
                    end

                    nFeasible = nFeasible + 1;

                    % Objetivo principal: minimizar diametro requerido.
                    % Penalizacion secundaria: preferir menor longitud total.
                    % Penalizacion terciaria: preferir menor momento maximo.
                    obj = dReqMax + 1e-3*Ltotal + 1e-6*shaftCandidate.Mmax;

                    records = [records; ...
                        xPulley, xA, xPinion, xB, xRightEnd, Ltotal, ...
                        bearingSpan, shaftCandidate.Mmax, dReqMax, dSelMax, FSmin, obj];

                    if obj < bestObj
                        bestObj = obj;

                        bestLayout.x_leftEnd  = optSet.x_leftEnd;
                        bestLayout.x_pulley   = xPulley;
                        bestLayout.x_A        = xA;
                        bestLayout.x_pinion   = xPinion;
                        bestLayout.x_B        = xB;
                        bestLayout.x_rightEnd = xRightEnd;

                        bestShaft  = shaftCandidate;
                        bestDesign = designCandidate;
                    end
                end
            end
        end
    end

    if nFeasible == 0
        error(['No se encontro ninguna configuracion factible. ', ...
               'Revise rangos de busqueda o separaciones minimas.']);
    end

    resultTable = array2table(records, ...
        'VariableNames', {'x_pulley','x_A','x_pinion','x_B','x_rightEnd', ...
                          'Ltotal','bearingSpan','Mmax','d_req_max', ...
                          'd_sel_max','FS_min','objective'});

    resultTable = sortrows(resultTable, 'objective', 'ascend');

    optResult.nEvaluated = nEvaluated;
    optResult.nFeasible = nFeasible;
    optResult.allResults = resultTable;
    optResult.top10 = resultTable(1:min(10,height(resultTable)), :);

    optResult.best_d_req_max = max(bestDesign.d_req_in);
    optResult.best_d_sel_max = max(bestDesign.d_sel_in);
    optResult.best_FS_min = min(bestDesign.FS_Goodman);
    optResult.best_Mmax = bestShaft.Mmax;
    optResult.bestShaft = bestShaft;
    optResult.bestDesign = bestDesign;
end



function txt = cumple(ok)
% Devuelve texto CUMPLE / NO CUMPLE.

    if ok
        txt = 'CUMPLE';
    else
        txt = 'NO CUMPLE';
    end
end