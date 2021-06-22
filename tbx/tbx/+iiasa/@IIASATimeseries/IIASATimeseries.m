classdef IIASATimeseries
    
    % Copyright 2020-2021 The MathWorks, Inc.
    
    properties (SetAccess = private)
        Model    (1,1) string
        Scenario (1,1) string
        Variable (1,1) string
        Region   (1,1) string
        Unit     (1,1) string
        RunId    (1,1) double
        Version  (1,1) double
        Years    (:,1) double
        Values   (:,1) double
    end
    
    methods
        idx = ismember(obj, ts)
    end
    
    methods
        
        function obj = IIASATimeseries(Data)
            
            if nargin > 0 && ~isempty(Data)
                
                m = size(Data,1);
                n = size(Data,2);
                obj(max(m,n),1) = obj;
                
                for i = 1 : numel(Data)
                    data = Data(i);
                    obj(i).Model = data.model;
                    obj(i).Scenario = data.scenario;
                    obj(i).Variable = data.variable;
                    obj(i).Region = data.region;
                    obj(i).Unit = data.unit;
                    obj(i).RunId = data.runId;
                    obj(i).Version = data.version;
                    obj(i).Years = data.years;
                    obj(i).Values = data.values;
                end
            end
            
        end
        
        function [h,l] = plot(obj, varargin)
            
            if ~isempty(obj)
                try 
                    h = plot([obj.Years], [obj.Values], varargin{:});
                catch
                    
                    h = plot(obj(1).Years, obj(1).Values, varargin{:});
                    hold(h(1).Parent,'on')
                    for i = 2 : length(obj)
                        h(i) = plot(obj(i).Years, obj(i).Values, varargin{:});
                    end
                    hold(h(1).Parent,'off')
                end
                axis(h(1).Parent,'tight');
                xlabel(h(1).Parent,'Years');

                units = unique([obj.Unit]);
                if numel(units) == 1
                    ylabel(h(1).Parent, "Units:   " + units);
                else
                    ylabel(h(1).Parent, "Multiple Units ");
                end

                str = igetLegend(obj);
                l = legend(h(1).Parent,str,'Location','best','Interpreter','none');
            else
                h = [];
            end
                         
        end
        
        function [h,l] = bar(obj, varargin)
            
            if ~isempty(obj)
                
                h = bar([obj.Years], [obj.Values], varargin{:});
                
                axis(h(1).Parent,'tight');
                xlabel(h(1).Parent,'Years');

                units = unique([obj.Unit]);
                if numel(units) == 1
                    ylabel(h(1).Parent, "Units:   " + units);
                else
                    ylabel(h(1).Parent, "Multiple Units ");
                end

                str = igetLegend(obj);
                l = legend(h(1).Parent,str,'Location','best','Interpreter','none');
            else
                h = [];
            end
            
        end
        
        function value = uniqueRegions(obj)
           value = unique([obj.Region]); 
        end
        
        function value = uniqueVariables(obj)
           value = unique([obj.Variable]); 
        end
        
        function value = uniqueModels(obj)
           value = unique([obj.Model]); 
        end
        
        function value = uniqueScenarios(obj)
           value = unique([obj.Scenario]); 
        end
        
        function lst = getRunList(obj)
            lst = table( ...
                [obj.Model]',[obj.Scenario]',[obj.Variable]',[obj.Region]',[obj.RunId]',[obj.Version]', ...
                'VariableNames',{'Model','Scenario','Variable','Region','RunId','Verison'}...
                );
        end
        
    end
    
end

function str = igetLegend(dt)

str = "";
str = iaddVarToLegend(str,'Model',[dt.Model]);
str = iaddVarToLegend(str,'Scenario',[dt.Scenario]);
str = iaddVarToLegend(str,'Variable',[dt.Variable]);
str = iaddVarToLegend(str,'Region',[dt.Region]);
str = iaddVarToLegend(str,'Id',[dt.RunId]);

if numel(str) == 1
    str = "Region = " + unique(dt.Region);
end

end

function str = iaddVarToLegend(str,var,data)

if isnumeric(data)
    format = '%s = %d';
else
    format = '%s = %s';
end

if length(unique(data)) ~= 1
    if numel(str) == 1
        str = str + arrayfun(@(x) string(sprintf('%s = %s',var(1),x)) , data);
    else
        str = str + arrayfun(@(x) string(sprintf(", " + format,var(1),x)) , data);
    end
end

end