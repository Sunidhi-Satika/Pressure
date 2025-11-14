% calibrate_and_plot.m
% Assumes To Workspace blocks created variables:
% P_true_log, V_adc_log (or V_filt_log), P_est_log (if present)
% Each logged variable is an Nx2 array [time, value] if saved as Array.

% --- load / extract
P_true = out.P_true_log.data;
t = out.P_true_log.time;
Vadc = out.Vadc.data;

% Choose steady-state calibration times (midpoints of your step blocks)
calib_times = [2,6,10,14,18]; % change if your step times differ
calib_V = zeros(size(calib_times));
calib_P = zeros(size(calib_times));
for i=1:length(calib_times)
    [~, idx] = min(abs(t - calib_times(i)));
    calib_V(i) = Vadc(idx);
    calib_P(i) = P_true(idx);
end

% Fit linear model P = a*V + b
coeffs = polyfit(calib_V, calib_P, 1);
a = coeffs(1); b = coeffs(2);
fprintf('Calibration fit: P = %.6f * V + %.6f  (kPa)\n', a, b);

% Compute P_est for whole record
P_est = a * Vadc + b;

% Metrics
err = P_est - P_true;
RMSE = sqrt(mean(err.^2));
maxErr = max(abs(err));
fprintf('RMSE = %.4f kPa, max error = %.4f kPa\n', RMSE, maxErr);

% Plots
figure('Name','Calibration & Results');
subplot(2,1,1);
plot(t,P_true,'-','LineWidth',1.2); hold on;
plot(t,P_est,'--','LineWidth',1.2);
xlabel('Time (s)'); ylabel('Pressure (kPa)');
legend('True P','Estimated P'); grid on; title('True vs Estimated');

subplot(2,1,2);
plot(calib_V,calib_P,'o','MarkerSize',8); hold on;
xx = linspace(min(calib_V)*0.98,max(calib_V)*1.02,50);
plot(xx, a*xx + b,'-','LineWidth',1.4);
xlabel('V_{adc} (V)'); ylabel('Pressure (kPa)');
title('Calibration points & fit'); grid on;