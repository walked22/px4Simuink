%% Load the data into MATLAB Workspace from a binary log file
% Usage: >> [datapoints,timestamp, numpoints] = readdata('datafile.bin')
% Header information format:
%           String "MWLOGV"
%           Time/Date 4 bytes (time())
%           Number of Signals per record Logged 1 bytes (256 max)
%           Data Type of Signals Logged  1 bytes (1-10)
%           Number of bytes per record 2 (65535 max)
% Plot Data Example: plot([1:numpoints], datapoints(1,:), [1:numpoints], datapoints(2,:))
% Steve Kuznicki
%   Copyright 2018-2019 The MathWorks, Inc.

function [datapts,timestamp,numpts] = px4_read_binary_file(dataFile)

if nargin == 0
    dataFile = 'data.bin';
end

fid = fopen(dataFile, 'r');
% load the header information
hdrToken = fread(fid, 5, 'char');
if strncmp(char(hdrToken),'MWLOGV',5) == true
    
    logTime = uint32(fread(fid, 1, 'uint32'));
    numflds = double(fread(fid, 1, 'uint8'));
    typefld = uint8(fread(fid, 1, 'uint8'));
    recSize = uint16(fread(fid, 1, 'uint16'));
    
    datapts = [];
    timestamp=[];

    fieldTypeStr = get_elem_type(typefld);

    while(~feof(fid))
        temp= fread(fid,double(numflds), fieldTypeStr);
        datapts=[datapts temp];
        timetemp=fread(fid, 1,'uint64');
        timestamp=[timestamp timetemp];
    end
    
    fclose(fid);
    numpts = size(datapts,2);
end

end

%% get the element type string
function [dtypeStr] = get_elem_type(dtype)
    switch(dtype)
        case 1
            dtypeStr = 'double';
        case 2
            dtypeStr = 'single';
        case 3
            dtypeStr = 'int32';
        case 4
            dtypeStr = 'uint32';
        case 5
            dtypeStr = 'int16';
        case 6
            dtypeStr = 'uint16';
        case 7
            dtypeStr = 'int8';
        case 8
            dtypeStr = 'uint8';
        case 9
            dtypeStr = 'logical';
        case 10
            dtypeStr = 'embedded.fi';
    end
end
