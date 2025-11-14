%% --- Parameters ---
Fs = 500;               % sample rate (Hz)
dt = 1/Fs;
Tend = 20;              % total time (s)
t = (0:dt:Tend)';       % time vector

P_mean = 60;            % mean manifold pressure (kPa)
P_range = 35;           % total dynamic range (kPa)

% low-frequency throttle change (~0.1 Hz)
slow_component = 0.5 * (1 + sin(2*pi*0.05*t));  % 20s period
P_throttle = P_mean + (P_range/2)*(2*slow_component - 1);

% faster oscillation (engine intake pulses ~3 Hz)
engine_ripple = 2.5 * sin(2*pi*3*t);

% small random turbulence/noise (sensor jitter)
noise = 0.5 * randn(size(t));   % ±0.5 kPa approx

% combine all parts
P = P_throttle + engine_ripple + noise;

% clamp to 0–100 kPa range
P(P < 0) = 0;
P(P > 100) = 100;

% create timeseries for Simulink
P_ts = timeseries(P,t);
assignin('base','P_ts',P_ts);