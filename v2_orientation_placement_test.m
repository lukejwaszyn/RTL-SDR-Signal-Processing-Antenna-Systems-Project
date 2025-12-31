% v2_orientation_placement_test
% Luke Waszyn - SDR RF Receiver Project
% V2: Orientation & Placement Sensitivity (Custom Dipole primary, Stock as control snapshots)
% Objective: Capture raw I/Q + PSD under fixed gain and save repeatable artifacts per test ID

clear; clc;

% User-entered run metadata
% Use short, consistent labels. Examples:
%   V2_P1_O0_CUSTOM
%   V2_P1_O90_CUSTOM
%   V2_P2_O180_CUSTOM
%   V2_CTRL_P1_STOCK_START

testID = strtrim(input('Enter Test ID (e.g., V2_P1_O0_CUSTOM): ', 's'));
if isempty(testID)
    error('Test ID cannot be empty.');
end

antennaConfig = strtrim(input('Antenna config (CUSTOM or STOCK): ', 's'));
placementNote = strtrim(input('Placement note (e.g., porch_mount_heightX): ', 's'));
orientationNote = strtrim(input('Orientation note (e.g., 0deg / 90deg / 180deg): ', 's'));

% SDR Parameters (locked for V2)
fc = 100.1e6;   % Center frequency (Hz)
Fs = 2.4e6;     % Sample rate (Hz)
frameLen = 2^16; % Samples per frame
tCapture = 1.0; % seconds total capture

% Fixed gain for V2 comparability
useAGC = false;
tunerGain = 20; % dB (adjust if you want, but keep constant across V2

% Output
outRoot = fullfile('data','v2_runs');
figDir  = fullfile(outRoot,'figures');
iqDir   = fullfile(outRoot,'iq');
metDir  = fullfile(outRoot,'metrics');

if ~exist(figDir,'dir'); mkdir(figDir); end
if ~exist(iqDir,'dir');  mkdir(iqDir);  end
if ~exist(metDir,'dir'); mkdir(metDir); end

% Create a filesystem-safe timestamp
runTimestamp = datestr(now,'yyyy-mm-dd_HHMMSS');

% Create RTL-SDR receiver object
rx = comm.SDRRTLReceiver( ...
    'CenterFrequency', fc, ...
    'SampleRate', Fs, ...
    'SamplesPerFrame', frameLen, ...
    'EnableTunerAGC', useAGC, ...
    'OutputDataType', 'single');

rx.TunerGain = tunerGain;

% Capture loop
nFrames = ceil((tCapture*Fs)/frameLen);
x = complex(zeros(nFrames*frameLen,1,'single'));

idx = 1;
for k = 1:nFrames
    [y, len] = rx();
    if len > 0
        x(idx:idx+len-1) = y;
        idx = idx + len;
    end
end

release(rx);
x = x(1:idx-1);

% Remove DC offset (improves spectrum readability)
x = x - mean(x);

% PSD / Spectrum computation (Welch)
NFFT = 2^15;
[pxx,f] = pwelch(x, hamming(NFFT), round(0.5*NFFT), NFFT, Fs, 'centered');
pxx_dB = 10*log10(pxx);

% Metric extraction (simple + repeatable)
% Peak metric near the expected station/carrier vicinity.
% We operate in "frequency offset from center" (Hz). For a station near fc,
% look within +/- 150 kHz by default.
peakWindowHz = 150e3;
peakMask = (abs(f) <= peakWindowHz);

peakPSD_dBHz = max(pxx_dB(peakMask));
peakFreqOffset_Hz = f(peakMask);
[~, iPk] = max(pxx_dB(peakMask));
peakOffsetAtMax_Hz = peakFreqOffset_Hz(iPk);

% Noise floor estimate: average PSD in an "off-carrier" region.
% Choose a band away from DC where carriers are less likely, adjust if needed.
noiseBandHz = [400e3 900e3]; % use magnitude range of offsets (both sides)
noiseMask = (abs(f) >= noiseBandHz(1)) & (abs(f) <= noiseBandHz(2));
noiseFloor_dBHz = mean(pxx_dB(noiseMask));

% Simple SNR-like metric (not true SNR): peak minus noise floor
snrLike_dB = peakPSD_dBHz - noiseFloor_dBHz;

% Plot + export
fig = figure('Name',testID);
plot(f/1e6, pxx_dB);
grid on;
xlabel('Frequency offset from center (MHz)');
ylabel('PSD (dB/Hz)');
title(sprintf('%s | fc = %.3f MHz | Fs = %.1f MS/s | Gain = %d dB', ...
    testID, fc/1e6, Fs/1e6, tunerGain), 'Interpreter','none');

subtitleStr = sprintf('Antenna: %s | Placement: %s | Orientation: %s | %s', ...
    antennaConfig, placementNote, orientationNote, runTimestamp);
try
    subtitle(subtitleStr, 'Interpreter','none');
catch
    % If subtitle() not available in your MATLAB version, ignore.
end

figFile = fullfile(figDir, sprintf('%s_%s.png', testID, runTimestamp));
exportgraphics(fig, figFile, 'Resolution', 300);

% Save raw I/Q + metadata
iqFile = fullfile(iqDir, sprintf('%s_%s_IQ.mat', testID, runTimestamp));
meta = struct();
meta.testID = testID;
meta.timestamp = runTimestamp;
meta.antennaConfig = antennaConfig;
meta.placementNote = placementNote;
meta.orientationNote = orientationNote;
meta.fc = fc;
meta.Fs = Fs;
meta.frameLen = frameLen;
meta.tCapture = tCapture;
meta.useAGC = useAGC;
meta.tunerGain = tunerGain;
meta.NFFT = NFFT;

save(iqFile, 'x', 'meta', '-v7.3');

% Save metrics summary
metrics = struct();
metrics.peakWindowHz = peakWindowHz;
metrics.peakPSD_dBHz = peakPSD_dBHz;
metrics.peakOffsetAtMax_Hz = peakOffsetAtMax_Hz;
metrics.noiseBandHz = noiseBandHz;
metrics.noiseFloor_dBHz = noiseFloor_dBHz;
metrics.snrLike_dB = snrLike_dB;

metFile = fullfile(metDir, sprintf('%s_%s_metrics.mat', testID, runTimestamp));
save(metFile, 'metrics', 'meta');

% Console printout
fprintf('\n--- V2 Run Complete ---\n');
fprintf('Test ID: %s\n', testID);
fprintf('Antenna: %s\n', antennaConfig);
fprintf('Placement: %s\n', placementNote);
fprintf('Orientation: %s\n', orientationNote);
fprintf('Peak PSD (within +/- %.0f kHz): %.2f dB/Hz at offset %.0f Hz\n', ...
    peakWindowHz/1e3, peakPSD_dBHz, peakOffsetAtMax_Hz);
fprintf('Noise floor (%.0f–%.0f kHz offset band): %.2f dB/Hz\n', ...
    noiseBandHz(1)/1e3, noiseBandHz(2)/1e3, noiseFloor_dBHz);
fprintf('SNR-like (peak - noise floor): %.2f dB\n', snrLike_dB);
fprintf('Saved figure: %s\n', figFile);
fprintf('Saved I/Q:    %s\n', iqFile);
fprintf('Saved metrics:%s\n\n', metFile);
