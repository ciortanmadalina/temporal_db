DROP VIEW if exists timeGPS;
CREATE view  mob as 
SELECT astext(atperiodset(trip, getTime(atValue(tdwithin(a.trip, b.geom, 30), TRUE))))
FROM busTrip a, billboard b
WHERE dwithin(a.trip, b.geom, 30);