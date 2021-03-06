function [ nodes, edges, node_classes, failed ] = construct_fastEGNG_classifier( Data, classLabels, NumOfEpochs, NumOfSamples, lambda)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 % Unsupervised Self Organizing Map. Growing Neural Gas (GNG) Algorithm.

% Main paper used for development of this neural network was:
% Fritzke B. "A Growing Neural Gas Network Learns Topologies", in 
%                         Advances in Neural Information Processing Systems, MIT Press, Cambridge MA, 1995.

% Check label data
if size(classLabels, 1) > 1
    if size(classLabels, 2) > 1
        error('Incorrect label data format!');
    else
        classLabels = classLabels';
    end
end

% Check data sample number
if NumOfEpochs*NumOfSamples > size(Data, 2)
    error('Not enough data provided!');
end

%clc;
%clear;
close all;
colordef black
%NumOfEpochs   = 600;
%NumOfSamples = 400;
age_inc               = 1;
max_age             = 100;
max_nodes         = 300;
eb                         = .05;
en                         = .005;
%lamda                   = 0.5;
alpha                    = .5;     % q and f units err reduction constant.
d                           = .99;   % err reduction factor.
RMSE                  = zeros(1,NumOfEpochs);

% load local_circular_2d1.mat
% load local_circular_2d2.mat;
% load local_sphere_shell.mat;
% load local_torus.mat;
% load local_uniform_2d.mat
% load local_quartersphere.mat;
% load multi_manifold_3d.mat;
 
% Define the params vector where the GNG algorithm parameters are stored:
params = [ age_inc;
                    max_age;
                    max_nodes;
                    eb;
                    en;
                    alpha;
                    lambda;
                    d;
                    0;   % Here, we insert the sample counter.
                    1;   % This is reserved for s1 (bmu);
                    2;]; % This is reserved for s2 (secbmu);

Cur_RMSE = zeros(1,NumOfEpochs);
RMSE = [];
Epoch = [];
Cur_NumOfNodes = [];

% Step.0 Start with two neural units (nodes) selected from input data:
NumOfNodes = 2;
nodes = [Data(:,1)  Data(:,2)];
node_classes = [ ];
fixed_nodes = uint8([0 0]);
failed = 0;

% Initial connections (edges) matrix.
edges = [0  1;
                1  0;];
     
% Initial ages matrix.
ages = [ NaN  0;
               0  NaN;];

% Initial err Vector.
%err = [0 0];

% scrsz = get(0,'ScreenSize');
% figure('Position',[scrsz(3)/2 scrsz(4)/3-50 scrsz(3)/2 2*scrsz(4)/3])
tic
while ~all(fixed_nodes)
    if toc>60
        %dbstop in construct_fastEGNG_classifier at 90;
        tic;
        failed = 1;
        return
    end
for kk=1:NumOfEpochs
    
    
    % Choose the next Input Training Vectors.
    nextblock = (kk-1)*NumOfSamples+1:1:kk*NumOfSamples;

    % Step.1 Generate an input signal � according to P(�).
    In = Data(:,nextblock);
    %In = Data;

    for n=1:NumOfSamples

    params(9) = n;

    % Step 2. Find the two nearest units s1 and s2 to the new data sample.
    [s1 s2 distances] = findTwoNearest(In(:,n),nodes);
    params(10) = s1;
    params(11) = s2;

    % Steps 3-6. Increment the age of all edges emanating from s1 .
    [nodes, edges, ages, fixed_nodes, node_classes] = edgeManagementF(In(:,n),nodes,edges,ages,fixed_nodes,node_classes,distances, params);

    % Step 7. Dead Node Removal Procedure.
    [nodes, edges, ages, fixed_nodes, node_classes] = removeUnconnectedF(nodes, edges,ages,fixed_nodes,node_classes);

    end

    

     %% Refresh drawing buffers
%     NumOfNodes = size(nodes,2);
%     Cur_NumOfNodes = [Cur_NumOfNodes NumOfNodes];
%     if length(Cur_NumOfNodes)>100
%         Cur_NumOfNodes = Cur_NumOfNodes(end-100:end);
%     end
% 
%     Cur_RMSE(kk) = norm(err)/sqrt(NumOfNodes);
%     RMSE = [RMSE Cur_RMSE(kk)];
%     if length(RMSE)>100
%         RMSE = RMSE(end-100:end);
%     end
% 
%     Epoch = [Epoch kk];
%     if length(Epoch)>100
%         Epoch = Epoch(end-100:end);
%     end

      %% Plot everything
%      subplot(1,2,1);
%      plotgng(nodes,edges,'n');
%      % xlim([-1/2 2.5]);
%      % ylim([-1 8]);
%      % zlim([-1/2 1.5]);
%      % xlim([-1 6]);
%      % ylim([-1 6]);
%      % zlim([-7 7]);
%      drawnow;
%  
%      subplot(2,2,2);
%      plot(Epoch,0,'r.');
%      title('RMS err');
%      if kk>100
%           xlim([Epoch(1) Epoch(end)]);
%      end
%      xlabel('Training Epoch Number');
%      grid on;
%  
%      subplot(2,2,4);
%      plot(Epoch,Cur_NumOfNodes,'g.');
%      title('Number of Neural Units in the Growing Neural Gas');
%      if kk>100
%        xlim([Epoch(1) Epoch(end)]);
%      end
%      xlabel('Training Epoch Number');
%      grid on;
%      M(kk)=getframe(gcf);
end

if size(nodes,2)>= NumOfEpochs*NumOfSamples
    disp(lambda);
    error('Neural gas did not converge!');
end
end
%NumOfNodes = size(nodes,2);

nearest_indices = knnsearch(Data', nodes');

node_classes = classLabels(:,nearest_indices);
end
