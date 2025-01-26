:param {
  // Define the file path root and the individual file names required for loading.
  // https://neo4j.com/docs/operations-manual/current/configuration/file-locations/
  file_path_root: 'file:///', // Change this to the folder your script can access the files at.
  file_0: 'DistrictName.csv',
  file_1: 'TargetVictim.csv',
  file_2: 'CrimeType.csv',
  file_3: 'WeaponType.csv',
  file_4: 'Street.csv',
  file_5: 'PoliceStation.csv',
  file_6: 'CrimeType_OccurredIn_DistrictName.csv',
  file_7: 'CrimeType_Involves_TargetVictim.csv',
  file_8: 'WeaponType_Used_CrimeType.csv',
  file_9: 'CrimeType_OccurredAt_Street.csv',
  file_10: 'Street_In_District.csv',
  file_11: 'Street_Located_PoliceStation.csv'
};

// CONSTRAINT creation
// -------------------
//
// Create node uniqueness constraints, ensuring no duplicates for the given node label and ID property exist in the database. This also ensures no duplicates are introduced in future.
//
// NOTE: The following constraint creation syntax is generated based on the current connected database version 5.26-aura.
CREATE CONSTRAINT `CrimeId_CrimeType_uniq` IF NOT EXISTS
FOR (n: `CrimeType`)
REQUIRE (n.`CrimeId`) IS UNIQUE;
CREATE CONSTRAINT `Name_WeaponType_uniq` IF NOT EXISTS
FOR (n: `WeaponType`)
REQUIRE (n.`Name`) IS UNIQUE;
CREATE CONSTRAINT `VictimId_TargetVictim_uniq` IF NOT EXISTS
FOR (n: `TargetVictim`)
REQUIRE (n.`VictimId`) IS UNIQUE;
CREATE CONSTRAINT `Name_District_uniq` IF NOT EXISTS
FOR (n: `District`)
REQUIRE (n.`Name`) IS UNIQUE;
CREATE CONSTRAINT `Name_Street_uniq` IF NOT EXISTS
FOR (n: `Street`)
REQUIRE (n.`Name`) IS UNIQUE;
CREATE CONSTRAINT `PoliceStationId_PoliceStation_uniq` IF NOT EXISTS
FOR (n: `PoliceStation`)
REQUIRE (n.`PoliceStationId`) IS UNIQUE;

:param {
  idsToSkip: []
};

// NODE load
// ---------
//
// Load nodes in batches, one node label at a time. Nodes will be created using a MERGE statement to ensure a node with the same label and ID property remains unique. Pre-existing nodes found by a MERGE statement will have their other properties set to the latest values encountered in a load file.
//
// NOTE: Any nodes with IDs in the 'idsToSkip' list parameter will not be loaded.
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_2) AS row
WITH row
WHERE NOT row.`CrimeId` IN $idsToSkip AND NOT toInteger(trim(row.`CrimeId`)) IS NULL
CALL {
  WITH row
  MERGE (n: `CrimeType` { `CrimeId`: toInteger(trim(row.`CrimeId`)) })
  SET n.`CrimeId` = toInteger(trim(row.`CrimeId`))
  SET n.`Type` = row.`Type`
  SET n.`Subtype` = row.`Subtype`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_3) AS row
WITH row
WHERE NOT row.`Name` IN $idsToSkip AND NOT row.`Name` IS NULL
CALL {
  WITH row
  MERGE (n: `WeaponType` { `Name`: row.`Name` })
  SET n.`Name` = row.`Name`
  SET n.`Type` = row.`Type`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_1) AS row
WITH row
WHERE NOT row.`VictimId` IN $idsToSkip AND NOT toInteger(trim(row.`VictimId`)) IS NULL
CALL {
  WITH row
  MERGE (n: `TargetVictim` { `VictimId`: toInteger(trim(row.`VictimId`)) })
  SET n.`VictimId` = toInteger(trim(row.`VictimId`))
  SET n.`Age` = toInteger(trim(row.`Age`))
  SET n.`Gender` = row.`Gender`
  SET n.`Ethnicity` = row.`Ethnicity`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row
WHERE NOT row.`Name` IN $idsToSkip AND NOT row.`Name` IS NULL
CALL {
  WITH row
  MERGE (n: `District` { `Name`: row.`Name` })
  SET n.`Name` = row.`Name`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_4) AS row
WITH row
WHERE NOT row.`Name` IN $idsToSkip AND NOT row.`Name` IS NULL
CALL {
  WITH row
  MERGE (n: `Street` { `Name`: row.`Name` })
  SET n.`Name` = row.`Name`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_5) AS row
WITH row
WHERE NOT row.`PoliceStationId` IN $idsToSkip AND NOT toInteger(trim(row.`PoliceStationId`)) IS NULL
CALL {
  WITH row
  MERGE (n: `PoliceStation` { `PoliceStationId`: toInteger(trim(row.`PoliceStationId`)) })
  SET n.`PoliceStationId` = toInteger(trim(row.`PoliceStationId`))
  SET n.`PhoneNumber` = row.`PhoneNumber`
  SET n.`Mail` = row.`Mail`
  SET n.`NumCops` = toInteger(trim(row.`NumCops`))
} IN TRANSACTIONS OF 10000 ROWS;


// RELATIONSHIP load
// -----------------
//
// Load relationships in batches, one relationship type at a time. Relationships are created using a MERGE statement, meaning only one relationship of a given type will ever be created between a pair of nodes.
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_8) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `CrimeType` { `CrimeId`: toInteger(trim(row.`CrimeId`)) })
  MATCH (target: `WeaponType` { `Name`: row.`Weapon` })
  MERGE (source)-[r: `USED`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_7) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `CrimeType` { `CrimeId`: toInteger(trim(row.`CrimeId`)) })
  MATCH (target: `TargetVictim` { `VictimId`: toInteger(trim(row.`VictimId`)) })
  MERGE (source)-[r: `INVOLVES`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_6) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `CrimeType` { `CrimeId`: toInteger(trim(row.`CrimeId`)) })
  MATCH (target: `District` { `Name`: row.`Name` })
  MERGE (source)-[r: `OCCURRED_IN`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_9) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `CrimeType` { `CrimeId`: toInteger(trim(row.`CrimeId`)) })
  MATCH (target: `Street` { `Name`: row.`StreetId` })
  MERGE (source)-[r: `OCCURRED_AT`]->(target)
  // Your script contains the datetime datatype. Our app attempts to convert dates to ISO 8601 date format before passing them to the Cypher function.
  // This conversion cannot be done in a Cypher script load. Please ensure that your CSV file columns are in ISO 8601 date format to ensure equivalent loads.
  // SET r.`DateTime` = datetime(row.`DateTime`)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_10) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Street` { `Name`: row.`Street` })
  MATCH (target: `District` { `Name`: row.`District` })
  MERGE (source)-[r: `IN`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_11) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `PoliceStation` { `PoliceStationId`: toInteger(trim(row.`PoliceStationId`)) })
  MATCH (target: `Street` { `Name`: row.`Street` })
  MERGE (source)-[r: `LOCATED`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

// Improved Labels
// -----------------
//

// Add labels to CrimeType nodes
MATCH (c:CrimeType)
CALL apoc.create.addLabels(c, [c.Type]) YIELD node
RETURN node

// Add labels to WeaponType nodes
MATCH (w:WeaponType)
CALL apoc.create.addLabels(w, [w.Type]) YIELD node
RETURN node

// Add labels to District nodes
MATCH (d:District)
CALL apoc.create.addLabels(d, [d.Name]) YIELD node
RETURN node

// Add labels to Street nodes
MATCH (s:Street)
CALL apoc.create.addLabels(s, [s.Name]) YIELD node
RETURN node

// Add labels to TargetVictim nodes
MATCH (t:TargetVictim)
CALL apoc.create.addLabels(t, [t.Ethnicity]) YIELD node
RETURN node