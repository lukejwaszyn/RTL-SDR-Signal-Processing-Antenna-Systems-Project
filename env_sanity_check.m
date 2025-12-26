% env_sanity_check.m
% Luke Waszyn - SDR RF Receiver Project
% Purpose: Verify MATLAB environment supports complex DSP workflow
% (FFT/PSD, filtering, resampling, audio playback, file I/O).

% Expected outcome:
% 1) FFT shows a tone at +100 kHz
% 2) PSD shows correct peak and noise floor behavior
% 3) Filtered signal has reduced out-of-band energy
% 4) Resampling runs without error
% 5) Short Audio tone plays without clipping

% Parameters
Fs  = 1.0e6; % synthetic IQ sample rate (Hz)
T   = 0.25; % duration (s)
N   = round(Fs*T); % samples
f0  = 100e3; % complex tone frequency (Hz)
snr_dB = 15; % SNR for synthetic test

rng(1); % repeatability

% Generate synthetic complex IQ: tone + noise
n = (0:N-1).';
x_clean = exp(1j*2*pi*f0*n/Fs);

% Add complex AWGN at desired SNR
sigP = mean(abs(x_clean).^2);
noiseP = sigP / (10^(snr_dB/10));
w = sqrt(noiseP/2) * (randn(N,1) + 1j*randn(N,1));
x = x_clean + w;

% FFT check (magnitude spectrum)
X = fftshift(fft(x));
f = linspace(-Fs/2, Fs/2, N).';

figure;
plot(f/1e3, 20*log10(abs(X)/max(abs(X))), 'LineWidth', 1);
grid on;
xlabel('Frequency (kHz)');
ylabel('Normalized Magnitude (dB)');
title('FFT Sanity Check: Complex Tone at +100 kHz');
xlim([-500 500]);

% PSD check using Welch
[Px, fw] = pwelch(x, hann(8192), 4096, 8192, Fs, 'centered');

figure;
plot(fw/1e3, 10*log10(Px), 'LineWidth', 1);
grid on;
xlabel('Frequency (kHz)');
ylabel('PSD (dB/Hz)');
title('PSD Sanity Check (pwelch)');
xlim([-500 500]);

% FIR low-pass filter check (simulate channel filtering)
% Keep only +/-150 kHz
fc_lp = 150e3;
Wn = fc_lp/(Fs/2);
L  = 201; % odd length for linear-phase FIR
b  = fir1(L-1, Wn, 'low', hann(L));

x_filt = filter(b, 1, x);

[Pf, ff] = pwelch(x_filt, hann(8192), 4096, 8192, Fs, 'centered');

figure;
plot(fw/1e3, 10*log10(Px), 'LineWidth', 1); hold on;
plot(ff/1e3, 10*log10(Pf), 'LineWidth', 1);
grid on;
xlabel('Frequency (kHz)');
ylabel('PSD (dB/Hz)');
title('Filter Sanity Check: PSD Before vs After LPF');
legend('Before filter','After filter','Location','best');
xlim([-500 500]);

% Resampling check (simulate path to audio sample rates)
x_dec4 = decimate(x_filt, 4);  % 1e6 -> 250k
x_dec5 = decimate(x_dec4, 5);  % 250k -> 50k
Fs_audio = Fs/(4*5);

fprintf('Resampling sanity: Fs -> %.0f Hz\n', Fs_audio);

% Audio output check (short tone)
doAudio = true;

if doAudio
    Fs_play = 44100;
    t = (0:Fs_play*0.5-1)'/Fs_play;
    y = 0.2*sin(2*pi*440*t);
    fprintf('Playing 440 Hz test tone...\n');
    sound(y, Fs_play);
end

% Save log file
outDir = fullfile(pwd, 'notes');
if ~exist(outDir), mkdir(outDir); end

logFile = fullfile(outDir, 'env_sanity_check_log.txt');
fid = fopen(logFile, 'a');
if fid ~= -1
    fprintf(fid, 'env_sanity_check run: %s\n', datestr(now));
    fprintf(fid, 'Fs=%.0f, f0=%.0f, SNR=%0.1f dB, FIR L=%d, Audio=%d\n\n', Fs, f0, snr_dB, L, doAudio);
    fclose(fid);
    fprintf('Wrote log: %s\n', logFile);
else
    warning('Could not write log file.');
end

fprintf('Environment sanity check complete.\n');