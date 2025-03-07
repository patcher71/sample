function varargout = CurveFit_v1(varargin)
% CURVEFIT_V1 MATLAB code for CurveFit_v1.fig
%      CURVEFIT_V1, by itself, creates a new CURVEFIT_V1 or raises the existing
%      singleton*.
%
%      H = CURVEFIT_V1 returns the handle to a new CURVEFIT_V1 or the handle to
%      the existing singleton*.
%
%      CURVEFIT_V1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CURVEFIT_V1.M with the given input arguments.
%
%      CURVEFIT_V1('Property','Value',...) creates a new CURVEFIT_V1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CurveFit_v1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CurveFit_v1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Edit the above text to modify the response to help CurveFit_v1
% Last Modified by GUIDE v2.5 07-Mar-2025 14:32:47
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CurveFit_v1_OpeningFcn, ...
                   'gui_OutputFcn',  @CurveFit_v1_OutputFcn, ...
                   'gui_LayoutFcn', [], ...  % Corrected line
                   'gui_Callback', []), ... % Corrected line         
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1}); 
end  % The 'if' statement was correctly closed

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before CurveFit_v1 is made visible.
function CurveFit_v1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CurveFit_v1 (see VARARGIN)
% Choose default command line output for CurveFit_v1
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes CurveFit_v1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% --- Outputs from this function are returned to the command line.
function varargout = CurveFit_v1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;

function EndCursorEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EndCursorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function StartCursorEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartCursorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end