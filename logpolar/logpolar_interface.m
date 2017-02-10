%CLASS_INTERFACE Example MATLAB class wrapper to an underlying C++ class
classdef logpolar_interface < handle
    properties (SetAccess = private, Hidden = true)
        objectHandle; % Handle to the underlying C++ class instance
    end
    methods
        %% Constructor - Create a new C++ class instance 
        function this = logpolar_interface(varargin)
            this.objectHandle = logpolar_interface_mex('new', varargin{:});
        end
        
        %% Destructor - Destroy the C++ class instance
        function delete(this)
            logpolar_interface_mex('delete', this.objectHandle);
        end

        %% To cortical
        function varargout = to_cortical(this, varargin)
            [varargout{1:nargout}] = logpolar_interface_mex('to_cortical', this.objectHandle, varargin{:});
        end
        
        %% To cartesian
        function varargout = to_cartesian(this, varargin)
            [varargout{1:nargout}] = logpolar_interface_mex('to_cartesian', this.objectHandle, varargin{:});
        end              
    end
end