# RTL-SDR Signal Processing & Antenna System Project

This project implements an end-to-end FM-band receive system using an RTL-SDR v4, a custom-built dipole antenna, and a MATLAB-based digital signal processing (DSP) pipeline. The system captures RF signals in the 88–108 MHz commercial FM broadcast band, performs baseband processing and spectral analysis, and supports narrowband FM demodulation for broadcast audio recovery.

The work is intentionally structured as a small **systems and verification effort**, progressing from architecture definition and hardware integration through DSP implementation and experimental characterization using repeatable test configurations.

---

## Scope and Objectives

**Primary technical objectives:**

- Design, construct, and integrate a custom FM-band dipole antenna with RG-59 coax feed and SMA interface.
- Interface the antenna and RF front end with an RTL-SDR v4 and a MATLAB-based DSP pipeline using `comm.SDRRTLReceiver`.
- Define and execute repeatable standard test configurations for:
  - Stock RTL-SDR antenna (control configuration)
  - Custom dipole antenna (primary hardware)
- Verify RF functionality via PSD/FFT analysis with identifiable FM carriers under controlled conditions.
- Characterize antenna behavior through controlled experiments involving:
  - Orientation changes (0°, 90°, 180°)
  - Placement and environment changes (mounting height, proximity to structures)
  - Receiver gain settings (AGC versus fixed gain)
- Perform narrowband FM demodulation and compare recovered audio quality between antenna configurations.
- Quantify results using FFT-based analysis and least-squares methods via existing numerical utilities.

---

## Project Structure

The repository is organized to clearly separate DSP implementation, experimental data, documentation, and engineering notes:

- `matlab/` – DSP implementation and test scripts  
  - RTL-SDR bring-up and environment sanity checks  
  - I/Q capture and PSD/FFT-based spectral analysis  
  - FM demodulation and metric extraction  
  - Numerical utilities for FFT analysis, peak detection, and least-squares fitting

- `data/` – Captured data products  
  - Raw complex I/Q captures for different antennas, orientations, and gain settings  
  - Demodulated audio outputs for selected FM stations  
  - Intermediate metric files used for analysis

- `docs/` – Design documentation and results  
  - System architecture diagrams (Architecture v0.1)  
  - Bill of Materials (BOM) reflecting current hardware configuration  
  - Figures (PSD comparisons, orientation and placement studies, demodulation results)  
  - Final report upon completion of verification activities

- `notes/` – Engineering notebook extracts  
  - Day-by-day handwritten logs (Day 1–N)  
  - Antenna build and revision notes  
  - Exigence and motivation pages  
  - Test matrices mapping experiments to verification milestones

---

## Verification Plan

Verification activities are organized around four primary milestones:

- **V1 – Carrier Visibility**  
  FM carriers are clearly visible in PSD measurements for both the stock antenna and the custom dipole under identical RF and DSP settings.

- **V2 – Orientation and Placement Sensitivity**  
  Measurable changes in received power and spectral characteristics are observed as the custom dipole is rotated and repositioned, with the stock antenna used as a control reference.

- **V3 – FM Demodulation**  
  Verified FM demodulation of at least one strong broadcast station using both antenna configurations, with qualitative and simple quantitative (SNR-like) comparisons of recovered audio.

- **V4 – Quantitative Characterization**  
  Basic metrics (e.g., peak PSD, estimated noise floor, SNR-like measures) logged versus tuner gain, antenna orientation, and placement, with optional curve fitting using existing numerical methods utilities.

---

## Status

### Hardware
- RTL-SDR v4 installed and operational.
- Custom FM-band dipole antenna constructed and integrated using RG-59 coax feed, soldered joints, and SMA pigtail interface.
- Stock RTL-SDR antenna retained and used as the control configuration.

### DSP / SDR Integration
- MATLAB environment configured with the Communications Toolbox Support Package for RTL-SDR.
- Environment sanity check completed and passed.
- Baseline I/Q capture and spectral analysis implemented, including DC offset removal and PSD estimation via `pwelch`.
- FM-band spectra successfully captured for both control and custom antenna configurations using consistent RF and DSP parameters.

### Verification Progress
- V1 (carrier visibility) achieved for both antennas.
- V2–V4 verification activities in progress using a structured test matrix covering orientation, placement, and gain.

### Documentation
A handwritten engineering notebook is being maintained, including day-by-day logs, system architecture revisions, antenna build notes, and verification planning. Scanned notebook pages and selected photos of the physical hardware and test setups are uploaded under `docs/` as supporting artifacts.

This repository will continue to be updated as additional verification runs, FM demodulation results, and final analysis are completed.

---

## Notes on Methodology

This project emphasizes **measured performance and verification**, rather than simulation-only results. All analysis is based on captured RF data from physical hardware, with consistent test configurations used to enable meaningful comparisons between antenna setups.

Design revisions and experimental decisions are documented in the engineering notebook and reflected in subsequent verification runs.
