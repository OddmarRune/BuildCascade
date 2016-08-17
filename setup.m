function [ ] = setup(  )
    mypath = userpath;
    addpath(sprintf('%s/lib',mypath(1:end-1)))
    addpath('./lib')
end

