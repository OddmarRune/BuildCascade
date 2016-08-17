function [ out ] = CheckOption(Options, opt, status)
    out = strcmpi(Options.(opt), status);
end

