--NOTE MY TABLE WAS NAMED public.dijon_evolution_population. YOU WILL NEED TO CHANGE THAT TO CUSTOM YOUR QUERY. SAME WITH COLUMN NAMES
--creation of an updated geom column containing geometries for use in Superset
alter table public.dijon_evolution_population add column geom_actualise text;

-- Update the geom_actualise column with the GeoJSON for each feature
UPDATE public.dijon_evolution_population AS dep
SET geom_actualise = geojson_result.geojson
FROM (
    SELECT
    --we retrieve the common code and put it in the JSON properties
        code_commune,
        --JSON constructor
        jsonb_build_object(
            --first key and first value. It's important to note that's a "Feature" value.
            'type', 'Feature',
            --second key and second value
            --Use "ST_ForcePolygonCCW" to create a valid Geojson that complies with the Right Hand Rule (RHR) standard
            'geometry', ST_AsGeoJSON(ST_ForcePolygonCCW(geom))::jsonb,
            --third key and third value
            'properties', jsonb_build_object(
                'id', code_commune
                -- Add more properties here if needed
            )
        ) AS geojson
    FROM public.dijon_evolution_population
) AS geojson_result
WHERE dep.code_commune = geojson_result.code_commune;

--test et check. Try the validation of one feature by this website : https://geojsonlint.com/ 
select geom_actualise from public.dijon_evolution_population dep  limit 3,
