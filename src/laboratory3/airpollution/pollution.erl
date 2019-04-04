-module(pollution).
-author("jakub").

%% API
-export([]).
-export([createMonitor/0, addStation/3, addValue/5]).

-record(station, {name, coordinates}).
-record(measurement, {date = calendar:local_time(), type, value = 0}).
-record(monitor, {stationsMap = #{}, measurementsMap = #{}}).


createMonitor() ->
  #monitor{}.


addStation(Name, {Latitude, Longitude}, Monitor)
  when is_record(Monitor, monitor) and is_number(Latitude) and is_number(Longitude) ->
  case (maps:is_key(Name, Monitor#monitor.stationsMap) or maps:is_key({Latitude, Longitude}, Monitor#monitor.stationsMap)) of
    true ->
      error_logger:error_msg("There is already station with the same name or the same coordinates in the system!");
    false ->
      Station = #station{name = Name, coordinates = {Latitude, Longitude}},
      StationsMap = Monitor#monitor.stationsMap,
      MeasurementsMap = Monitor#monitor.measurementsMap,
      #monitor{stationsMap = maps:put(Name, Station, StationsMap), measurementsMap = MeasurementsMap}
  end;
addStation(_, _, _)
  -> error_logger:error_msg("Bad arguments! Try again").



addValue(_, _, _, _, #{}) -> error_logger:error_msg("The monitor is empty!");
addValue(StationKey, Date, Type, Value, Monitor) ->
  StationsMap = Monitor#monitor.stationsMap,
  MeasurementsMap = Monitor#monitor.measurementsMap,
  try maps:get(StationKey, StationsMap) of
    Station ->
      Measurement = #measurement{date = Date, type = Type, value = Value},
      try maps:get(Station, MeasurementsMap) of
        MeasurementsList ->
          case lists:member(Measurement, MeasurementsList) of
            true -> error_logger:error_msg("There is already such measurement for station: ~p", [Station]);
            false -> #monitor{
              stationsMap = StationsMap,
              measurementsMap = MeasurementsMap#{Station := MeasurementsList ++ [Measurement]}
            }
          end
      catch
        error:_ ->
          #monitor{stationsMap = StationsMap, measurementsMap = maps:put(Station, [Measurement], MeasurementsMap)}
      end
  catch
    error:_ -> error_logger:error_msg("There is no such station in the system! Try again~n")
  end.

