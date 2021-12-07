DROP VIEW if exists timeGPS;
CREATE VIEW timeGPS AS
WITH pointPair AS(
     SELECT tripID, pointID AS p1, t AS t1, geom AS geom1,
       lead(pointID, 1) OVER (PARTITION BY tripID ORDER BY pointID) p2,
       lead(t, 1) OVER (PARTITION BY tripID ORDER BY pointID) t2,
       lead(geom, 1) OVER (PARTITION BY tripID ORDER BY pointID) geom2    
     FROM gpsPoint
   ), segment AS(
     SELECT tripID, p1, p2, t1, t2,
       st_makeline(geom1, geom2) geom
    FROM pointPair
    WHERE p2 IS NOT NULL    
  ), approach AS(
    SELECT tripID, p1, p2, t1, t2, a.geom,
      st_intersection(a.geom, st_exteriorRing(st_buffer(b.geom, 30))) visibilityTogglePoint
    FROM segment a, billboard b
    WHERE st_dwithin(a.geom, b.geom, 30)
  )
  SELECT tripID, p1, p2, t1, t2, geom, visibilityTogglePoint,
    (st_lineLocatePoint(geom, visibilityTogglePoint) * (t2 - t1)) + t1 visibilityToggleTime,
	st_lineLocatePoint(geom, visibilityTogglePoint) * (t2 - t1) visibilityTime
  FROM approach;