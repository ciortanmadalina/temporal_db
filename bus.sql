CREATE EXTENSION MobilityDB CASCADE;

DROP table busTrip;
CREATE TABLE busTrip(tripID, trip) AS
  SELECT tripID,tgeompoint_seq(array_agg(tgeompoint_inst(geom, t) ORDER BY t))
FROM gpsPoint
GROUP BY tripID;


SELECT astext(atperiodset(trip, getTime(atValue(tdwithin(a.trip, b.geom, 30), TRUE))))
FROM busTrip a, billboard b
WHERE dwithin(a.trip, b.geom, 30);