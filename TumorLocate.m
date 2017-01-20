function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%   cc c  singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 16-Mar-2016 18:44:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%
% --- Executes on button press in pushbutton1.
%%
function pushbutton1_Callback(hObject, eventdata, handles)

% hObject handle to pushbutton1 (see GCBO)

% eventdata reserved - to be defined in a future version of MATLAB

% handles structure with handles and user data (see GUIDATA)
dirName = uigetdir('*.dcm','select dir file');
setappdata(handles.pushbutton1,'UserData',dirName);
handles.output = hObject;

guidata(hObject, handles);

%%
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
%DicomDir = '/Users/Bhavin/Documents/MATLAB/R_022/Images/'; %current directory

DicomDir=getappdata(handles.pushbutton1,'UserData');
MyFiles = dir(fullfile(DicomDir, '*.dcm')); %%locate  dcm files in directory
mkdir ('/Users/Bhavin/Documents/MATLAB/','NewFolder'); %make new folder to store files
mkdir ('/Users/Bhavin/Documents/MATLAB/','Tumor'); %make new folder to store files
mkdir ('/Users/Bhavin/Documents/MATLAB/','Montage');


delete('/Users/Bhavin/Documents/MATLAB/NewFolder/*.dcm')
NewDir = '/Users/Bhavin/Documents/MATLAB/NewFolder'; %new directory
delete('/Users/Bhavin/Documents/MATLAB/Tumor/*.png')
delete('/Users/Bhavin/Documents/MATLAB/Montage/*.png')

for k=1:length(MyFiles) 
    oldFile = fullfile(DicomDir, MyFiles(k).name);
    Info= dicominfo(oldFile);
    newFile = sprintf('CT%d.dcm\n', Info.InstanceNumber);
    disp(Info.InstanceNumber);
    disp(newFile);
    copyfile(oldFile, fullfile(NewDir, newFile));
end
% disp(dicominfo('000004.dcm'));

NewFiles=dir(fullfile(NewDir,'*.dcm'));
for i = 1:length(NewFiles); 
    filename = strcat('/Users/Bhavin/Documents/MATLAB/NewFolder/',NewFiles(i).name);
%     I = dicomread(filename);
%     I=imadjust(I);
%     figure, imshow(I);
    

A = dicomread(filename);
A1= imadjust(A);
figure, imshow(A1);

%%
B=A1;
B = medfilt2(A1);
%figure, imshow(B);
B=uint16(B);
B=immultiply(B,1.5);
%figure,imshow(B);

%%
imwrite(B,'filt.png','BitDepth',16);
image=imread('filt.png');
imfinfo('filt.png');

pic=imread('filt.png');
filename = sprintf('montage%d.png', i);
imwrite(pic, filename, 'png');
 movefile(filename,'/Users/Bhavin/Documents/MATLAB/Montage/');

% cd '/Users/Bhavin/Documents/MATLAB/Montage/'
% fileFolder = fullfile('/Users/Bhavin/Documents/MATLAB/Montage/');
% dirOutput = dir(fullfile(fileFolder,'montage*.png'));
% fileNames = {dirOutput.name};
% montage(fileNames); 

%%



Iseg = segmentImage2(image);
image=Iseg;
%figure, imshow(Iseg);

%%

open5 = imopen(image,strel('disk',8));
%figure, imshow(open5);
gy2Bw=open5;

%%
imReg=filterRegions1(image);
%figure, imshow(imReg);
figure, imshow(gy2Bw);
 open6=imopen(imReg,strel('disk',22));
 %figure, imshow(open6);
gy2Bw2=open6;
%figure, imshow(gy2Bw2);
Io = imsubtract(gy2Bw,gy2Bw2);

%%
%figure, imshow(Io);
Io=logical(Io);
j=filterEccen(Io);
j2=filterRegion2(j);
j3=filterPerim(j2);
j4=filterOrien(j3);
figure, imshow(j4);
ja=double(j4);

%%

level  = multithresh(ja);
result = nlfilter(ja,[5 5], @(x) x(3,3)>mean(x(:)));
%figure, imshow(result,[]);
BW_filled=result;

%%
cc = bwconncomp(ja, 4);
I3 = B;
I3(BW_filled) = 255;
figure, imshow(I3);
%%
points = detectSURFFeatures(BW_filled);
count =points.length();
%%

if any(count>=1)
figure, imshow(I3); hold on;
strongest = (points.selectStrongest(1));
 plot(strongest);
%%
tumorData= regionprops(cc,'all');
tArea = tumorData().Area;
tPerimeter = tumorData().Perimeter;
timage=tumorData().Image;

tEccent=tumorData().Eccentricity;
 X = ['Tumor Located! With Area Of (?pixels):',num2str(tArea)];
 Y = ['perimeter:',num2str(tPerimeter)];
 Z = ['eccentricity:',num2str(tEccent)];
disp(X)
disp(Y)
disp(Z)

%%
img_out=A1;
img_out(~ja)=0;
figure, imshow(img_out);
glcms = graycomatrix(img_out);
stats = graycoprops(glcms)

filename1=sprintf('Tumor%d.png',i);
imwrite(img_out,filename1);
movefile(filename1,'/Users/Bhavin/Documents/MATLAB/Tumor/');




end;
%%
if any(count==0)  
    imshow(A1); 
    disp('No Tumor Located In This Scan!');
  
end  

end

%
% cd '/Users/Bhavin/Documents/MATLAB/Montage/'
% fileFolder = fullfile('/Users/Bhavin/Documents/MATLAB/Montage/');
% dirOutput = dir(fullfile(fileFolder,'montage*.png'));
% fileNames = {dirOutput.name};
% montage(fileNames); 
% guidata(hObject, handles);




% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)

% hObject handle to pushbutton3 (see GCBO)

% eventdata reserved - to be defined in a future version of MATLAB

% handles structure with handles and user data (see GUIDATA)

imshow('')



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;

cd '/Users/Bhavin/Documents/MATLAB/Montage/'
fileFolder = fullfile('/Users/Bhavin/Documents/MATLAB/Montage/');
dirOutput = dir(fullfile(fileFolder,'montage*.png'));
fileNames = {dirOutput.name};
montage(fileNames); 


imshow(montage);

guidata(hObject, handles);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;

cd '/Users/Bhavin/Documents/MATLAB/Tumor/'
fileFolder = fullfile('/Users/Bhavin/Documents/MATLAB/Tumor/');
dirOutput = dir(fullfile(fileFolder,'Tumor*.png'));
fileNames = {dirOutput.name};
montage(fileNames); 
imshow(montage);

guidata(hObject, handles);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%3d model