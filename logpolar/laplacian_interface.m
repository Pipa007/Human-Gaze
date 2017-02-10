%CLASS_INTERFACE Example MATLAB class wrapper to an underlying C++ class
classdef laplacian_interface < handle
    properties (SetAccess = private, Hidden = true)
        objectHandle; % Handle to the underlying C++ class instance
    end
    methods
        %% Constructor - Create a new C++ class instance 
        function this = laplacian_interface(varargin)
            this.objectHandle = laplacian_interface_mex('new', varargin{:});
        end
        
        %% Destructor - Destroy the C++ class instance
        function delete(this)
            laplacian_interface_mex('delete', this.objectHandle);
        end
        
        %% get pyramid
        function varargout = get_pyramid(this, varargin)
            [varargout{1:nargout}] = laplacian_interface_mex('get_pyramid', this.objectHandle, varargin{:});
        end
        
        function varargout = foveate(this, varargin)
            [varargout{1:nargout}] = laplacian_interface_mex('foveate', this.objectHandle, varargin{:});
        end
        
    end
end