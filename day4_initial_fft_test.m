% day4_initial_fft_test
% Luke Waszyn - SDR RF Receiver Project
% Day 4 Control Test - RTL-SDR Stock & Dipole Antenna
% Objective: Capture raw I/Q and verify FM carriers in spectrum (V1)

% Parameters
fc = 100.1e6; % Center frequency (Hz) (Can vary from 88-108 MHz, testing at 100.1)
Fs = 2.4e6; % Sample rate (Hz)
frameLen = 2^16; % Samples per frame
tCapture = 1.0; % seconds total capture

% Gain control:
useAGC  = true; % start with AGC for bring-up
tunerGain = 20; % used if AGC=false

% Create RTL-SDR receiver object
rx = comm.SDRRTLReceiver( ...
    'CenterFrequency',          fc, ...
    'SampleRate',               Fs, ...
    'SamplesPerFrame',          frameLen, ...
    'EnableTunerAGC',           useAGC, ...
    'OutputDataType',           'single');

if ~useAGC
    rx.TunerGain = tunerGain;
end

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

% Remove DC offset (helps spectrum readability)
x = x - mean(x);

% PSD / Spectrum plot
NFFT = 2^15;
[pxx,f] = pwelch(x, hamming(NFFT), round(0.5*NFFT), NFFT, Fs, 'centered');

figure;
plot(f/1e6, 10*log10(pxx));
grid on;
xlabel('Frequency offset from center (MHz)');
ylabel('PSD (dB/Hz)');

title(sprintf('RTL-SDR Control Spectrum: fc = %.3f MHz, Fs = %.1f MS/s', fc/1e6, Fs/1e6));
