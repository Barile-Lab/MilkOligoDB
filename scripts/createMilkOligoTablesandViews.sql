
--CREATE DATABASE "MilkOligoDB" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';

BEGIN;

-- CREATE SCHEMA  ------------------------------
CREATE SCHEMA IF NOT EXISTS "MilkOligoDB_V1_230131"; -- we will use postgres schemas to keep track of database versions, so that users can follow, keep and compare different versions of the database.
-- -------------------------------------------------------------
-- 
GRANT USAGE ON SCHEMA   "MilkOligoDB_V1_230131" TO $USERNAME --change this to your actual postgres database use name
;
SET search_path TO "MilkOligoDB_V1_230131";
END;
COMMIT;

CREATE TABLE IF NOT EXISTS "tbl_animal" ( 
	"Category" CHARACTER VARYING,
	"Common Name" CHARACTER VARYING,
	"Order" CHARACTER VARYING,
	"Family" CHARACTER VARYING, 
	"Genus" CHARACTER VARYING,
	"Species" CHARACTER VARYING,
	"Subspecies" CHARACTER VARYING,
	"NCBILink" CHARACTER VARYING,
	"NCBITaxID" INTEGER )
	;

 -------------------------------------------------------------
-- 
CREATE TABLE IF NOT EXISTS "tbl_article" ( 
	"PubMed ID" CHARACTER VARYING,
	"DOI" CHARACTER VARYING,
	"Analytical Method" CHARACTER VARYING,
	"1st Author" CHARACTER VARYING,
	"Year" NUMERIC )
	;
-------------------------------------------------------------
-- 
CREATE TABLE IF NOT EXISTS "tbl_oligosaccharide" ( 
	"isomer_ID" CHARACTER VARYING,
	"Fucosylated" BOOLEAN,
	"Acidic" BOOLEAN,
	"Neutral" BOOLEAN,
	"Basic Core Type" NUMERIC,
	"isomer_name" CHARACTER VARYING,
	"hasLinkage" BOOLEAN,
	"has_Neu5Gc" BOOLEAN,
	"Hex" INTEGER,
	"HexNAc" INTEGER,
	"Fuc" INTEGER,
	"Neu5Ac" SMALLINT,
	"isomer_suffix" CHARACTER( 3 ) NOT NULL,
	"Neu5Gc" SMALLINT,
	"CoreType_1" BOOLEAN,
	"CoreType_2" BOOLEAN )
	;
-------------------------------------------------------------

CREATE TABLE "tbl_AnimalArticle" ( 
	"NCBITaxID" INTEGER NOT NULL,
	"Number of Donors" CHARACTER VARYING,
	"Total Number of Samples" CHARACTER VARYING,
	"Number of Oligosaccharides Identified" CHARACTER VARYING,
	"Analytical Method" CHARACTER VARYING,
	"PubMed ID" CHARACTER VARYING,
	"DOI" CHARACTER VARYING NOT NULL,
	PRIMARY KEY ( "NCBITaxID", "DOI" ) );

-----------------------------------------------------------

 CREATE TABLE IF NOT EXISTS "tbl_AnimalArticleOligo" ( 
	"DOI" CHARACTER VARYING,
	"isomer_ID" CHARACTER VARYING,
	"NCBITaxID" INTEGER )
	;

-------------------------------------------------------------
 
-- CREATE VIEW "vw_uniq_OligosPerAnimal" -----------------------
CREATE OR REPLACE VIEW "vw_uniq_OligosPerAnimal" AS  SELECT DISTINCT tbl_animal."Category",
    tbl_animal."Common Name",
    tbl_animal."Order",
    tbl_animal."Family",
    tbl_animal."Genus",
    tbl_animal."Species",
    tbl_animal."Subspecies",
    tbl_oligosaccharide."isomer_ID",
    tbl_oligosaccharide.has_linkage,
    tbl_oligosaccharide."CoreType_1",
    tbl_oligosaccharide."CoreType_2",
    tbl_oligosaccharide."Fucosylated",
    tbl_oligosaccharide."Acidic",
    tbl_oligosaccharide."Neutral",
    tbl_oligosaccharide."has_Neu5Gc",
    tbl_animal."NCBITaxID"
   FROM ((("MilkOligoDB_V1.0_230130".tbl_animal
     JOIN "MilkOligoDB_V1.0_230130"."tbl_AnimalArticleOligo" ON ((tbl_animal."NCBITaxID" = "tbl_AnimalArticleOligo"."NCBITaxID")))
     JOIN "MilkOligoDB_V1.0_230130".tbl_article ON (((tbl_article."DOI")::TEXT = ("tbl_AnimalArticleOligo"."DOI")::TEXT)))
     JOIN "MilkOligoDB_V1.0_230130".tbl_oligosaccharide ON (((tbl_oligosaccharide."isomer_ID")::TEXT = ("tbl_AnimalArticleOligo"."isomer_ID")::TEXT)))
  ORDER BY tbl_animal."Order", tbl_animal."Category", tbl_animal."Common Name", tbl_animal."Family", tbl_oligosaccharide."isomer_ID";;
-- -------------------------------------------------------------

-- CHANGE "COMMENT" OF "VIEW "vw_uniq_OligosPerAnimal" ---------
COMMENT ON VIEW "MilkOligoDB_V1.0_230130"."vw_uniq_OligosPerAnimal" IS 'This view constructs a record for each unique combination of animal to oligosaccharide across all articles. It is the basis for counts and comparisons across animals that do not concern article level details.';
-- ------------

-- CREATE VIEW "vw_oligosPerAnimalArticle" ---------------------
CREATE OR REPLACE VIEW "MilkOligoDB_V1.0_230130"."vw_oligosPerAnimalArticle" AS  SELECT tbl_animal."Category",
    tbl_animal."Common Name",
    tbl_animal."Order",
    tbl_animal."Family",
    tbl_animal."Genus",
    tbl_animal."Species",
    tbl_animal."Subspecies",
    tbl_oligosaccharide."isomer_ID",
    tbl_oligosaccharide.isomer_name,
    tbl_oligosaccharide.has_linkage,
    tbl_oligosaccharide."CoreType_1",
    tbl_oligosaccharide."CoreType_2",
    tbl_oligosaccharide."Fucosylated",
    tbl_oligosaccharide."Acidic",
    tbl_oligosaccharide."Neutral",
    tbl_oligosaccharide."has_Neu5Gc",
    tbl_animal."NCBITaxID",
    tbl_article."DOI"
   FROM ((("MilkOligoDB_V1.0_230130".tbl_animal
     JOIN "MilkOligoDB_V1.0_230130"."tbl_AnimalArticleOligo" ON ((tbl_animal."NCBITaxID" = "tbl_AnimalArticleOligo"."NCBITaxID")))
     JOIN "MilkOligoDB_V1.0_230130".tbl_article ON (((tbl_article."DOI")::TEXT = ("tbl_AnimalArticleOligo"."DOI")::TEXT)))
     JOIN "MilkOligoDB_V1.0_230130".tbl_oligosaccharide ON (((tbl_oligosaccharide."isomer_ID")::TEXT = ("tbl_AnimalArticleOligo"."isomer_ID")::TEXT)))
  ORDER BY tbl_animal."Order", tbl_animal."Category", tbl_animal."Common Name", tbl_animal."Family", tbl_oligosaccharide."isomer_ID", tbl_oligosaccharide.isomer_name;;
-- -------------------------------------------------------------

-- CHANGE "COMMENT" OF "VIEW "vw_oligosPerAnimalArticle" -------
COMMENT ON VIEW "MilkOligoDB_V1.0_230130"."vw_oligosPerAnimalArticle" IS 'This view queries across all base tables to produce a view of each unique combination of animal and oligosaccharide per article';
-- -------------------------------------------------------------
-- CREATE VIEW "vw_cntOligoFeatsPerAnimal" ---------------------
CREATE OR REPLACE VIEW "MilkOligoDB_V1.0_230130"."vw_cntOligoFeatsPerAnimal" AS  SELECT "vw_uniq_OligosPerAnimal"."Category",
    "vw_uniq_OligosPerAnimal"."Common Name",
    "vw_uniq_OligosPerAnimal"."Order",
    "vw_uniq_OligosPerAnimal"."Family",
    "vw_uniq_OligosPerAnimal"."Genus",
    "vw_uniq_OligosPerAnimal"."Species",
    "vw_uniq_OligosPerAnimal"."Subspecies",
    count(DISTINCT "vw_uniq_OligosPerAnimal"."isomer_ID") AS "count Unq Oligos",
    count("vw_uniq_OligosPerAnimal".has_linkage) AS "count w linkage",
    count("vw_uniq_OligosPerAnimal"."CoreType_1") AS "count Core1",
    count("vw_uniq_OligosPerAnimal"."CoreType_2") AS "count Core2",
    count("vw_uniq_OligosPerAnimal"."Fucosylated") AS "count Fuc",
    count("vw_uniq_OligosPerAnimal"."Acidic") AS "count Acidic",
    count("vw_uniq_OligosPerAnimal"."Neutral") AS "count Neutral",
    count("vw_uniq_OligosPerAnimal"."has_Neu5Gc") AS "count wNeu5Gc",
    "vw_uniq_OligosPerAnimal"."NCBITaxID"
   FROM "MilkOligoDB_V1.0_230130"."vw_uniq_OligosPerAnimal"
  GROUP BY "vw_uniq_OligosPerAnimal"."Category", "vw_uniq_OligosPerAnimal"."Common Name", "vw_uniq_OligosPerAnimal"."Order", "vw_uniq_OligosPerAnimal"."Family", "vw_uniq_OligosPerAnimal"."Genus", "vw_uniq_OligosPerAnimal"."Species", "vw_uniq_OligosPerAnimal"."Subspecies", "vw_uniq_OligosPerAnimal"."NCBITaxID"
  ORDER BY "vw_uniq_OligosPerAnimal"."Order", "vw_uniq_OligosPerAnimal"."Category", "vw_uniq_OligosPerAnimal"."Common Name", "vw_uniq_OligosPerAnimal"."Family", "vw_uniq_OligosPerAnimal"."Genus", "vw_uniq_OligosPerAnimal"."Species", "vw_uniq_OligosPerAnimal"."Subspecies";;
-- -------------------------------------------------------------

-- CHANGE "COMMENT" OF "VIEW "vw_cntOligoFeatsPerAnimal" -------
COMMENT ON VIEW "MilkOligoDB_V1.0_230130"."vw_cntOligoFeatsPerAnimal" IS 'This view counts the oligosaccharide features across each animal.';
-- -------------------------------------------------------------

-- CREATE VIEW "vw_cntOligoFeatsAnimalMatchHuman" --------------
CREATE OR REPLACE VIEW "MilkOligoDB_V1.0_230130"."vw_cntOligoFeatsAnimalMatchHuman" AS  SELECT DISTINCT "vw_uniq_OligosPerAnimal"."Category",
    "vw_uniq_OligosPerAnimal"."Common Name",
    "vw_uniq_OligosPerAnimal"."Order",
    "vw_uniq_OligosPerAnimal"."Family",
    "vw_uniq_OligosPerAnimal"."Genus",
    "vw_uniq_OligosPerAnimal"."Species",
    "vw_uniq_OligosPerAnimal"."Subspecies",
    count(DISTINCT "vw_uniq_OligosPerAnimal"."isomer_ID") AS "count unq isomers",
    count("vw_uniq_OligosPerAnimal".has_linkage) AS "count w linkage",
    count("vw_uniq_OligosPerAnimal"."CoreType_1") AS "count Core1",
    count("vw_uniq_OligosPerAnimal"."CoreType_2") AS "count Core2",
    count("vw_uniq_OligosPerAnimal"."Fucosylated") AS "count Fuc",
    count("vw_uniq_OligosPerAnimal"."Acidic") AS "count Acidic",
    count("vw_uniq_OligosPerAnimal"."Neutral") AS "count Neutral",
    count("vw_uniq_OligosPerAnimal"."has_Neu5Gc") AS "count Neu5Gc",
    "vw_uniq_OligosPerAnimal"."NCBITaxID"
   FROM ("MilkOligoDB_V1.0_230130"."vw_uniq_OligosPerAnimal" "V"
     JOIN "MilkOligoDB_V1.0_230130"."vw_uniq_OligosPerAnimal" ON ((("V"."isomer_ID")::TEXT = ("vw_uniq_OligosPerAnimal"."isomer_ID")::TEXT)))
  WHERE ((("vw_uniq_OligosPerAnimal"."Common Name")::TEXT <> 'Human'::TEXT) AND (("V"."Common Name")::TEXT = 'Human'::TEXT))
  GROUP BY "vw_uniq_OligosPerAnimal"."Order", "vw_uniq_OligosPerAnimal"."Category", "vw_uniq_OligosPerAnimal"."Common Name", "vw_uniq_OligosPerAnimal"."Family", "vw_uniq_OligosPerAnimal"."Genus", "vw_uniq_OligosPerAnimal"."Species", "vw_uniq_OligosPerAnimal"."Subspecies", "vw_uniq_OligosPerAnimal"."NCBITaxID", "V"."Common Name";;
-- -------------------------------------------------------------

-- CHANGE "COMMENT" OF "VIEW "vw_cntOligoFeatsAnimalMatchHuman" 
COMMENT ON VIEW "MilkOligoDB_V1.0_230130"."vw_cntOligoFeatsAnimalMatchHuman" IS 'This view counts the oligosaccharide features across each non-human animal, that also matches with human milk oligosaccharides.';
-- -------------------------------------------------------------

-- CREATE VIEW "vw_compareCntOligoFeatsAnimal2Human" -----------
CREATE OR REPLACE VIEW "MilkOligoDB_V1.0_230130"."vw_compareCntOligoFeatsAnimal2Human" AS  SELECT tbl_animal."Category",
    tbl_animal."Common Name",
    tbl_animal."Order",
    tbl_animal."Family",
    tbl_animal."Genus",
    tbl_animal."Species",
    tbl_animal."Subspecies",
    "vw_cntOligoFeatsPerAnimal"."count Unq Oligos",
    "vw_cntOligoFeatsAnimalMatchHuman"."count unq isomers" AS "cnt unq Oligos match Humans",
    "vw_cntOligoFeatsPerAnimal"."count w linkage",
    "vw_cntOligoFeatsAnimalMatchHuman"."count w linkage" AS "cnt link match Humans",
    "vw_cntOligoFeatsPerAnimal"."count Core1",
    "vw_cntOligoFeatsAnimalMatchHuman"."count Core1" AS "cnt Core1 match Humans",
    "vw_cntOligoFeatsPerAnimal"."count Core2",
    "vw_cntOligoFeatsAnimalMatchHuman"."count Core2" AS "cnt Core2 match Humans",
    "vw_cntOligoFeatsPerAnimal"."count Fuc",
    "vw_cntOligoFeatsAnimalMatchHuman"."count Fuc" AS "cnt Fuc match Humans",
    "vw_cntOligoFeatsPerAnimal"."count Acidic",
    "vw_cntOligoFeatsAnimalMatchHuman"."count Acidic" AS "cnt Acidic match Humans",
    "vw_cntOligoFeatsPerAnimal"."count Neutral",
    "vw_cntOligoFeatsAnimalMatchHuman"."count Neutral" AS "cnt Neutral match Humans",
    "vw_cntOligoFeatsPerAnimal"."count wNeu5Gc",
    "vw_cntOligoFeatsAnimalMatchHuman"."count Neu5Gc" AS "cnt Neu5Gc match Humans",
    tbl_animal."NCBITaxID"
   FROM (("MilkOligoDB_V1.0_230130"."vw_cntOligoFeatsAnimalMatchHuman"
     JOIN "MilkOligoDB_V1.0_230130".tbl_animal ON (("vw_cntOligoFeatsAnimalMatchHuman"."NCBITaxID" = tbl_animal."NCBITaxID")))
     JOIN "MilkOligoDB_V1.0_230130"."vw_cntOligoFeatsPerAnimal" ON ((tbl_animal."NCBITaxID" = "vw_cntOligoFeatsPerAnimal"."NCBITaxID")));;
-- -------------------------------------------------------------

-- CHANGE "COMMENT" OF "VIEW "vw_compareCntOligoFeatsAnimal2Human" 
COMMENT ON VIEW "MilkOligoDB_V1.0_230130"."vw_compareCntOligoFeatsAnimal2Human" IS 'This view counts the oligosaccharide features across each animal compared to the animal milk oligosaccharide features that are matched with human milk oligosaccharide features. It is the basis for the Summary 3 table in the forthcoming publication.';
-- -------------------------------------------------------------

-- 