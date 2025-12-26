# RTL-SDR-Signal-Processing-Antenna-Systems-Project

This project implements an end-to-end FM-band receive chain using an RTL-SDR v4, a custom-built dipole antenna, and a MATLAB-based DSP pipeline. The system:

- Captures RF in the 88–108 MHz commercial FM band using an RTL-SDR.
- Performs baseband processing and spectrum analysis in MATLAB.
- (In progress) Demodulates broadcast FM to audio for at least one strong station.
- Compares a **custom dipole antenna** against the stock RTL-SDR antenna through structured, repeatable measurements.

The emphasis is on treating this as a small systems / verification project: architecture → hardware build → DSP implementation → experimental characterization → documentation.

---

## Scope and Goals

**Core technical goals:**

- Design and build a custom FM-band dipole (“Dipole v1”) with RG-59 feed and mechanical mounting.
- Integrate the antenna and feed with an RTL-SDR front end and MATLAB (`comm.SDRRTLReceiver`).
- Establish repeatable “standard test configurations” for both:
  - Stock RTL-SDR antenna (control).
  - Custom Dipole v1 (final hardware).
- Verify basic RF functionality via PSD/FFT (FM carriers visible under known conditions).
- Experimentally characterize antenna behavior via:
  - Orientation changes (0°, 90°, 180°).
  - Placement / environment changes (porch mounting, height, proximity to structures).
  - Receiver gain settings (AGC vs fixed gain).
- Implement a narrowband FM demodulation chain in MATLAB and compare demodulated audio quality between antennas.
- Use numerical utilities originally developed for ESC 407H (FFT-based analysis, least-squares fitting, etc.) to quantify results (e.g., simple SNR-like metrics vs gain or orientation).

---

## Project Structure

The repository is organized to separate DSP code, data, hardware details, and experiment notes:

- `matlab/` – MATLAB scripts and DSP blocks
  - RTL-SDR bring-up and I/Q capture scripts.
  - PSD/FFT analysis scripts (e.g., initial FM-band spectrum tests).
  - (Planned) FM demodulation and metric extraction scripts.
  - (Planned) Reused numerical utilities from ESC 407H (e.g., FFT/peak analysis, least-squares tools).

- `data/` – Captured IQ data and audio outputs
  - Raw I/Q captures for different antennas, orientations, and gains.
  - Demodulated audio segments for selected FM stations (stock vs custom antenna).
  - Intermediate metric files (e.g., peak PSD vs gain, SNR-like values).

- `docs/` – Design and results documentation
  - System architecture (Architecture v0.1 and later revisions).
  - Bill of Materials (RTL-SDR, Dipole v1 materials, coax, connectors, tools).
  - Key figures (PSD plots, orientation/placement comparisons, demod spectra).
  - Final project report (once all verification steps are complete).

- `notes/` – Engineering notebook extracts and working notes
  - Day-by-day logs (Day 1–N) summarizing decisions, tests, and observations.
  - Antenna build/rebuild notes (prototype P0 vs Dipole v1).
  - Test matrices and verification plan (V1–V4 mapping to specific experiments).

---

## Verification Plan

Verification is organized around four main milestones:

- **V1 – Carrier Visibility:**  
  FM carriers clearly visible in PSD for both the stock antenna and the custom Dipole v1 under identical RF/DSP settings.

- **V2 – Orientation & Placement Sensitivity:**  
  Measurable changes in received power and spectra as Dipole v1 is rotated and/or moved between defined test positions, with the stock antenna used as a control reference.

- **V3 – FM Demodulation:**  
  Successful FM demodulation (audio) of at least one strong broadcast station using both antennas, with qualitative and simple quantitative (SNR-like) comparisons.

- **V4 – Quantitative Characterization:**  
  Basic metrics (e.g., peak PSD, noise floor, SNR-like measures) logged versus tuner gain, orientation, and placement; optional curve fits using existing numerical methods utilities.

---

## Status

**As of now:**

- **Hardware**
  - RTL-SDR v4 is installed and operational.
  - Custom Dipole v1 (final hardware) is built: 18 AWG two-conductor dipole on wooden dowel, RG-59 coax feed, soldered joints with electrical tape insulation, SMA pigtail to RTL-SDR.
  - Stock RTL-SDR antenna is available and used as the control configuration.

- **DSP / SDR Integration**
  - MATLAB environment configured with the Communications Toolbox Support Package for RTL-SDR.
  - Baseline script implemented (`day4_initial_fft_test`–style) to:
    - Capture complex I/Q data at a specified FM center frequency.
    - Remove DC offset and estimate PSD using `pwelch`.
  - Initial FM-band spectra successfully captured for:
    - Stock antenna (control).
    - Custom Dipole v1, using consistent RF/DSP parameters.

- **Verification Progress**
  - V1 (carrier visibility) is **functionally achieved** for both antennas.
  - Orientation / placement tests (V2), FM demodulation (V3), and quantitative gain/placement characterization (V4) are **in progress** and being designed using a structured test matrix.

- **Documentation**
  - A dedicated engineering notebook is being maintained with:
    - Day 1–3 logs (project setup, architecture, antenna build).
    - System Architecture v0.1 and exigence/motivation.
    - Antenna build notes (prototype P0 and Dipole v1).
  - The full notebook (scanned pages) and selected photos of the physical hardware and test setups are planned for upload to `docs/` upon project completion, which is expected approximately 10 days after project start (this coming Tuesday).

This repository will be updated as additional verification runs (V2–V4), FM demodulation results, and final analysis are completed.
