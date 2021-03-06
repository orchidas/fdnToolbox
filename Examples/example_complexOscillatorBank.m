% Test complexOscillatorBank 
% 
% Sebastian J. Schlecht, Wednesday, 1 January 2020
clear; clc; close all;

rng(1);

%% Define 
N = 4;
cyclesPerSample = [1 1 1.2 1.2] / 1000;
amplitude = [0.2 0.2 0.33 0.33];

complexConjugateSign = [1 -1 1 -1];
oscAmplitude = complexConjugateSign .* amplitude;
osc = complexOscillatorBank( cyclesPerSample, oscAmplitude);

%% Compute
output = [];
for it = 1:10
    len = randi([500, 1500], 1);
    output = [output; osc.get(len)];
end

%% plot
figure(1); hold on; grid on;
plot(abs(output))
plot(angle(output))
xlabel('Time [samples]')
ylabel('Absolute value and angle')