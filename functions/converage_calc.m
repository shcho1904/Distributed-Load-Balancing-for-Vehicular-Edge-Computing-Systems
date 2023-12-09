function Covered_distance = converage_calc(TX_POWER_dB_BS, thresholds)

r1 = [1:10000]';

% noise and interference power
AWGN_POWER_DB = -174; % dBm/Hz
AWGN_POWER_LN = 10^(-3).*db2pow(AWGN_POWER_DB).*20.*10^6; %Linear

%LoS
PL_BS1 = 64.4032+(r1>10).*(22*log10(r1)-22);

%NLoS
% PL_BS1 = 22+28+14.4032+(r1>10).*(30*log10(r1)-30);

RX_POWER_dB_BS1 = TX_POWER_dB_BS - PL_BS1;
Interfer_BS1 = db2pow(RX_POWER_dB_BS1); %Linear

%RX_POWER
RX_POWER_BS1 = Interfer_BS1;

%Rate_1 no interference
SNIR1 = (RX_POWER_BS1)./AWGN_POWER_LN;
% pow2db(SNIR1)
T = SNIR1 > db2pow(thresholds);
Covered_distance = sum(T);
end