%% ================================================================
%  MT7006 - Examen Parcial II
%  Variante 1 - Grupo 1
%  Diseño de transmisión: bandas V + engranes rectos + ejes + rodamientos
%
%  Versión física revisada:
%  - Corrige K1 de bandas V para transmisión V-V.
%  - Calcula relación de tensiones T1/T2, T1, T2 y carga radial de banda.
%  - Usa rodamientos comerciales SKF 6207 con datos de catálogo.
%  - Usa poleas comerciales Martin sección C, 4 ranuras, PD 9 in y 15 in.
%  - Optimiza el árbol principal con separaciones físicas mínimas basadas en
%    ancho de polea, ancho de rodamiento, tapa/retén y holguras de montaje.
%  - Impone diámetros mínimos constructivos para asientos de polea, piñón y
%    rodamientos, evitando soluciones matemáticas no fabricables.
%  - Mantiene concentradores de fatiga conservadores y explícitos.
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
inp.Lcoj_h      = 30000;     % Vida minima rodamientos [h], confiabilidad 99 %

inp.Cmax_band   = 28;        % Distancia maxima entre centros bandas [in]
inp.Dmax_pulley = 15;        % Diametro nominal maximo polea mayor [in]
inp.Ltot_max    = 18;        % Longitud maxima arbol principal [in]

%% ================================================================
%  2. COMPONENTES COMERCIALES Y VARIABLES DE DISENO
%% ================================================================

% ------------------------------------------------
% 2.1 Rodamiento comercial seleccionado para el arbol principal
%     SKF 6207, rodamiento rigido de bolas, abierto.
%     Catalogo SKF Rolling Bearings, tabla de ranura profunda d = 35 mm.
% ------------------------------------------------

bearingSKF.model       = "SKF 6207";
bearingSKF.type        = "Deep groove ball bearing, open";
bearingSKF.bore_mm     = 35.0;
bearingSKF.D_mm        = 72.0;
bearingSKF.B_mm        = 17.0;
bearingSKF.C_kN        = 27.0;      % Capacidad dinamica basica C
bearingSKF.C0_kN       = 15.3;      % Capacidad estatica basica C0
bearingSKF.Pu_kN       = 0.655;     % Limite de carga de fatiga
bearingSKF.ref_speed   = 20000;     % rpm
bearingSKF.limit_speed = 13000;     % rpm
bearingSKF.mass_kg     = 0.29;

bearingSKF.bore_in     = bearingSKF.bore_mm/25.4;
bearingSKF.D_in        = bearingSKF.D_mm/25.4;
bearingSKF.B_in        = bearingSKF.B_mm/25.4;
bearingSKF.C_lbf       = bearingSKF.C_kN*224.809;
bearingSKF.C0_lbf      = bearingSKF.C0_kN*224.809;

% ------------------------------------------------
% 2.2 Poleas comerciales Martin, seccion C, 4 ranuras, QD.
%     La polea de 15 in queda en el arbol principal en voladizo.
% ------------------------------------------------

sheaveMotor.part       = "Martin 4 C 90 E";    % Motriz, sobre eje del motor
sheaveMotor.PD_in      = 9.0;                   % Diametro de paso [in]
sheaveMotor.OD_in      = 9.4;                   % Diametro exterior catalogo [in]
sheaveMotor.grooves    = 4;
sheaveMotor.section    = "C";
sheaveMotor.face_in    = 4 + 3/8;               % F = 4 3/8 in
sheaveMotor.bushing    = "E";
sheaveMotor.max_bore   = 3.5;
sheaveMotor.L_in       = 2.625;                 % Length thru bore [in]
sheaveMotor.weight_lbf = 30.0;                  % Peso sin buje [lbf]

sheaveDriven.part       = "Martin 4 C 150 E";  % Conducida, arbol principal
sheaveDriven.PD_in      = 15.0;
sheaveDriven.OD_in      = 15.4;
sheaveDriven.grooves    = 4;
sheaveDriven.section    = "C";
sheaveDriven.face_in    = 4 + 3/8;
sheaveDriven.bushing    = "E";
sheaveDriven.max_bore   = 3.5;
sheaveDriven.L_in       = 2.625;
sheaveDriven.weight_lbf = 62.0;                 % Peso sin buje [lbf]

% ------------------------------------------------
% 2.3 Transmision por bandas V
% ------------------------------------------------

belt.section       = "C";
belt.d_motor       = sheaveMotor.PD_in;       % Diametro de paso polea menor [in]
belt.D_driven      = sheaveDriven.PD_in;      % Diametro de paso polea mayor [in]
belt.Li            = 85.0;                    % Longitud interior comercial C85 [in]
belt.pitch_corr    = 2.9;                     % Correccion Li -> Lp para seccion C [in]
belt.N_bands       = 4;                       % Cuatro bandas individuales C85

belt.K_service     = 1.50;                    % Servicio: trituradora/impacto pesado, 16-24 h
belt.hp_per_belt   = 7.8;                     % Htab aprox. seccion C, d=9 in, V~4000 ft/min
belt.KL            = 0.90;                    % Longitud C85: banda C, intervalo 81-96 in
belt.f_eff         = 0.5123;                  % Coeficiente efectivo Gates para bandas V
belt.include_Fc    = false;                   % No se usa fuerza centrifuga por falta de peso/longitud

% ------------------------------------------------
% 2.4 Engranes rectos
% ------------------------------------------------

gear.phi_deg       = 20;
gear.Np            = 20;
gear.Ng            = 72;
gear.Pd            = 5;
gear.F             = 2.50;
gear.Qv            = 7;
gear.H_hp          = 10; 

% Factores AGMA. Deben justificarse en memoria.
gear.Ko            = 1.75;
gear.Ks            = 1.00;
gear.Km            = 1.155;
gear.KB            = 1.00;
gear.Cf            = 1.00;
gear.KT            = 1.00;
gear.KR            = 1.25;

% Factores geometricos AGMA leidos/estimados para Np=20, Ng=72, phi=20 deg.
gear.Jp            = 0.33;
gear.Jg            = 0.41;
gear.Cp            = 2300;                    % sqrt(psi), acero-acero
gear.Ncycles_pinion = 1e8;

% ------------------------------------------------
% 2.5 Material de engranes
% ------------------------------------------------
matGear.name       = "AISI 4140 OQT 1000";
matGear.HB         = 341;
matGear.Sut_psi    = 168e3;
matGear.Sy_psi     = 152e3;

% ------------------------------------------------
% 2.6 Material de ejes
% ------------------------------------------------
matShaft.name      = "AISI 4140 OQT 1300";
matShaft.Sut_psi   = 117e3;
matShaft.Sy_psi    = 100e3;
matShaft.surface   = "machined";
matShaft.reliability_ke = 0.814;              % Fatiga, 99 %

% ------------------------------------------------
% 2.7 Diametros minimos constructivos
% ------------------------------------------------
% Para que el montaje sea fisicamente viable, la polea conducida, el pinon
% y los rodamientos del arbol principal se hacen compatibles con el mismo
% diametro base de asiento. Si el pinon quedara con bore menor que los
% asientos de rodamiento, no podria montarse entre los apoyos.
phys.main_pulley_seat_d_in  = bearingSKF.bore_in;
phys.main_bearing_seat_d_in = bearingSKF.bore_in;
phys.main_pinion_seat_d_in  = bearingSKF.bore_in;
phys.out_bearing_seat_d_in  = 1.25;           % Preliminar para eje de salida
phys.out_gear_seat_d_in     = 1.25;           % Rueda + chavetero
phys.round_increment_in     = 0.125;

% Concentradores conservadores, justificados como seleccion preliminar:
% chavetero: Kf flexion ~1.7, Kfs torsion ~1.4;
% hombro con filete razonable: Kf flexion ~1.5, Kfs torsion ~1.25.
KtAssume.keyway_Kf_b  = 1.70;
KtAssume.keyway_Kfs_t = 1.40;
KtAssume.shoulder_Kf_b  = 1.50;
KtAssume.shoulder_Kfs_t = 1.25;

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
belt.theta_small_deg = rad2deg(belt.theta_small_rad);

belt.V_ftmin = pi * belt.d_motor * inp.n_motor / 12;

% Segun el documento: columna Plana en V
belt.Dminusd_over_C = (belt.D_driven - belt.d_motor)/belt.C;
belt.Ktheta = KthetaFlatV(belt.Dminusd_over_C);

% Factor de longitud
belt.KL = 0.90;

% Potencia de diseno para bandas
belt.H_design_base = inp.P_hp * belt.K_service;
belt.H_design_req  = inp.P_hp * belt.K_service * inp.FS_band_min;   % 17.25 hp

% Potencia tabulada individual por banda
belt.Htab_4000 = 7.86;
belt.Htab_5000 = 7.39;
belt.hp_per_belt = interp1([4000, 5000], [belt.Htab_4000, belt.Htab_5000], ...
    belt.V_ftmin, 'linear', 'extrap');

% Numero de bandas
belt.Htab_total_req = belt.H_design_req / (belt.Ktheta * belt.KL);
belt.N_unrounded = belt.Htab_total_req / belt.hp_per_belt;
belt.N_required = ceil(belt.N_unrounded);
belt.N_bands = belt.N_required;

% Torque nominal del arbol principal para engranes
T_main_lbin = 63025 * belt.H_design_req / kin.n_main;

% Tension centrifuga
belt.Kc = 1.716;
belt.Fc_lbf = belt.Kc * (belt.V_ftmin/1000)^2;

% Relacion de tensiones
belt.tension_ratio = exp(belt.f_eff * belt.theta_small_rad);

% Diferencia de tensiones por banda usando la polea mayor
belt.deltaF_lbf = (63025 * belt.H_design_req / belt.N_bands) / ...
                  (kin.n_main * (belt.D_driven/2));

% Tensiones F1 y F2
belt.T1_lbf = belt.Fc_lbf + ...
    (belt.deltaF_lbf * belt.tension_ratio) / (belt.tension_ratio - 1);

belt.T2_lbf = belt.T1_lbf - belt.deltaF_lbf;

% Carga radial usada en el documento
belt.Fradial_lbf = belt.T1_lbf + belt.T2_lbf;

% Factor de seguridad real
belt.FS_real = inp.FS_band_min * (belt.N_bands / belt.N_unrounded);

fprintf('\n============================================================\n');
fprintf('2. BANDAS EN V\n');
fprintf('============================================================\n');
fprintf('Banda seleccionada        = %s85\n', belt.section);
fprintf('Numero de bandas          = %d\n', belt.N_bands);
fprintf('Polea motriz              = %s (PD = %.2f in)\n', ...
    sheaveMotor.part, sheaveMotor.PD_in);
fprintf('Polea conducida           = %s (PD = %.2f in)\n', ...
    sheaveDriven.part, sheaveDriven.PD_in);
fprintf('Longitud interior Li      = %.3f in\n', belt.Li);
fprintf('Longitud de paso Lp       = %.3f in\n', belt.Lp);
fprintf('Distancia entre centros C = %.3f in\n', belt.C);
fprintf('Angulo de contacto        = %.2f deg\n', ...
    belt.theta_small_deg);
fprintf('K1 por angulo contacto    = %.4f\n', belt.Ktheta);
fprintf('K2 por longitud           = %.4f\n', belt.KL);
fprintf('Velocidad de banda        = %.2f ft/min\n', ...
    belt.V_ftmin);
fprintf('Potencia por banda        = %.2f hp\n', ...
    belt.hp_per_belt);
fprintf('F1                        = %.2f lbf\n', ...
    belt.T1_lbf);
fprintf('F2                        = %.2f lbf\n', ...
    belt.T2_lbf);
fprintf('FB = F1 + F2              = %.2f lbf\n', ...
    belt.Fradial_lbf);
fprintf('FS real bandas            = %.3f\n', ...
    belt.FS_real);

%% ================================================================
%  5. DISENO DE ENGRANES RECTOS AGMA
%% ================================================================

gearOut = calcSpurGearAGMA(gear, matGear, kin.n_main);

fprintf('\n============================================================\n');
fprintf('3. ENGRANES RECTOS AGMA\n');
fprintf('============================================================\n');
fprintf('Material engranes             = %s\n', matGear.name);
fprintf('Np, Ng                        = %d, %d dientes\n', gear.Np, gear.Ng);
fprintf('Paso diametral Pd             = %.3f dientes/in\n', gear.Pd);
fprintf('Ancho de cara F               = %.3f in\n', gear.F);
fprintf('dp, dg                        = %.3f in, %.3f in\n', gearOut.dp, gearOut.dg);
fprintf('do_p, do_g                    = %.3f in, %.3f in\n', gearOut.do_p, gearOut.do_g);
fprintf('dr_p, dr_g                    = %.3f in, %.3f in\n', gearOut.dr_p, gearOut.dr_g);
fprintf('db_p, db_g                    = %.3f in, %.3f in\n', gearOut.db_p, gearOut.db_g);
fprintf('Centro engranes               = %.3f in\n', gearOut.Ccenter);
fprintf('Velocidad linea de paso Vt    = %.2f ft/min\n', gearOut.Vt);
fprintf('Wt                            = %.2f lbf\n', gearOut.Wt);
fprintf('Wr                            = %.2f lbf\n', gearOut.Wr);
fprintf('Kv                            = %.3f\n', gearOut.Kv);
fprintf('I contacto                    = %.3f\n', gearOut.I);
fprintf('st pinon flexion              = %.2f psi\n', gearOut.st_p);
fprintf('st engrane flexion            = %.2f psi\n', gearOut.st_g);
fprintf('sc pinon contacto             = %.2f psi\n', gearOut.sc_p);
fprintf('sc engrane contacto           = %.2f psi\n', gearOut.sc_g);
fprintf('Sat                           = %.2f psi\n', gearOut.Sat);
fprintf('Sac                           = %.2f psi\n', gearOut.Sac);
fprintf('SFt pinon                     = %.3f\n', gearOut.SFt_p);
fprintf('SFt engrane                   = %.3f\n', gearOut.SFt_g);
fprintf('SFc pinon                     = %.3f\n', gearOut.SFc_p);
fprintf('SFc engrane                   = %.3f\n', gearOut.SFc_g);
fprintf('FS engranes critico           = %.3f\n', gearOut.FS_min);

%% ================================================================
%  5B. OPTIMIZACION FISICA DEL ARBOL PRINCIPAL
%% ================================================================

arch.clear_left_of_pulley = 0.50;       % retencion/tuerca/holgura antes de polea [in]
arch.clear_pulley_to_housing = 0.50;    % claro polea-carcasa [in]
arch.cover_seal_pack = 0.75;            % tapa/retén/espesor lateral equivalente [in]
arch.internal_clear = 0.50;             % claro interno entre componente y rodamiento [in]
arch.right_retention = 1.25;            % extremo despues del rodamiento B [in]

optMain.step = 0.25;
optMain.x_leftEnd = 0.0;

% Rango de centros fisicamente razonable. La funcion tambien verifica las separaciones.
optMain.x_pulley_min = sheaveDriven.face_in/2 + arch.clear_left_of_pulley;
optMain.x_pulley_max = 4.00;
optMain.x_A_min      = 5.50;
optMain.x_A_max      = 9.50;
optMain.x_pinion_min = 8.00;
optMain.x_pinion_max = 14.00;
optMain.x_B_min      = 10.50;
optMain.x_B_max      = 16.75;

% Separaciones calculadas con dimensiones comerciales.
optMain.min_pulley_to_A = sheaveDriven.face_in/2 + ...
                          arch.clear_pulley_to_housing + ...
                          arch.cover_seal_pack + bearingSKF.B_in/2;

optMain.min_A_to_pinion = bearingSKF.B_in/2 + ...
                          arch.internal_clear + gear.F/2;

optMain.min_pinion_to_B = gear.F/2 + ...
                          arch.internal_clear + bearingSKF.B_in/2;

optMain.min_B_to_rightEnd = arch.right_retention;
optMain.Ltot_max = inp.Ltot_max;
optMain.min_bearing_span = optMain.min_A_to_pinion + optMain.min_pinion_to_B;
optMain.max_bearing_span = 13.00;

[layoutMain, optMainResult] = optimizeMainShaftLayout( ...
    inp, optMain, belt, gearOut, T_main_lbin, matShaft, KtAssume, phys, bearingSKF);

fprintf('\n============================================================\n');
fprintf('5B. OPTIMIZACION FISICA DEL ARBOL PRINCIPAL\n');
fprintf('============================================================\n');
fprintf('min polea-A   = %.3f in\n', optMain.min_pulley_to_A);
fprintf('min A-pinon   = %.3f in\n', optMain.min_A_to_pinion);
fprintf('min pinon-B   = %.3f in\n', optMain.min_pinion_to_B);
fprintf('min B-extremo = %.3f in\n', optMain.min_B_to_rightEnd);
fprintf('Configuraciones evaluadas = %d\n', optMainResult.nEvaluated);
fprintf('Configuraciones factibles  = %d\n', optMainResult.nFeasible);

fprintf('\nMejor configuracion encontrada:\n');
fprintf('x_polea   = %.3f in\n', layoutMain.x_pulley);
fprintf('x_A       = %.3f in\n', layoutMain.x_A);
fprintf('x_pinon   = %.3f in\n', layoutMain.x_pinion);
fprintf('x_B       = %.3f in\n', layoutMain.x_B);
fprintf('x_extremo = %.3f in\n', layoutMain.x_rightEnd);
fprintf('L_total   = %.3f in\n', layoutMain.x_rightEnd - layoutMain.x_leftEnd);

fprintf('\nResultado mecanico de la mejor configuracion:\n');
fprintf('Diametro requerido maximo        = %.4f in\n', optMainResult.best_d_req_max);
fprintf('Diametro final constructivo max  = %.4f in\n', optMainResult.best_d_sel_max);
fprintf('FS minimo Goodman                = %.4f\n', optMainResult.best_FS_min);
fprintf('Momento maximo resultante        = %.4f lbf*in\n', optMainResult.best_Mmax);

fprintf('\nTop 10 configuraciones factibles:\n');
disp(optMainResult.top10);

%% ================================================================
%  6. CARGAS SOBRE ARBOL PRINCIPAL OPTIMIZADO
%% ================================================================

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

critMain = table( ...
    ["Polea - chavetero"; ...
     "Hombro cojinete A"; ...
     "Pinon - chavetero"; ...
     "Hombro cojinete B"], ...
    [layoutMain.x_pulley; layoutMain.x_A; layoutMain.x_pinion; layoutMain.x_B], ...
    [KtAssume.keyway_Kf_b; KtAssume.shoulder_Kf_b; KtAssume.keyway_Kf_b; KtAssume.shoulder_Kf_b], ...
    [KtAssume.keyway_Kfs_t; KtAssume.shoulder_Kfs_t; KtAssume.keyway_Kfs_t; KtAssume.shoulder_Kfs_t], ...
    [phys.main_pulley_seat_d_in; phys.main_bearing_seat_d_in; phys.main_pinion_seat_d_in; phys.main_bearing_seat_d_in], ...
    [true; true; true; true], ...
    'VariableNames', {'Seccion','x_in','Kf_b','Kfs_t','d_min_in','exact_seat'} );

designMain = designShaftByGoodman( ...
    critMain, shaftMain, T_main_lbin, matShaft, inp.FS_eje_min, phys.round_increment_in);

fprintf('\n============================================================\n');
fprintf('7. DISENO ARBOL PRINCIPAL POR GOODMAN, CON DIAMETROS FISICOS\n');
fprintf('============================================================\n');
disp(designMain);

FS_main_min = min(designMain.FS_Goodman);

%% ================================================================
%  8. CARGAS Y DISENO DEL EJE DE SALIDA
%% ================================================================

T_out_lbin = 63025 * inp.P_hp / kin.n_out;

loadsOutY = [
    6.0, -gearOut.Wr
];

loadsOutZ = [
    6.0, gearOut.Wt
];

% Geometria fisica preliminar de eje de salida. Se deja compacta, con claro
% para rueda de F=2.5 in entre apoyos.
layoutOut.x_leftEnd  = 0.0;
layoutOut.x_C        = 2.0;
layoutOut.x_gear     = 6.0;
layoutOut.x_D        = 11.0;
layoutOut.x_rightEnd = 13.0;

shaftOut = shaftTwoPlaneAnalysis( ...
    layoutOut.x_leftEnd, layoutOut.x_rightEnd, ...
    layoutOut.x_C, layoutOut.x_D, ...
    loadsOutY, loadsOutZ);

fprintf('\n============================================================\n');
fprintf('8. REACCIONES EJE DE SALIDA\n');
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
    [KtAssume.shoulder_Kf_b; KtAssume.keyway_Kf_b; KtAssume.shoulder_Kf_b], ...
    [KtAssume.shoulder_Kfs_t; KtAssume.keyway_Kfs_t; KtAssume.shoulder_Kfs_t], ...
    [phys.out_bearing_seat_d_in; phys.out_gear_seat_d_in; phys.out_bearing_seat_d_in], ...
    [false; false; false], ...
    'VariableNames', {'Seccion','x_in','Kf_b','Kfs_t','d_min_in','exact_seat'} );

designOut = designShaftByGoodman( ...
    critOut, shaftOut, T_out_lbin, matShaft, inp.FS_eje_min, phys.round_increment_in);

fprintf('\n============================================================\n');
fprintf('9. DISENO EJE DE SALIDA POR GOODMAN, CON DIAMETROS FISICOS\n');
fprintf('============================================================\n');
disp(designOut);

FS_out_min = min(designOut.FS_Goodman);
FS_eje_global = min(FS_main_min, FS_out_min);

%% ================================================================
%  9. SELECCION DE RODAMIENTOS DEL ARBOL PRINCIPAL
%% ================================================================

bearingCatalog = createBearingCatalogSKF();

idxA = designMain.Seccion == "Hombro cojinete A";
idxB = designMain.Seccion == "Hombro cojinete B";
d_journal_min_in = max([designMain.d_sel_in(idxA), designMain.d_sel_in(idxB), bearingSKF.bore_in]);

bearingA = selectBallBearing(shaftMain.FrA, 0, kin.n_main, inp.Lcoj_h, ...
    d_journal_min_in, bearingCatalog);

bearingB = selectBallBearing(shaftMain.FrB, 0, kin.n_main, inp.Lcoj_h, ...
    d_journal_min_in, bearingCatalog);

fprintf('\n============================================================\n');
fprintf('10. RODAMIENTOS ARBOL PRINCIPAL\n');
fprintf('============================================================\n');
fprintf('Diametro minimo asiento rodamiento = %.3f in\n', d_journal_min_in);

printBearingResult('Rodamiento A', bearingA);
printBearingResult('Rodamiento B', bearingB);

%% ================================================================
%  10. VERIFICACION FINAL DE RESTRICCIONES
%% ================================================================

fprintf('\n============================================================\n');
fprintf('11. VERIFICACION FINAL CUMPLE / NO CUMPLE\n');
fprintf('============================================================\n');

check_ns       = kin.n_out >= kin.ns_min && kin.n_out <= kin.ns_max;
check_ib       = kin.ib >= 1.5 && kin.ib <= 2.5;
check_ig       = kin.ig >= 2.5 && kin.ig <= 4.0;
check_no_1to1  = abs(kin.ib - 1) > 1e-6 && abs(kin.ig - 1) > 1e-6;

check_band_FS  = belt.FS_real >= inp.FS_band_min;
check_Cmax     = belt.C <= inp.Cmax_band;
check_Dmax     = belt.D_driven <= inp.Dmax_pulley;
check_motor_sheave_min = belt.d_motor >= 9.0;  % Diametro minimo recomendado para banda clasica C
check_wrap     = belt.theta_small_deg >= 120;

check_Np       = gear.Np >= 17;
check_Qv       = gear.Qv >= 6 && gear.Qv <= 8;
check_gear_FS  = gearOut.FS_min >= inp.FS_eng_min;

check_main_L   = (layoutMain.x_rightEnd - layoutMain.x_leftEnd) <= inp.Ltot_max;
check_shaft_FS = FS_eje_global >= inp.FS_eje_min;
check_phys_bearing_d = all(abs([designMain.d_sel_in(idxA); designMain.d_sel_in(idxB)] - bearingSKF.bore_in) <= 1e-6);

check_bear_A   = bearingA.life_h_99 >= inp.Lcoj_h;
check_bear_B   = bearingB.life_h_99 >= inp.Lcoj_h;
check_bear_speed = kin.n_main <= min(bearingA.limit_speed, bearingB.limit_speed);
check_bearing_model = string(bearingA.model) == bearingSKF.model && string(bearingB.model) == bearingSKF.model;

reportCheck('Velocidad salida', kin.n_out, sprintf('%.2f - %.2f rpm', kin.ns_min, kin.ns_max), check_ns);
reportCheck('Relacion bandas ib', kin.ib, '[1.5, 2.5]', check_ib);
reportCheck('Relacion engranes ig', kin.ig, '[2.5, 4.0]', check_ig);
reportCheck('Ninguna etapa 1:1', double(check_no_1to1), 'true', check_no_1to1);
reportCheck('FS bandas', belt.FS_real, sprintf('>= %.3f', inp.FS_band_min), check_band_FS);
reportCheck('Centro bandas C [in]', belt.C, sprintf('<= %.3f', inp.Cmax_band), check_Cmax);
reportCheck('Diametro nominal polea mayor [in]', belt.D_driven, sprintf('<= %.3f', inp.Dmax_pulley), check_Dmax);
reportCheck('Diametro polea menor recomendado [in]', belt.d_motor, '>= 9.0 para seccion C', check_motor_sheave_min);
reportCheck('Angulo contacto menor [deg]', belt.theta_small_deg, '>= 120', check_wrap);
reportCheck('Numero dientes pinon', gear.Np, '>= 17', check_Np);
reportCheck('Calidad AGMA Qv', gear.Qv, '[6, 8]', check_Qv);
reportCheck('FS engranes critico', gearOut.FS_min, sprintf('>= %.3f', inp.FS_eng_min), check_gear_FS);
reportCheck('FS ejes global', FS_eje_global, sprintf('>= %.3f', inp.FS_eje_min), check_shaft_FS);
reportCheck('Longitud arbol principal [in]', layoutMain.x_rightEnd-layoutMain.x_leftEnd, sprintf('<= %.3f', inp.Ltot_max), check_main_L);
reportCheck('Asientos rodamientos = bore SKF 6207', double(check_phys_bearing_d), 'true', check_phys_bearing_d);
reportCheck('Modelo rodamientos seleccionado', double(check_bearing_model), 'SKF 6207 en A y B', check_bearing_model);
reportCheck('Vida rodamiento A [h]', bearingA.life_h_99, sprintf('>= %.1f', inp.Lcoj_h), check_bear_A);
reportCheck('Vida rodamiento B [h]', bearingB.life_h_99, sprintf('>= %.1f', inp.Lcoj_h), check_bear_B);
reportCheck('Velocidad rodamiento [rpm]', kin.n_main, sprintf('<= %.0f', min(bearingA.limit_speed, bearingB.limit_speed)), check_bear_speed);

allChecks = [check_ns, check_ib, check_ig, check_no_1to1, ...
             check_band_FS, check_Cmax, check_Dmax, check_motor_sheave_min, check_wrap, ...
             check_Np, check_Qv, check_gear_FS, check_shaft_FS, check_main_L, ...
             check_phys_bearing_d, check_bearing_model, check_bear_A, check_bear_B, check_bear_speed];

fprintf('\nRESULTADO GLOBAL: %s\n', cumple(all(allChecks)));

%% ================================================================
%  11. GRAFICOS
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

function K = KthetaFlatV(Dminusd_over_C)
    xTable = [0.00 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00 1.10 1.20 1.30 1.40 1.50];
    kTable = [0.75 0.76 0.78 0.79 0.80 0.81 0.83 0.84 0.85 0.85 0.82 0.80 0.77 0.73 0.70 0.65];

    K = interp1(xTable, kTable, Dminusd_over_C, 'linear', 'extrap');
end

function C = centerDistanceFromPitchLength(Lp, d, D)
% Calcula la distancia entre centros usando:
%
% C = 0.25 * [ Lp - (pi/2)(D+d)
%              + sqrt((Lp - (pi/2)(D+d))^2 - 2(D-d)^2) ]

    A = Lp - (pi/2)*(D + d);

    disc = A^2 - 2*(D - d)^2;

    if disc < 0
        error('No existe solucion real para C con la longitud de banda seleccionada.');
    end

    C = 0.25*(A + sqrt(disc));
end

function gearOut = calcSpurGearAGMA(gear, matGear, n_pinion)
% Calculo AGMA simplificado para engranes rectos externos.
% Los datos de entrada se toman desde la estructura gear.
% Unidades inglesas: fuerza [lbf], longitud [in], esfuerzo [psi].

    phi = deg2rad(gear.phi_deg);

    % Geometria
    gearOut.dp = gear.Np / gear.Pd;
    gearOut.dg = gear.Ng / gear.Pd;
    gearOut.Ccenter = (gearOut.dp + gearOut.dg)/2;

    gearOut.addendum = 1/gear.Pd;
    gearOut.dedendum = 1.25/gear.Pd;

    gearOut.do_p = gearOut.dp + 2*gearOut.addendum;
    gearOut.do_g = gearOut.dg + 2*gearOut.addendum;

    gearOut.dr_p = gearOut.dp - 2*gearOut.dedendum;
    gearOut.dr_g = gearOut.dg - 2*gearOut.dedendum;

    gearOut.db_p = gearOut.dp*cos(phi);
    gearOut.db_g = gearOut.dg*cos(phi);

    % Fuerzas
    gearOut.Vt = pi * gearOut.dp * n_pinion / 12;
    gearOut.Wt = 33000 * gear.H_hp / gearOut.Vt;
    gearOut.Wr = gearOut.Wt * tan(phi);

    % Factores obtenidos
    gearOut.Kv = 1.142;
    gearOut.I  = 0.104;

    % Esfuerzo de flexion AGMA
    gearOut.st_p = (gearOut.Wt * gear.Pd)/(gear.F * gear.Jp) * ...
        gear.Ko * gear.Ks * gear.Km * gear.KB * gearOut.Kv;

    gearOut.st_g = (gearOut.Wt * gear.Pd)/(gear.F * gear.Jg) * ...
        gear.Ko * gear.Ks * gear.Km * gear.KB * gearOut.Kv;

    % Esfuerzo de contacto AGMA
    gearOut.sc_p = gear.Cp * sqrt( ...
        (gearOut.Wt * gear.Ko * gear.Ks * gear.Km * gearOut.Kv) / ...
        (gear.F * gearOut.dp * gearOut.I) );

    gearOut.sc_g = gear.Cp * sqrt( ...
        (gearOut.Wt * gear.Ko * gear.Ks * gear.Km * gearOut.Kv) / ...
        (gear.F * gearOut.dg * gearOut.I) );

    % Esfuerzos permisibles
    gearOut.Sat = 77.3*matGear.HB + 12800;
    gearOut.Sac = 322*matGear.HB + 29100;

    % Factores de vida
    gearOut.YN_p = 0.977;
    gearOut.YN_g = 0.999;

    gearOut.ZN_p = 0.948;
    gearOut.ZN_g = 0.977;

    % Factores de seguridad
    gearOut.SFt_p = (gearOut.Sat / gearOut.st_p) * ...
        (gearOut.YN_p / gear.KR);

    gearOut.SFt_g = (gearOut.Sat / gearOut.st_g) * ...
        (gearOut.YN_g / gear.KR);

    gearOut.SFc_p = (gearOut.Sac / gearOut.sc_p) * ...
        (gearOut.ZN_p / gear.KR);

    gearOut.SFc_g = (gearOut.Sac / gearOut.sc_g) * ...
        (gearOut.ZN_g / gear.KR);

    gearOut.FS_min = min([gearOut.SFt_p, gearOut.SFt_g, ...
                          gearOut.SFc_p, gearOut.SFc_g]);
end

function [bestLayout, optResult] = optimizeMainShaftLayout(inp, optSet, belt, gearOut, T_main_lbin, matShaft, KtAssume, phys, bearingSKF)
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

                    if xA <= xPulley + optSet.min_pulley_to_A, continue; end
                    if xPinion <= xA + optSet.min_A_to_pinion, continue; end
                    if xB <= xPinion + optSet.min_pinion_to_B, continue; end
                    bearingSpan = xB - xA;
                    if bearingSpan < optSet.min_bearing_span, continue; end
                    if bearingSpan > optSet.max_bearing_span, continue; end

                    xRightEnd = xB + optSet.min_B_to_rightEnd;
                    Ltotal = xRightEnd - optSet.x_leftEnd;
                    if Ltotal > optSet.Ltot_max, continue; end

                    loadsY = [xPulley, -belt.Fradial_lbf; xPinion, gearOut.Wr];
                    loadsZ = [xPinion, -gearOut.Wt];

                    shaftCandidate = shaftTwoPlaneAnalysis(optSet.x_leftEnd, xRightEnd, xA, xB, loadsY, loadsZ);

                    critCandidate = table( ...
                        ["Polea - chavetero"; "Hombro cojinete A"; "Pinon - chavetero"; "Hombro cojinete B"], ...
                        [xPulley; xA; xPinion; xB], ...
                        [KtAssume.keyway_Kf_b; KtAssume.shoulder_Kf_b; KtAssume.keyway_Kf_b; KtAssume.shoulder_Kf_b], ...
                        [KtAssume.keyway_Kfs_t; KtAssume.shoulder_Kfs_t; KtAssume.keyway_Kfs_t; KtAssume.shoulder_Kfs_t], ...
                        [phys.main_pulley_seat_d_in; bearingSKF.bore_in; phys.main_pinion_seat_d_in; bearingSKF.bore_in], ...
                        [true; true; true; true], ...
                        'VariableNames', {'Seccion','x_in','Kf_b','Kfs_t','d_min_in','exact_seat'} );

                    designCandidate = designShaftByGoodman(critCandidate, shaftCandidate, T_main_lbin, matShaft, inp.FS_eje_min, phys.round_increment_in);

                    dReqMax = max(designCandidate.d_req_in);
                    dSelMax = max(designCandidate.d_sel_in);
                    FSmin   = min(designCandidate.FS_Goodman);

                    if FSmin < inp.FS_eje_min, continue; end
                    nFeasible = nFeasible + 1;

                    obj = dSelMax + 1e-4*shaftCandidate.Mmax + 1e-3*Ltotal;

                    records = [records; xPulley, xA, xPinion, xB, xRightEnd, Ltotal, bearingSpan, shaftCandidate.Mmax, dReqMax, dSelMax, FSmin, obj]; %#ok<AGROW>

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
        error('No se encontro ninguna configuracion factible. Revise rangos o separaciones.');
    end

    resultTable = array2table(records, 'VariableNames', ...
        {'x_pulley','x_A','x_pinion','x_B','x_rightEnd','Ltotal','bearingSpan','Mmax','d_req_max','d_sel_max','FS_min','objective'});
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

function shaft = shaftTwoPlaneAnalysis(x0, xEnd, xA, xB, loadsY, loadsZ)
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
    if isempty(loads)
        RA = 0; RB = 0; return;
    end
    sumF = sum(loads(:,2));
    sumMA = sum(loads(:,2) .* (loads(:,1) - xA));
    RB = -sumMA / (xB - xA);
    RA = -sumF - RB;
end

function M = momentDistribution(x, allLoads)
    M = zeros(size(x));
    for k = 1:size(allLoads,1)
        xi = allLoads(k,1);
        Fi = allLoads(k,2);
        idx = x >= xi;
        M(idx) = M(idx) + Fi .* (x(idx) - xi);
    end
end

function designTable = designShaftByGoodman(critTable, shaft, T_lbin, matShaft, FS_req, increment)
    nSec = height(critTable);
    Seccion = strings(nSec,1);
    x_in = zeros(nSec,1);
    M_lbin = zeros(nSec,1);
    Kf_b = zeros(nSec,1);
    Kfs_t = zeros(nSec,1);
    d_req_in = zeros(nSec,1);
    d_min_in = zeros(nSec,1);
    d_sel_in = zeros(nSec,1);
    exact_seat = false(nSec,1);
    Se_psi = zeros(nSec,1);
    FS_Goodman = zeros(nSec,1);
    FS_yield = zeros(nSec,1);

    for i = 1:nSec
        Seccion(i) = critTable.Seccion(i);
        x_in(i) = critTable.x_in(i);
        Kf_b(i) = critTable.Kf_b(i);
        Kfs_t(i) = critTable.Kfs_t(i);
        d_min_in(i) = critTable.d_min_in(i);
        if ismember('exact_seat', critTable.Properties.VariableNames)
            exact_seat(i) = critTable.exact_seat(i);
        end
        M_lbin(i) = interp1(shaft.x, shaft.MR, x_in(i), 'linear', 'extrap');

        [d_req_in(i), Se_psi(i)] = requiredDiameterGoodman(M_lbin(i), T_lbin, matShaft, FS_req, Kf_b(i), Kfs_t(i));
        if exact_seat(i)
            % Asientos metricos comerciales: no se redondean a fraccion imperial.
            % Si resistencia exige mas diametro que el bore comercial, debe elegirse
            % otro rodamiento/buje, no redondear el asiento.
            if d_req_in(i) > d_min_in(i)
                error('La seccion "%s" requiere d = %.4f in, mayor que el asiento comercial %.4f in. Seleccione un rodamiento/buje mayor.', ...
                    char(Seccion(i)), d_req_in(i), d_min_in(i));
            end
            d_sel_in(i) = d_min_in(i);
        else
            d_sel_in(i) = max(roundUpTo(d_req_in(i), increment), d_min_in(i));
            d_sel_in(i) = roundUpTo(d_sel_in(i), increment);
        end

        FS_Goodman(i) = goodmanFS(M_lbin(i), T_lbin, d_sel_in(i), matShaft, Kf_b(i), Kfs_t(i));
        FS_yield(i) = yieldFS(M_lbin(i), T_lbin, d_sel_in(i), matShaft, Kf_b(i), Kfs_t(i));
        Se_psi(i) = enduranceLimitShaft(matShaft, d_sel_in(i));
    end

    designTable = table(Seccion, x_in, M_lbin, Kf_b, Kfs_t, d_req_in, d_min_in, d_sel_in, exact_seat, Se_psi, FS_Goodman, FS_yield);
end

function [d_req, Se] = requiredDiameterGoodman(M, T, mat, FS_req, Kfb, Kfs)
    d = 1.0;
    for iter = 1:60
        Se = enduranceLimitShaft(mat, d);
        A = Kfb * 32*M / (pi*Se) + sqrt(3) * Kfs * 16*T / (pi*mat.Sut_psi);
        d_new = (FS_req * A)^(1/3);
        if abs(d_new - d) < 1e-6
            d = d_new; break;
        end
        d = d_new;
    end
    d_req = d;
    Se = enduranceLimitShaft(mat, d_req);
end

function FS = goodmanFS(M, T, d, mat, Kfb, Kfs)
    Se = enduranceLimitShaft(mat, d);
    sigma_a = Kfb * 32*M / (pi*d^3);
    tau_m   = Kfs * 16*T / (pi*d^3);
    sigma_a_eq = sigma_a;
    sigma_m_eq = sqrt(3) * tau_m;
    FS = 1 / (sigma_a_eq/Se + sigma_m_eq/mat.Sut_psi);
end

function FSy = yieldFS(M, T, d, mat, Ktb, Kts)
    sigma_b = Ktb * 32*M / (pi*d^3);
    tau_t   = Kts * 16*T / (pi*d^3);
    sigma_vm = sqrt(sigma_b^2 + 3*tau_t^2);
    FSy = mat.Sy_psi / sigma_vm;
end

function Se = enduranceLimitShaft(mat, d)
    Sut_ksi = mat.Sut_psi / 1000;
    if Sut_ksi <= 200
        Se_prime = 0.5 * mat.Sut_psi;
    else
        Se_prime = 100e3;
    end
    ka = 2.70 * Sut_ksi^(-0.265);      % maquinado, Sut en ksi
    if d <= 2
        kb = 0.879 * d^(-0.107);
    else
        kb = 0.91 * d^(-0.157);
    end
    kc = 1.00;
    kd = 1.00;
    ke = mat.reliability_ke;
    kf_misc = 1.00;
    Se = ka * kb * kc * kd * ke * kf_misc * Se_prime;
end

function y = roundUpTo(x, increment)
    y = ceil(x/increment) * increment;
end

function catalog = createBearingCatalogSKF()
    model = ["SKF 6006"; "SKF 6206"; "SKF 6306"; "SKF 6207"; "SKF 6307"; "SKF 6208"];
    bore_mm = [30; 30; 30; 35; 35; 40];
    D_mm    = [55; 62; 72; 72; 80; 80];
    B_mm    = [13; 16; 19; 17; 21; 18];
    C_kN    = [13.8; 20.3; 28.1; 27.0; 33.2; 30.7];
    C0_kN   = [8.3; 11.2; 16.0; 15.3; 19.0; 19.0];
    ref_speed = [28000; 24000; 20000; 20000; 18000; 17000];
    limit_speed = [17000; 15000; 13000; 13000; 11000; 11000];
    mass_kg = [0.12; 0.20; 0.35; 0.29; 0.45; 0.37];

    kN_to_lbf = 224.809;
    bore_in = bore_mm / 25.4;
    C_lbf  = C_kN  * kN_to_lbf;
    C0_lbf = C0_kN * kN_to_lbf;

    catalog = table(model, bore_mm, bore_in, D_mm, B_mm, C_lbf, C0_lbf, ref_speed, limit_speed, mass_kg);
end

function bearing = selectBallBearing(Fr_lbf, Fa_lbf, n_rpm, life_h_req, bore_min_in, catalog)
    a_life = 3;
    a1 = 0.21;        % confiabilidad 99 %, aproximacion clasica

    if abs(Fa_lbf) < 1e-9
        Fe_lbf = Fr_lbf;
    else
        X = 1.0; Y = 0.0;
        Fe_lbf = X*Fr_lbf + Y*Fa_lbf;
    end

    Lreq_mrev_99 = 60*n_rpm*life_h_req / 1e6;
    L10_req_mrev = Lreq_mrev_99 / a1;
    Creq_lbf = Fe_lbf * (L10_req_mrev)^(1/a_life);

    idx = find(catalog.bore_in >= bore_min_in & catalog.C_lbf >= Creq_lbf);
    if isempty(idx)
        error('No hay rodamiento en catalogo interno que cumpla C requerido y diametro minimo.');
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
    bearing.D_mm = sel.D_mm;
    bearing.B_mm = sel.B_mm;
    bearing.C_lbf = sel.C_lbf;
    bearing.C0_lbf = sel.C0_lbf;
    bearing.ref_speed = sel.ref_speed;
    bearing.limit_speed = sel.limit_speed;
    bearing.mass_kg = sel.mass_kg;
    bearing.Fr_lbf = Fr_lbf;
    bearing.Fa_lbf = Fa_lbf;
    bearing.Fe_lbf = Fe_lbf;
    bearing.Creq_lbf = Creq_lbf;
    bearing.life_h_99 = life_h_99;
end

function printBearingResult(label, bearing)
    fprintf('\n%s:\n', label);
    fprintf('Modelo seleccionado = %s\n', bearing.model);
    fprintf('d x D x B = %.1f x %.1f x %.1f mm\n', bearing.bore_mm, bearing.D_mm, bearing.B_mm);
    fprintf('Fr = %.2f lbf, Fa = %.2f lbf, Fe = %.2f lbf\n', bearing.Fr_lbf, bearing.Fa_lbf, bearing.Fe_lbf);
    fprintf('C requerido = %.2f lbf\n', bearing.Creq_lbf);
    fprintf('C catalogo  = %.2f lbf\n', bearing.C_lbf);
    fprintf('C0 catalogo = %.2f lbf\n', bearing.C0_lbf);
    fprintf('Vida 99%% = %.1f h\n', bearing.life_h_99);
    fprintf('Velocidad limite = %.0f rpm\n', bearing.limit_speed);
end

function reportCheck(name, value, requirement, ok)
    if isnumeric(value)
        if abs(value - round(value)) < 1e-9
            valueStr = sprintf('%.0f', value);
        else
            valueStr = sprintf('%.4f', value);
        end
    else
        valueStr = char(string(value));
    end
    fprintf('%-45s valor = %-12s requerido: %-15s -> %s\n', name, valueStr, requirement, cumple(ok));
end

function txt = cumple(ok)
    if ok
        txt = 'CUMPLE';
    else
        txt = 'NO CUMPLE';
    end
end