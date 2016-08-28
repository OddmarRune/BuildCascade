function [ ] = WriteResult( Cooler, Gas, Filename )
    if nargin<3
        fid = 1;
    elseif ischar(Filename)
        fid = fopen(Filename,'a');
    else
        fid = 1;
    end
    
    AmbientTemperature = Cooler.Temperatures(1);
    Mass = FindMassTransportSymbolic(Cooler,Gas);
    SpecificEnergy = CalculateSpecificEnergy(Cooler, Mass);
    kWh_per_ton = SpecificEnergy/3.6e3;
    COP = (Gas.States{1}.H-Gas.States{end}.H)/SpecificEnergy;
    
    fprintf(fid,'# Results\n');
    fprintf(fid,'    Ambient Tempetarure   = %.3g °C\n',AmbientTemperature);
    fprintf(fid,'    Specific Energy       = %.3g kJ/kg ( %.3g kWh/ton )\n',...
        SpecificEnergy/1e3,kWh_per_ton);
    fprintf(fid,'    COP                   = %g\n',COP);
    fprintf(fid,'\n');
    fprintf(fid,'-------------+---------+----------+-----------+---------------------\n');
    fprintf(fid,'Heat Ex. nr. | Refrig. | Temp (°C)| Mass/time | Used Heat Exchangers\n');
    fprintf(fid,'-------------|---------|----------|-----------|---------------------\n');
    for i = 1:length(Cooler.Circuits)
        fprintf(fid,' %11d | %7s | %8.3g |     %2.3f |',...
            Cooler.Circuits{i}.MyHeatExchangerNr,...
            Cooler.Circuits{i}.Refrigerant.Name,...
            Cooler.Circuits{i}.Temperature,...
            Mass(i));
        fprintf(fid,' %d ',Cooler.Circuits{i}.UsedHeatExchangers);
        fprintf(fid,'\n');
    end
    fprintf(fid,'-------------+---------+----------+-----------+---------------------\n');
    fprintf(fid,'\n');

    if fid ~= 1
        fclose(fid);
    end
end