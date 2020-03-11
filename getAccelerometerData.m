%GETACCELEROMETERDATA

%This script works along with the px4demo_serial model. This script needs
%to be executed only after building and loading the above mentioned demo
%model onto the Pixhawk board.

%This script reads and displays the accelerometer data sent by the px4demo_serial
%running on the pixhawk board via serial (/dev/ttyACM0).

% Copyright 2019 The MathWorks, Inc.

%change the comport value below to the one on which the Pixhawk board is
%connected on your Host machine
comport = 'COM15';
delete(instrfind('Port',comport));

%open serial object
s = serial(comport);
%The Baudrate of 115200 is set on the Pixhawk board as well in the
%px4demo_serial model
s.BaudRate = 115200;
try
    fopen(s);

    headerToSend = uint8([7 7]);
    packetToSend = uint8([9 9 9]);
    
    %Data to Send
    dataToSend = [headerToSend packetToSend headerToSend packetToSend];
    
    %Initialize the variable to store the data which is to be received
    data = [];
    
    %Send the data to the pixhawk hardware. The pixhawk hardware on
    %receiving this dataToSend, parses it, verifies if the data is correct
    %and only then sends the accelerometer data back to the host
    fwrite(s,dataToSend);
    
    %wait for half a sec before reading the data sent by the board.
    pause(0.5);
    
    %Read the accelerometer data sent by the pixhawk board. The
    %accelerometer data are 3 single precision values(12 bytes). The header
    %associated with this data is [5 5]. Hence expectedDataLength = 14
    expectedDataLength = 14;
    data = fread(s,expectedDataLength);
       
    %close the connection after reading
    fclose(s);
    delete(s);
    
catch ME
    disp(ME.message)
end

if isempty(data)
    disp('Unable to read any data.');
else
    
    %Logic to find the packet after stripping the header
    data = data';
    header = [5 5];
    
    %Find the starting indices of 'header' in the 'data' received. It is
    %expected to be 1 in this case
    k = strfind(data,header);
    
    if ~isempty(k) && any(ismember(k,1))
        %get the packet data by stripping the header
        packet = data(length(header)+1:expectedDataLength);
    end
    
    % The accel values are in the order x, y, and z.
    accx = typecast(uint8(packet(1:4)),'single');
    accy = typecast(uint8(packet(5:8)),'single');
    accz = typecast(uint8(packet(9:12)),'single');
    
    %display the accel data on screen
    disp(['Accelerometer data(x | y | z) in m/s^2: ', num2str(accx),' | ', num2str(accy), ' | ', num2str(accz), '.'])
end