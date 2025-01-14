clear;
close all;
clc;
addpath('mytoolbox');   


%%
load('madgwick_gps_values2');
%rem = 50;
%rem = 316;
rem = 316;
lat_lte = lat_list(1:end-rem);
lng_lte = lng_list(1:end-rem);
yaw_lte = yaw_list(1:end-rem);

% i = 1;
% while i*2 < length(lat_lte)
%     lat_lte(i*2)=[];
%     lng_lte(i*2)=[];
%     yaw_lte(i*2)=[];
%     i = i+1;
% end

figure('units','normalized','outerposition',[0.2 0.2 0.8 0.8])
plot(lng_lte,lat_lte,'Color','r','Marker','.');
hold on
 for i = 1:length(lng_lte)
     plot([lng_lte(i),lng_lte(i)+0.0002*cos(yaw_lte(i))], [lat_lte(i),lat_lte(i)+0.0002*sin(yaw_lte(i))],'-b');
     hold on
 end
grid on
xlabel('Longitude (in �)');
ylabel('Latitude (in �)');
xlim([12.923 12.937]);
ylim([50.805 50.812]);
%pbaspect([1 1 1]);

%webmap opentopomap     % Open a web map
%wmline(lat_lte,lng_lte,'LineWidth',3,'Color','r')     % Plot the glider path track on the basemap

%%
load('record_data2');
rem = 316;
lat = gps1List(:,1);
lng = gps1List(:,2);

% i = 1;
% while i*2 < length(lat_lte)
%     lat_lte(i*2)=[];
%     lng_lte(i*2)=[];
%     yaw_lte(i*2)=[];
%     i = i+1;
% end

figure('units','normalized','outerposition',[0.2 0.2 0.8 0.8])
plot(lng,lat,'Color','r','Marker','.');
grid on
xlabel('Longitude (in �)');
ylabel('Latitude (in �)');

webmap opentopomap     % Open a web map
wmline(lat,lng,'LineWidth',3,'Color','r')     % Plot the glider path track on the basemap

%% Read data and 2D
% Initialize data
load('record_data2');
rem = 142;
lat = gps1List(:,1);
lng = gps1List(:,2);
accL = accList(rem:end,:);
gyrL = gyrList(rem:end,:);
headL = gps2List(:,1);
velL = gps2List(:,2);
deltatL = time;

x_list = zeros([0 4]);

% Initialize figure
figure('units','normalized','outerposition',[0.2 0.2 0.8 0.8])
l = animatedline('Color','r','Marker','.');
title('Crossing points of the 2D Kalman Filter');
xlabel('longitude (�)');
ylabel('latitude (�)');
grid on
pbaspect([1 1 1]);

% Initialize map
name = 'opentopomap';     % Define the name that you will use to specify your custom basemap.
url = 'a.tile.opentopomap.org';     % Specify the website that provides the map data
copyright = char(uint8(169));     % Create an attribution to display on the map that gives credit to the provider of the map data
attribution = [ ...
      "map data:  " + copyright + "OpenStreetMap contributors,SRTM", ...
      "map style: " + copyright + "OpenTopoMap (CC-BY-SA)"];
displayName = 'Open Topo Map';     % Define the name that will appear
addCustomBasemap(name,url,'Attribution',attribution,'DisplayName',displayName)     % Add the custom basemap to the list of basemap layers available.


% Kalman filter initialization
std_lat = 1.7;
std_lng = 1.3;
std_vel = 0.05;
std_head = 0.3*pi/180;
std_yrate = 0.1*pi/180;
std_alng = 0.01;
std_alat = 0.01;

H = [1, 0, 0, 0, 0, 0;  % Linearized measurement model matrix H
    0, 1, 0, 0, 0, 0;
    0, 0, 1, 0, 0, 0;
    0, 0, 0, 1, 0, 0;
    0, 0, 0, 0, 1, 0;
    0, 0, 0, 0, 0, 1;
    0, 0, 0, 1, 1, 0];

R = [std_lat^2, 0, 0, 0, 0, 0, 0;  % Measurement covariance matrix R
    0, std_lng^2, 0, 0, 0, 0, 0;
    0, 0, std_head^2, 0, 0, 0, 0;
    0, 0, 0, std_vel^2, 0, 0, 0;
    0, 0, 0, 0, std_yrate^2, 0, 0;
    0, 0, 0, 0, 0, std_alng^2, 0;
    0, 0, 0, 0, 0, 0, std_alat^2];


Q = [10*(20*pi/180)^2, 0;  % Process noise covariance matrix Q
    0, 1000];

x = zeros([6 1]);  % Initialization of x and P              
P = R(1:6,1:6);

% Starting point 
coord_init = [lat(1),lng(1)];
lat_old = lat(1);
lng_old = lng(1);

% Read and treat
for i = 2:length(deltatL)
    % Process sensor data through algorithm
    deltat = deltatL(i);
    z = [coord2meter(0, lng(i), 0, lng_old);  % longitude (East shifting) measured in m
        coord2meter(lat(i), 0, lat_old, 0);   % latitude (North shifting) measured in m
        headL(i)*pi/180;                       % heading in rad
        velL(i);                              % velocity in m/s
        gyrL(i,3)*pi/180;                        % yaw rate in rad/s
        accL(i,1);                               % longitudinal acceleration in m/s^2
        accL(i,2)];                              % lateral acceleration in m/s^2  
    %disp(z);
    [x_upd, P_upd] = fusionKalman2D(x, P, z, H, R, Q, deltat);
    x = x_upd;
    P = P_upd;
    lat_old = lat(i);
    lng_old = lng(i);

    % display
    [new_lat, new_lng] = meter2coord(coord_init(1), coord_init(2), x(2), x(1));
    x_list = cat(1, x_list, [new_lng, new_lat, x(3), x(4)]);  % lng,lat,head,vel
    addpoints(l,x_list(end, 1),x_list(end, 2));
    hold on
    %plot([x_list(end, 1),x_list(end, 1)+0.00001*sin(x_list(end,3))],[x_list(end, 2),x_list(end, 2)+0.00001*cos(x_list(end,3))],'-b');
    drawnow limitrate
end

webmap opentopomap     % Open a web map
wmline(x_list(end, 2),x_list(end, 1),'LineWidth',3,'Color','r')     % Plot the glider path track on the basemap